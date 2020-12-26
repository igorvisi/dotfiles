# (Old) Étapes de l'installation d'Arch Linux

Ce n'est pas un script ! Ceci me permet de me rappeler certaines étapes !

## 1. Partitionnement

Test si on est sur UEFI ou BIOS ?

```shell
    efivars on /sys/firmware/efi/efivars type efivars (rw,nosuid,nodev   noexec,relatime)
```

### Pour table de partition MBR

- **512Mo** pour **/boot**
  [si UEFI]

### Pour table de partition GPT

- **1Go** pour **/boot** en FAT32.
  Il faut qu’elle soit étiquetée en EF00 à sa création.
  Pour le swap, c’est la référence 8200.

### Pour les deux (la suite)

- **100%** Reste en **luks** -> **vg** :

1.  **RAM+1Go** pour swap -> **vg-swap**
2.  **~100Go** pour /var -> **vg-var**
3.  **~50Go** pour / -> **vg-root**
4.  **100%FREE** pour /home -> **vg-home**

```shell
# Ecraser les données
dd if=/dev/zero of=/dev/sda2 bs=52M

cryptsetup luksFormat --cipher twofish-xts-plain64 --key-size 512  --hash sha512 --iter-time 2000 /dev/sda2

crypsetup luksOpen /dev/sda2 luks

# Remplir la partition cryptée avec des données zero
dd if=/dev/zero of=/dev/mapper/luks status=progress

# Lvm
vgcreate vg /dev/mapper/luks
lvcreate -n swap -L $taille vg # taille peut-être 10g par exemple
lvcreate -n root -L $taille vg
lvcreate -n var -L $taille vg
lvcreate -n home -l 100%FREE vg # 100% de l'espace restant

# Swap
mkswap /dev/mapper/vg-swap
swapon /dev/mapper/vg-swap

# Formatage
mkfs.ext4 /dev/mapper/vg-root
mkfs.ext4 /dev/mapper/vg-home
mkfs.ext4 /dev/mapper/vg-var
```

## 2. Téléchargement d'Archlinux Boostrap

```shell
cd /tmp/
wget https://archlinux/iso/latest/...archlinux-boostrap...
```

## 3. Chroot dans l'environnement Arch Boostrap

```shell
# Décompresser
tar xzf /tmp/archlinux-boostrap.. /tmp
# Chrooter
/tmp/root.x86_64/bin/arch-chroot /tmp/root.x86_64

# Montage
mount /dev/mapper/vg-root /mnt
mkdir /mnt/{var,home}
mount /dev/mapper/vg-var /mnt/var
mount /dev/mapper/vg-home /mnt/home
```

## 4. Installation de logiciels de base

```shell
 # Installation système de base
 pacstrap /mnt base base-devel neovim git grub zsh sudo powertop go nodejs npm
 # /etc/fstab pour lister les partitions
 genfstab -U -p /mnt >> /mnt/etc/fstab
 # chroot dans le nouveau système
 arch-chroot /mnt /bin/zsh
```

## 5. Dans le nouveau système configuration

```shell
  nvim /etc/vconsole.conf
  # Ajouter
    ## KEYMAP=fr-latin9
    ## FONT=lat9w-16

  nvim /etc/locale.conf
  # Ajouter
    ## LANG=en_US.UTF-8
    ## LANGUAGE="en_US:fr_FR"
    ## LC_COLLATE=C
  nvim /etc/locale-gen
    ## Décommenter fr_FR.UTF-8 et en_US.UTF-8 "
  locale-gen
  export LANG=en_US.UTF-8
  nvim /etc/default/locale
  # Ajouter
    ## LL_ALL=en_US.UTF-8


  # Nom de la machine machine
  nvim /etc/hostname

  # Date time machine
  ln -sf /usr/share/zoneinfo/Africa/Kinshasa /etc/localtime
  hwclock --systohc --utc

  # Ajouter dans /etc/mkinitcpio.conf
  nvim /etc/mkinitcpio.conf
   ## HOOKS=(base udev autodetect modconf block keyboard keymap consolefonts encrypt lvm2 filesystems resume fsck)
  mkinitcpio -p linux
  # Activer l'hibernation
  nvim /etc/default/grub
   ## GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda2:root resume=/dev/mapper/v-swap
   ## GRUB_ENABLE_CRYPTODISK="y
  grub-mkconfig -o /boot/grub/grub.cfg
```

## 6. Installation grub

- Si BIOS

```shell
grub-install --no-floppy --recheck /dev/sda
```

- Si UEFI

```shell
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck mkdir /boot/EFI/boot cp /boot/EFI/arch_grub/grubx64.efi /boot/EFI/boot/bootx64.efi`
```

## 7. Utilisateur

```shell
# changer mot de passe du root
passwd root

