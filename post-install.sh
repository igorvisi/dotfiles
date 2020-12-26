#!/bin/zsh

# For ArchLinux and based distro in my workstation

echo "###########"
echo "Source zsh"
echo "###########"
source ~/.zshrc

echo "#######################"
echo "Adding $USER to groups"
echo "#######################"
sudo usermod -aG autologin,wheel,input,vboxsf,sambashare,vboxusers,docker $USER

echo "#####################"
echo "Copying conf to /etc"
echo "#####################"
sudo cp -r etc /


$read -n 1 -p "Do you want to Restore from a backup? (y/N)" REPLY
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "###################################"
	echo "Restore backups from external disk"
	echo "###################################"
	$HOME/bin/restore
fi

ln -sf $EXTRADIR/keys/ssh ~/.ssh
ln -sf $EXTRADIR/keys/gnupg ~/.gnupg
ln -sf $EXTRADIR/Media/Pics $PICTUREDIR
ln -sf $EXTRADIR/electrum ~/.electrum
gpg --export-ssh-key $GPGKEY >> ~/.ssh/authorized_keys

echo "############################"
echo "Install packages from Pacman"
echo "############################"

for packageOff in $(cat ~/.extra/cloud.igorvisi.com/packages/pacman.txt); do sudo pacman -S $packageOff --needed --noconfirm ; done

echo "################################"
echo "Install packages from AUR perso"
echo "###############################"
for packageAUR in $(cat ~/.extra/cloud.igorvisi.com/packages/aur.txt); do pacman -S $packageAUR --needed ; done

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


echo "###########################"
echo "Enable and starting service"
echo "###########################"


systemctl --user enable --now syncthing.service
systemctl --user enable --now classifier.timer
systemctl --user enable --now pacsave.timer


