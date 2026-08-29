#!/usr/bin/env bash
# fix-noctalia-keyring.sh - Migrate Noctalia Google Calendar refresh-token
# from Default_Keyring (remains locked after screen lock) to the login
# keyring (auto-unlocked by GDM via pam_gnome_keyring). Only touches the
# default keyring; GDM (gdm-password) already unlocks login, no need to
# patch TTY login unless explicitly requested.
#
# Idempotent with backups. See noctalia.log 2026-08-28/29:
# status=denied-or-locked category=locked + secret-tool showing token in
# Default_Keyring/23 with schema dev.noctalia.Secret.
#
# Usage: ./script/fix-noctalia-keyring.sh [--check-only] [--no-pam] [--with-login]
#   --check-only : run diagnostics only, no changes
#   --no-pam     : skip PAM checks/patching (GDM already OK)
#   --with-login : also patch /etc/pam.d/login for TTY auto-unlock
#
# Rollback:
#   cp ~/.local/share/keyrings/default.bak.YYYYMMDD ~/.local/share/keyrings/default
#   cp ~/.local/share/keyrings/login.keyring.bak.* ~/.local/share/keyrings/login.keyring
#   sudo cp /etc/pam.d/login.bak.YYYYMMDD /etc/pam.d/login  # if --with-login was used
#   # Restore previous Default item via seahorse if needed
set -euo pipefail

CHECK_ONLY=0
NO_PAM=0
WITH_LOGIN=0
for arg in "$@"; do
  case "$arg" in
    --check-only) CHECK_ONLY=1 ;;
    --no-pam) NO_PAM=1 ;;
    --with-login) WITH_LOGIN=1 ;;
    -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
    *) echo "unknown arg: $arg" >&2; exit 1 ;;
  esac
done

info()  { printf "\033[36m[fix-noctalia]\033[0m %s\n" "$*"; }
warn()  { printf "\033[33m[fix-noctalia]\033[0m WARN: %s\n" "$*"; }
fail()  { printf "\033[31m[fix-noctalia]\033[0m FAIL: %s\n" "$*"; exit 1; }

timestamp="$(date +%Y%m%d_%H%M%S)"
keyring_dir="$HOME/.local/share/keyrings"
default_file="$keyring_dir/default"

# 1. Diagnostics - never print secret values, only metadata
info "Diagnostics: keyring / PAM"
echo "  default collection: $(cat "$default_file" 2>/dev/null || echo '<missing>')"
echo "  pam login has gnome_keyring: $(grep -c pam_gnome_keyring /etc/pam.d/login 2>/dev/null || echo 0)"
echo "  gdm-password has gnome_keyring: $(grep -c pam_gnome_keyring /etc/pam.d/gdm-password 2>/dev/null || echo 0)"

