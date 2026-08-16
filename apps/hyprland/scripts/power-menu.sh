#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
launcher="$script_dir/launcher.sh"

choose() {
    "$launcher" --dmenu --placeholder "$1"
}

confirm() {
    local prompt=$1
    local answer

    answer=$(printf 'Non\nOui\n' | choose "$prompt")
    [[ "$answer" == "Oui" ]]
}

choice=$(printf '%s\n' \
    "Verrouiller" \
    "Mettre en veille" \
    "Se déconnecter" \
    "Redémarrer" \
    "Éteindre" | choose "Alimentation")

case "$choice" in
    "Verrouiller")
        exec "$script_dir/lock.sh"
        ;;
    "Mettre en veille")
        exec systemctl suspend
        ;;
    "Se déconnecter")
        exec uwsm stop
        ;;
    "Redémarrer")
        confirm "Confirmer le redémarrage ?" && exec systemctl reboot
        ;;
    "Éteindre")
        confirm "Confirmer l'arrêt ?" && exec systemctl poweroff
        ;;
esac
