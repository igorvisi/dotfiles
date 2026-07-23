Set-ExecutionPolicy Bypass -Scope Process -Force

function Install-IfApproved {
    param(
        [string]$Description,
        [string]$Command
    )

    $choice = Read-Host "Do you want to install $Description? [y/N]"
    switch ($choice) {
        { $_ -match '^[yY]' } {
            Write-Host "Installing $Description..." -ForegroundColor Green
            Invoke-Expression $Command
        }
        default {
            Write-Host "Skipping $Description." -ForegroundColor Red
        }
    }
}

# Installer Chocolatey si non présent
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    [System.Net.ServicePointManager]::SecurityProtocol = 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# GUI Applications
Install-IfApproved "VSCode (code editor)" "choco install vscode -y"
Install-IfApproved "Zed (code editor)" "choco install zed -y"
Install-IfApproved "1Password (password manager)" "choco install 1password -y"
Install-IfApproved "Brave browser" "choco install brave -y"
Install-IfApproved "Spotify" "choco install spotify -y"
Install-IfApproved "Obsidian (note-taking app)" "choco install obsidian -y"
Install-IfApproved "Telegram (messaging app)" "choco install telegram -y"
Install-IfApproved "Thunderbird (email client)" "choco install thunderbird -y"
Install-IfApproved "VLC (media player)" "choco install vlc -y"
Install-IfApproved "KeePassXC (password manager)" "choco install keepassxc -y"
Install-IfApproved "LocalSend (local file sharing tool)" "choco install localsend -y"
Install-IfApproved "TablePlus (database management tool)" "choco install tableplus -y"
Install-IfApproved "WezTerm (terminal emulator)" "choco install wezterm -y"

# Fonts
Install-IfApproved "JetBrains Mono Nerd Fonts" "
choco install jetbrainsmono-nf -y
"
Install-IfApproved "Maple Mono NF (programming font)" "
choco install maple-mono-nf -y
"

Write-Host "Installation completed." -ForegroundColor Green