if command -v secret-tool >/dev/null 2>&1; then
  echo "  secret-tool search scope=calendar (redacted):"
  # Hide secret value - only show label, schema, attributes and collection
  secret-tool search --all scope calendar 2>&1 | grep -v "^secret = " | sed 's/^/    /' || true
  # Show count without exposing secret
  count="$(secret-tool search --all scope calendar 2>&1 | grep -c "^\[/" || true)"
  echo "    -> $count matching item(s) (secrets redacted)"
else
  warn "secret-tool not found"
fi

if command -v busctl >/dev/null 2>&1; then
  for col in login Default_5fKeyring; do
    locked="$(busctl --user get-property org.freedesktop.secrets "/org/freedesktop/secrets/collection/$col" org.freedesktop.Secret.Collection Locked 2>&1 || echo "unknown")"
    echo "  $col Locked: $locked"
  done
fi

# Python diagnostic using libsecret with correct schema - does not expose secret
python3 - <<'PY' 2>&1 | sed 's/^/  py: /' || true
import gi
gi.require_version('Secret', '1')
from gi.repository import Secret
schema = Secret.Schema.new("dev.noctalia.Secret", Secret.SchemaFlags.NONE,
    {"application": Secret.SchemaAttributeType.STRING, "version": Secret.SchemaAttributeType.STRING,
     "name": Secret.SchemaAttributeType.STRING, "owner": Secret.SchemaAttributeType.STRING,
     "scope": Secret.SchemaAttributeType.STRING})
attrs = {"application":"noctalia","version":"1","name":"refresh-token","owner":"perso","scope":"calendar"}
try:
    items = Secret.password_search_sync(schema, attrs, Secret.SearchFlags.ALL, None)
    print(f"password_search_sync dev.noctalia.Secret perso/calendar: {len(items) if items else 0} found")
    if items:
        for it in items:
            print(f"  - {it.get_label()} (collection via search)")
except Exception as e:
    print(f"search error: {e}")
PY

if [[ $CHECK_ONLY -eq 1 ]]; then
  info "--check-only: exiting without changes"
  exit 0
fi

# 2. Backup keyring files with restricted permissions
info "Backing up keyring files"
mkdir -p "$keyring_dir"
# Ensure backups are not world-readable
umask 077
cp -v "$default_file" "$default_file.bak.$timestamp" 2>/dev/null || warn "default file missing"
cp -v "$keyring_dir/login.keyring" "$keyring_dir/login.keyring.bak.$timestamp" 2>/dev/null || true
cp -v "$keyring_dir/Default_Keyring.keyring" "$keyring_dir/Default_Keyring.keyring.bak.$timestamp" 2>/dev/null || true
chmod 600 "$default_file.bak.$timestamp" 2>/dev/null || true

# 3. Ensure default collection is login (auto-unlocked by GDM)
if [[ "$(cat "$default_file" 2>/dev/null || echo "")" != "login" ]]; then
  info "default != login -> fixing"
  # Use atomic write with restricted perms
  tmp_default="$(mktemp)"
  chmod 600 "$tmp_default"
  echo "login" > "$tmp_default"
  mv -f "$tmp_default" "$default_file"
  chmod 600 "$default_file"
  info "default set to login"
else
  info "default already login"
fi

# 4. Migrate token to login with correct schema
info "Migrating Noctalia token to login (schema dev.noctalia.Secret)"

python3 <<'PY'
import subprocess
import sys
import gi
gi.require_version('Secret', '1')
from gi.repository import Secret

SCHEMA_NAME = "dev.noctalia.Secret"
ATTRS = {"application":"noctalia","version":"1","name":"refresh-token","owner":"perso","scope":"calendar"}
LABEL = "Noctalia calendar refresh token"

schema = Secret.Schema.new(SCHEMA_NAME, Secret.SchemaFlags.NONE,
    {"application": Secret.SchemaAttributeType.STRING, "version": Secret.SchemaAttributeType.STRING,
     "name": Secret.SchemaAttributeType.STRING, "owner": Secret.SchemaAttributeType.STRING,
     "scope": Secret.SchemaAttributeType.STRING})

# Retrieve token securely - prefer libsecret, fallback to secret-tool
# Never print token value, only length
token = None
try:
    # Try libsecret first (correct schema)
    token = Secret.password_lookup_sync(schema, ATTRS, None)
    if token:
        print(f"token found via libsecret schema {SCHEMA_NAME} len={len(token)}")
except Exception as e:
    print(f"libsecret lookup error: {e}")

if not token:
    # Fallback: attribute-only search (finds Generic or dev.noctalia)
    try:
        out = subprocess.check_output(
            ["secret-tool","lookup","application","noctalia","scope","calendar"],
            text=True
        ).strip()
        if out:
            token = out
            print(f"token found via secret-tool fallback len={len(token)}")
    except subprocess.CalledProcessError:
        pass
    except Exception as e:
        print(f"secret-tool lookup error: {e}")

if not token:
    print("No token found - Noctalia not connected to Google Calendar, nothing to migrate (reconnect via Noctalia UI)")
    sys.exit(0)

# Check if already correctly stored in login with valid schema
try:
    existing = Secret.password_lookup_sync(schema, ATTRS, None)
    if existing and existing == token:
        import subprocess as sp
        # Check each collection for duplicates
        for col in ["login", "Default_5fKeyring"]:
            try:
                out = sp.check_output(
                    ["busctl","--user","call","org.freedesktop.secrets",
                     f"/org/freedesktop/secrets/collection/{col}",
                     "org.freedesktop.Secret.Collection","SearchItems",
                     "a{ss}","2","application","noctalia","scope","calendar"],
                    text=True
                ).strip()
                if "Default_5fKeyring" in out and "/Default_5fKeyring/" in out:
                    print(f"duplicate remaining in {col}: {out} -> cleanup required")
                else:
                    print(f"collection {col} SearchItems: {out}")
            except Exception as e:
                print(f"SearchItems {col} error: {e}")
        out = sp.check_output(
            ["busctl","--user","call","org.freedesktop.secrets",
             "/org/freedesktop/secrets","org.freedesktop.Secret.Service","SearchItems",
             "a{ss}","2","application","noctalia","scope","calendar"],
            text=True
        ).strip()
        print(f"Service SearchItems: {out}")
        if "/Default_5fKeyring/" in out:
            print("cleanup of Default required despite existing correct token")
        else:
            print("token already correctly in login, checking for Generic duplicates")
            try:
                all_search = sp.check_output(
                    ["secret-tool","search","--all","application","noctalia","scope","calendar"],
                    text=True
                )
                count_generic = all_search.count("org.freedesktop.Secret.Generic")
                count_correct = all_search.count("dev.noctalia.Secret")
                if count_generic > 0:
                    print(f"Generic duplicate detected ({count_generic}) plus correct ({count_correct}) -> cleanup")
                else:
                    print("no duplicates, already clean -> exit 0")
                    sys.exit(0)
            except Exception:
                pass
except Exception as e:
    print(f"check existing error: {e}")

# Store in login with correct schema (COLLECTION_DEFAULT points to default==login)
# Use libsecret which handles secure memory and avoids command-line exposure
print("storing token in login with schema dev.noctalia.Secret...")
try:
    ok = Secret.password_store_sync(schema, ATTRS, Secret.COLLECTION_DEFAULT, LABEL, token, None)
    print(f"password_store_sync -> {ok}")
    # Clear token from memory
    token = None
except Exception as e:
    print(f"store error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

# Cleanup: remove misplaced items (Generic schema or wrong collection)
# Keep only the newest correct item in login
import subprocess as sp
import re
try:
    out = sp.check_output(
        ["busctl","--user","call","org.freedesktop.secrets",
         "/org/freedesktop/secrets","org.freedesktop.Secret.Service","SearchItems",
         "a{ss}","2","application","noctalia","scope","calendar"],
        text=True
    ).strip()
    paths = re.findall(r'"/org/freedesktop/secrets/[^"]+"', out)
    print(f"paths found: {len(paths)}")
    keep = None
    for p in paths:
        loc = p.strip('"')
        try:
            typ = sp.check_output(
                ["busctl","--user","get-property","org.freedesktop.secrets",loc,
                 "org.freedesktop.Secret.Item","Type"],
                text=True
            ).strip()
            # Redact label/created from logs except for debugging type/collection
            created = sp.check_output(
                ["busctl","--user","get-property","org.freedesktop.secrets",loc,
                 "org.freedesktop.Secret.Item","Created"],
                text=True
            ).strip()
            is_login = "login" in loc
            is_correct_schema = "dev.noctalia.Secret" in typ
            # Keep newest correct item in login
            if is_login and is_correct_schema:
                if keep is None:
                    keep = (loc, created)
                else:
                    if created > keep[1]:
                        print(f"  duplicate correct older {keep[0]} -> delete, keep {loc}")
                        sp.check_output(
                            ["busctl","--user","call","org.freedesktop.secrets",keep[0],
                             "org.freedesktop.Secret.Item","Delete"],
                            text=True
                        )
                        keep = (loc, created)
                    else:
                        print(f"  duplicate correct {loc} -> delete, keep {keep[0]}")
                        sp.check_output(
                            ["busctl","--user","call","org.freedesktop.secrets",loc,
                             "org.freedesktop.Secret.Item","Delete"],
                            text=True
                        )
            elif not is_correct_schema or "Default" in loc:
                print(f"  removing misplaced item: collection={'login' if is_login else 'Default'}, schema={'correct' if is_correct_schema else 'Generic'}")
                sp.check_output(
                    ["busctl","--user","call","org.freedesktop.secrets",loc,
                     "org.freedesktop.Secret.Item","Delete"],
                    text=True
                )
        except Exception as e:
            print(f"  inspect/delete error for {loc}: {e}")
    print(f"kept: {keep[0] if keep else 'none'}")
except Exception as e:
    print(f"cleanup error: {e}")
    import traceback
    traceback.print_exc()

# Final verification - do not expose secret
try:
    final = Secret.password_lookup_sync(schema, ATTRS, None)
    if final:
        print(f"final verification OK len={len(final)}")
        final = None  # clear
    else:
        print("final verification FAILED - token not found after migration")
        sys.exit(1)
except Exception as e:
    print(f"verification error: {e}")
    sys.exit(1)

# Ensure token cleared from memory
try:
    del token
except:
    pass
print("migration completed")
PY
py_exit=$?
if [[ $py_exit -ne 0 ]]; then
  fail "Python migration failed (exit $py_exit)"
fi

# 5. PAM - only GDM after login, not whole system (TTY login opt-in)
if [[ $NO_PAM -eq 1 ]]; then
  info "--no-pam: skipping PAM"
else
  # GDM after login = gdm-password (unlocks login). Already correct on this host, verify only.
  gdm_file="/etc/pam.d/gdm-password"
  if grep -q "pam_gnome_keyring.so" "$gdm_file" 2>/dev/null; then
    info "PAM GDM OK: pam_gnome_keyring already in $gdm_file (login unlocked after GDM)"
  else
    warn "PAM GDM missing in $gdm_file - patch required (sudo)"
    pam_backup="/etc/pam.d/gdm-password.bak.$timestamp"
    if ! sudo cp -v "$gdm_file" "$pam_backup"; then
      fail "sudo cp backup gdm-password failed"
    fi
    sudo chmod 644 "$pam_backup"
    tmp_pam="$(mktemp)"
    # Secure temp file
    chmod 600 "$tmp_pam"
    cat "$gdm_file" > "$tmp_pam"
    grep -q "auth.*pam_gnome_keyring" "$tmp_pam" || echo "auth       optional     pam_gnome_keyring.so" >> "$tmp_pam"
    grep -q "session.*pam_gnome_keyring" "$tmp_pam" || echo "session    optional     pam_gnome_keyring.so auto_start" >> "$tmp_pam"
    grep -q "password.*pam_gnome_keyring" "$tmp_pam" || echo "password   optional     pam_gnome_keyring.so use_authtok" >> "$tmp_pam"
    if sudo tee "$gdm_file" < "$tmp_pam" >/dev/null; then
      info "PAM gdm-password updated"
      sudo chmod 644 "$gdm_file"
      rm -f "$tmp_pam"
    else
      rm -f "$tmp_pam"
      fail "sudo tee gdm-password failed"
    fi
  fi

  # TTY login only if explicitly requested
  if [[ $WITH_LOGIN -eq 1 ]]; then
    info "Configuring PAM /etc/pam.d/login (--with-login)"
    pam_file="/etc/pam.d/login"
    pam_backup="/etc/pam.d/login.bak.$timestamp"
    if grep -q "pam_gnome_keyring.so" "$pam_file" 2>/dev/null; then
      info "pam_gnome_keyring already in $pam_file (skip)"
    else
      info "Adding pam_gnome_keyring to $pam_file (requires sudo)"
      if ! sudo cp -v "$pam_file" "$pam_backup"; then
        fail "sudo cp backup failed - run manually"
      fi
      sudo chmod 644 "$pam_backup"
      if ! grep -q "auth.*pam_nologin.so" "$pam_file"; then
        warn "$pam_file unexpected content, manual edit recommended"
      fi
      tmp_pam="$(mktemp)"
      chmod 600 "$tmp_pam"
      cat > "$tmp_pam" <<'EOF_PAM'
#%PAM-1.0
auth       requisite    pam_nologin.so
auth       include      system-local-login
auth       optional     pam_gnome_keyring.so
account    include      system-local-login
session    include      system-local-login
session    optional     pam_gnome_keyring.so auto_start
password   include      system-local-login
password   optional     pam_gnome_keyring.so use_authtok
EOF_PAM
      if sudo tee "$pam_file" < "$tmp_pam" >/dev/null; then
        info "PAM login TTY updated"
        sudo chmod 644 "$pam_file"
        rm -f "$tmp_pam"
        cat "$pam_file" | sed 's/^/    /'
      else
        rm -f "$tmp_pam"
        fail "sudo tee failed"
      fi
    fi
  else
    # If login was previously patched but user wants GDM-only, warn and suggest revert
    if grep -q "pam_gnome_keyring.so" /etc/pam.d/login 2>/dev/null; then
      warn "/etc/pam.d/login contains pam_gnome_keyring (previous patch) - requested GDM-only"
      echo "  To revert TTY login to original (no auto-unlock):"
      echo "    sudo cp /etc/pam.d/login.bak.20260829 /etc/pam.d/login"
      echo "  (backup from $(stat -c %y /etc/pam.d/login.bak.20260829 2>/dev/null | cut -d' ' -f1))"
      echo "  Or re-run with --with-login to keep TTY patch"
    else
      info "PAM login TTY not modified (GDM-only) - OK"
    fi
  fi
fi

# 6. Final verification (redacted)
info "Final verification"
echo "  default: $(cat "$default_file")"
secret-tool search --all scope calendar 2>&1 | grep -v "^secret = " | sed 's/^/    /' || true
python3 - <<'PY' 2>&1 | sed 's/^/    /'
import gi
gi.require_version('Secret', '1')
from gi.repository import Secret
schema = Secret.Schema.new("dev.noctalia.Secret", Secret.SchemaFlags.NONE,
    {"application": Secret.SchemaAttributeType.STRING, "version": Secret.SchemaAttributeType.STRING,
     "name": Secret.SchemaAttributeType.STRING, "owner": Secret.SchemaAttributeType.STRING,
     "scope": Secret.SchemaAttributeType.STRING})
attrs = {"application":"noctalia","version":"1","name":"refresh-token","owner":"perso","scope":"calendar"}
items = Secret.password_search_sync(schema, attrs, Secret.SearchFlags.ALL, None)
print(f"libsecret search dev.noctalia.Secret: {len(items) if items else 0} item(s)")
PY

info "Done. Next: logout/login or reboot, then:"
echo "  journalctl --user -n 50 | grep -i keyring"
echo "  tail -n 50 ~/.cache/noctalia/noctalia.log | grep -i calendar"
echo "  # should show storage unlocked, no 'locked or access was denied'"
echo "Backups: $keyring_dir/*.bak.$timestamp and /etc/pam.d/login.bak.$timestamp (if used)"
