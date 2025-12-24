Set-ExecutionPolicy Bypass -Scope Process -Force

# Installer Chocolatey si non présent
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installation de Chocolatey..."
    [System.Net.ServicePointManager]::SecurityProtocol = 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Write-Host "Installation des logiciels..."

$packages = @(
    "1password"
    "1password8"
    "androidstudio"
    "bitwarden"
    "chocolatey"
    "chocolatey-compatibility.extension"
    "chocolatey-core.extension"
    "chocolatey-dotnetfx.extension"
    "chocolatey-os-dependency.extension"
    "chocolatey-windowsupdate.extension"
    "dotnetfx"
    "flutter"
    "localsend"
    "mobaxterm"
    "naps2"
    "netbird"
    "obsidian"
    "postman"
    "qbittorrent"
    "scrcpy"
    "sumatrapdf"
    "tableplus"
    "tailscale"
    "telegram"
    "thunderbird"
    "wezterm.install"
    "winscp"
    "wireguard"
    "zoom"
)

foreach ($pkg in $packages) {
    Write-Host "Installation de $pkg ..."
    choco install $pkg -y --ignore-checksums
}

Write-Host "Installation terminée."
