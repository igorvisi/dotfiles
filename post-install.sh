#!/bin/zsh

# For ArchLinux and based distro in my workstation

echo "###########"
echo "Source zsh"
echo "###########"
source ~/.zshrc

echo "#######################"
echo "Adding $USER to groups"
echo "#######################"
sudo usermod -aG autologin,nopasswdlogin,wheel,input,vboxsf,vboxusers $USER

echo "#####################"
echo "Copying conf to /etc"
echo "#####################"
sudo cp -r etc /

echo "###################################"
echo "Restore backups from external disk"
echo "###################################"
$HOME/bin/restore \
&& (
ln -sf ~/.extra/keys/gnupg ~/.gnupg
ln -sf ~/.extra/Media/Pics $PICTUREDIR
ln -sf ~/.extra/electrum ~/.electrum
gpg --export-ssh-key $GPGKEY >> ~/.ssh/authorized_keys
)

echo "############################"
echo "Install packages from Pacman"
echo "############################"

for packageOff in $(cat ~/.extra/packages/pacman.txt); do sudo pacman -S $packageOff --needed --noconfirm ; done

echo "##########################"
echo "Install packages from AUR"
echo "##########################"
for packageAUR in $(cat ~/.extra/packages/aur.txt); do yay -S $packageAUR --needed ; done

read -n 1 -p "Do you want to install vscode extensions? (y/N)" REPLY
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "###################################"
	echo "Install visual studio code packages"
	echo "###################################"
	for extension in $( cat ~/.extra/packages/vscode.txt ); do code --install-extension $extension ; done
fi

read -n 1 -p "Do you want to install npm packages? (y/N)" REPLY
echo
if [[ $REPLY =~ ^[Yy] ]]; then
	echo "###########################"
	echo "Install npm global packages"
	echo "############################"
	for package in $( cat ~/.extra/packages/npm.txt ); do npm install -g $package ; done
fi

echo "###################################"
echo "Configuring GTK file chooser dialog"
echo "###################################"
gsettings set org.gtk.Settings.FileChooser sort-directories-first true

echo "###########################"
echo "Enable and starting service"
echo "###########################"

sudo systemctl enable --now usbguard.service
sudo systemctl enable --now usbguard-dbus.service

systemctl --user enable --now verdaccio.service
systemctl --user enable --now classifier.timer
systemctl --user enable --now pacsave.timer
systemctl --user enable --now urlwatch.timer
