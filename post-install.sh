#!/bin/zsh

# For ArchLinux and based distro in my workstation

echo "###########"
echo "Source zsh"
echo "###########"
source ~/.zshrc

echo "#######################"
echo "Adding $USER to groups"
echo "#######################"
sudo usermod -aG autologin,nopasswdlogin,wheel,input,vboxsf,sambashare,vboxusers,docker $USER

echo "#####################"
echo "Copying conf to /etc"
echo "#####################"
sudo cp -r etc /

echo "###################################"
echo "Restore backups from external disk"
echo "###################################"
$HOME/bin/restore \
&& (
ln -sf ~/.extra/cloud.igorvisi.com/keys/ssh ~/.ssh
ln -sf ~/.extra/cloud.igorvisi.com/keys/gnupg ~/.gnupg
ln -sf ~/.extra/cloud.igorvisi.com/Media/Pics $PICTUREDIR
ln -sf ~/.extra/cloud.igorvisi.com/electrum ~/.electrum
gpg --export-ssh-key $GPGKEY >> ~/.ssh/authorized_keys
)

echo "############################"
echo "Install packages from Pacman"
echo "############################"

for packageOff in $(cat ~/.extra/cloud.igorvisi.com/packages/pacman.txt); do sudo pacman -S $packageOff --needed --noconfirm ; done

echo "##########################"
echo "Install packages from AUR"
echo "##########################"
for packageAUR in $(cat ~/.extra/cloud.igorvisi.com/packages/aur.txt); do yay -S $packageAUR --needed ; done

read -n 1 -p "Do you want to install vscode extensions? (y/N)" REPLY
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "###################################"
	echo "Install visual studio code packages"
	echo "###################################"
	for extension in $( cat ~/.extra/cloud.igorvisi.com/packages/vscode.txt ); do code --install-extension $extension ; done
fi

read -n 1 -p "Do you want to install npm packages? (y/N)" REPLY
echo
if [[ $REPLY =~ ^[Yy] ]]; then
	echo "###########################"
	echo "Install npm global packages"
	echo "############################"
	for package in $( cat ~/.extra/cloud.igorvisi.com/packages/npm.txt ); do npm install -g $package ; done
fi


read -n 1 -p "Do you want to restore previous /org/ dconf? (y/N)" REPLY
echo
if [[ $REPLY =~ ^[Yy] ]]; then
	echo "###########################"
	echo "Restoring previous /org/dconf"
	echo "############################"
	dconf load /org/ < ~/.extra/cloud.igorvisi.com/conf/dconf/config.ini
fi

read -n 1 -p "Do you want to restore previous cinnamon conf? (y/N)" REPLY
echo
if [[ $REPLY =~ ^[Yy] ]]; then
	echo "###########################"
	echo "Restoring previous cinnamon conf"
	echo "############################"
	dconf load /org/cinnamon/ < ~/.extra/cloud.igorvisi.com/conf/cinnamon/config.ini
fi

read -n 1 -p "Do you want to restore previous gnome conf? (y/N)" REPLY
echo
if [[ $REPLY =~ ^[Yy] ]]; then
	echo "###########################"
	echo "Restoring previous gnome conf"
	echo "############################"
	dconf load /org/gnome/ < ~/.extra/cloud.igorvisi.com/conf/gnome/config.ini
fi


echo "###################################"
echo "Configuring GTK file chooser dialog"
echo "###################################"
gsettings set org.gtk.Settings.FileChooser sort-directories-first true

echo "###########################"
echo "Enable and starting service"
echo "###########################"


systemctl --user enable --now syncthing.service
systemctl --user enable --now classifier.timer
systemctl --user enable --now dconf-save.timer
systemctl --user enable --now pacsave.timer


echo "###################################"
echo "Configuring GTK file chooser dialog"
echo "###################################"
gsettings set org.gtk.Settings.FileChooser sort-directories-first true