# création utilisateur administrateur
useradd  -m  -G  autologin,nopasswdlogin,wheel,input,vboxsf,vboxusers -c 'Nom complet de l’utilisateur' -s  /bin/zsh  nom-de-l’utilisateur
passwd nom-de-l’utilisateur

# décommenter wheel dans sudoers
nvim /etc/sudoers

# Laptop Mode and swapiness
file /etc/sysctl.d/laptop.conf
vm.laptop_mode = 5
cat /etc/sysctl.d/99-sysctl.conf
vm.swappiness=10

# Action comme fermer le couvercle ou appuyer sur le bouton power
vim /etc/systemd/login.conf
HandlePowerKey=suspend
HandleLidSwithc=suspend
HandleHibernateKey=hibernate
HandleLidSwitch=suspend

vim /etc/tmpfiles.d/start.conf
w /sys/power/pm_async - - - - 0
w /sys/power/image_size - - - - 8589934592

# se connecter en tant nom-de-utilisateur
su nom-de-utilsateur
# Changer le shell par défaut pour zsh ( déja fait au dessus juste pour vérifier)
chsh -s /bin/zsh
```

## 8. Dotfiles

### installation de dotfiles

```bash
git clone --depth=1 https://github.com/igorvisi/dotfiles ~/.dotfiles
chmod +x install && ./install
```

### installation de YAY pour gérer les dépots non officiels

```bash
git clone --depth=1 https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

### installation environnement de bureau et nextcloud-desktop

```bash
yay -S nextcloud-client termite cinnamon firefox chromium lightdm lightdm-gtk-greeter
systemctl enable lightdm
```

### récupération des données sur nextcloud

exec post-install.sh

### dernières rétouches

- ForwardToSyslog=yes on /etc/systemd/journald.conf
- sudo /bin/sh -c "echo 0 > /sys/power/pm_async"
- Autologin and no password

/etc/lightdm/lightdm.conf
[Seat:*]
...
autologin-user=nom-user
autologin-user-timeout=0
autologin-session=session
pam-autologin-service=lightdm-autologin
user-sexion=startx

/etc/pam.d/lightdm

### %PAM-1.O

auth sufficient pam_succeed_if.so user ingroup nopasswdlogin
auth include system-login
...

### Activez les services ci-après

```bash
systemctl enable syslog-ng  #gestion des fichiers d’enregistrement d’activité
systemctl enable NetworkManager
systemctl enable vboxservice
systemctl enable cronie  # pour les tâches récurrentes
systemctl enable avahi-daemon  # dépendance de Cups
systemctl enable avahi-dnsconfd  # utre dépendance de Cups
systemctl enable org.cups.cupsd  # cups pour les imprimantes
systemctl enable bluetooth  # uniquement si on a du matériel bluetooth
systemctl enable powertop # powertop
systemctl enable tlp.service
systemctl enable tlp-sleep.service
```

# Rappel

### Récupérer un système endommagé avec chroot

```shell
sudo mount --bind /dev /mnt/dev; sudo mount -t proc /proc /mnt/proc; sudo mount --bind /run /mnt/run; sudo mount -t sysfs /sys /mnt/sys; sudo chroot /mnt/ zsh
# connexion internet
net-setup eth0
sudo cp /etc/resolv.conf /mnt/resolv.conf*
```

### Afficher les dossiers en premier sur dialogue

gsettings set org.gtk.Settings.FileChooser sort-directories-first true

### Prendre en charge mon terminal client

```bash
tic -x ~/.dotfiles/termite/termite.info #Si en remote serveur via SSH
```

### Dual boot avec windows problème de temps local ou UTC

```bash
# locale
timedatectl set-local-rtc 1 --adjust-system-clock
# UTC
timedatectl set-local-rtc 0 --adjust-system-clock
```

### Problème hibernation de windows en dual boot avec linux

```bash
sudo ntfsfix /dev/sdb1
```

### Get exa, modern ls

wget -c https://github.com/ogham/exa/releases/download/v0.8.0/exa-linux-x86_64-0.8.0.zip
unzip exa-linux-x86_64-0.8.0.zip
mv exa-linux-x86_64 /usr/local/bin/exa

### Génération des clés SSH et GPG

```bash
ssh-keygen -o -t rsa -b 4096 -C "mail@mail.com"
ssh-keygen -o -t ed25519 -C "mail@mail.com"
```


### Remove cache
```bash
paccache -rk 1  # Laisser seulement a dernière version en cache
paccache -ruk0  # Enlever tous les logiciels non installés

```


###

mkdir /etc/nginx/sites-avaible

