# Étapes de l'installation d'Arch Linux

Ce n'est pas un script ! Ceci me permet de me rappeler certaines étapes !

## 1. Partitionnement

Table de partition MBR

- **512Mo** pour **/boot**
  [si UEFI]
  Table de partition GPT
- **1Go** pour **/boot** en FAT32.
  Il faut qu’elle soit étiquetée en EF00 à sa création.
  Pour le swap, c’est la référence 8200.

* **100%** Reste en **luks** -> **vg** :

1.  **RAM+1Go** pour swap -> **vg-swap**
2.  **~100Go** pour /var -> **vg-var**
3.  **~50Go** pour / -> **vg-root**
4.  **100%FREE** pour /home -> **vg-home**

```shell
# Ecraser les données
dd if=/dev/urandom of=/dev/sda2

cryptsetup luksFormat --cipher twofish-xts-plain64 --key-size 512  --hash sha512 --iter-time 2000 /dev/sda2

crypsetup luksOpen /dev/sda2 luks

# Remplir la partition cryptée avec des données aléatoires
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

# Montage
mount /dev/mapper/vg-root /mnt
cat /dev/zero > /mnt/zeros ;sync ; rm /mnt/zero
mkdir /mnt/{var,home}
mount /dev/mapper/vg-var /mnt/var
cat /dev/zero > /mnt/var/zeros ;sync ; rm /mnt/var/zeros
mount /dev/mapper/vg-home /mnt/home
cat /dev/zero > /mnt/home/zeros ;sync ; rm /mnt/home/zeros
```

## 2. Téléchargement d'Archlinux Boostrap

```shell
cd /tmp/
wget https://archlinux/iso/latest/... archlinux-boostrap..
```

## 3. Chroot dans l'environnement Arch Boostrap

```shell
# Décompresser
tar xzf /tmp/archlinux-boostrap.. /tmp
# Chrooter
/tmp/root.x86_64/bin/arch-chroot /tmp/root.x86_64
```

## 4. Installation de logiciels de base

```shell
 # Installation système de base
 pacstrap /mnt base base-devel nvim git openssh grub zsh sudo powertop
 # /etc/fstab pour lister les partitions
 genfstab -U -p /mnt >> /mnt/etc/fstab
 # chroot dans le nouveau système
 arch-chroot /mnt /bin/zsh
```

# 5. Dans le nouveau système configuration

```shell
  nvim /etc/vconsole.conf
  # Ajouter :
    KEYMAP=fr-latin9
    FONT=lat9w-16

  nvim /etc/locale.conf
  # Ajouter :
  # LANG=fr_FR.UTF-8
  # LC_COLLATE=C
  locale-gen
  export LANG=fr_FR.UTF-8

  # Name machine
  nvim /etc/hostname

  # Date time machine
  ln -sf /usr/share/zoneinfo/Africa/Kinshasa /etc/localtime
  hwclock --systohc --utc

  # Ajouter dans /etc/mkinitcpio.conf
  nvim /etc/mkinitcpio.conf
  # HOOKS=(base udev autodetect modconf block keyboard keymap consolefonts encrypt lvm2 filesystems resume fsck)
  mkinitcpio -p linux
  # Activer l'hibernation
  nvim /etc/default/grub
  # GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda2:luks:allow-discards resume=UUID=8b9c73e9-d514-example-vg-swap-uuid"
  grub-mkconfig -o /boot/grub/grub.cfg
```

## 6. Installation grub

- Teste si on est sur UEFI ou BIOS ?

```shell
    efivars on /sys/firmware/efi/efivars type efivars (rw,nosuid,nodev   noexec,relatime)
```

- Si UEFI

```shell
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck mkdir /boot/EFI/boot cp /boot/EFI/arch_grub/grubx64.efi /boot/EFI/boot/bootx64.efi`
```

- Si BIOS

```shell
grub-install --no-floppy --recheck /dev/sda
```

## 7. Utilisateur

````shell
# changer mot de passe du root
passwd root

# création utilisateur administrateur
useradd  -m  -G  autologin,nopasswdlogin,wheel -c 'Nom complet de l’utilisateur' -s  /bin/zsh  nom-de-l’utilisateur
passwd nom-de-l’utilisateur

# décommenter wheel dans sudoers
nvim /etc/sudoers

# Powertop
file /etc/systemd/system/powertop.service
[Unit]
Description=Powertop tunings
[Service]
Type=oneshot
ExecStart=/usr/bin/powertop --auto-tune
[Install]
WantedBy=multi-user.target

# Vérouiller après suspend
file /etc/systemd/system/wakelock.service
[Unit]
Description= Lock the screen on resume after suspend
[Service]
User=visi
Type=forking
Environment=DISPLAY=:0
ExecStart=/usr/bin/sh -c "/home/visi/Bin/lock"
[Install]
WantedBy=suspend.target

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

```bash
# se connecter en tant nom-de-utilisateur
su nom-de-utilsateur
# Changer le shell par défaut pour zsh
chsh -s /bin/zsh
````

## 8. Dotfiles

### installation de dotfiles

```bash
git clone https://github.com/igorvisi/dotfiles ~/.dotfiles
cd ~/.dotfiles && git submodule init && git submodule update
cp dotbot/tools/git-submodule/install .
chmod +x install && ./install
```

### installation de nextcloud(owncloud), gpg et enfcs

### récupération des données sur nextcloud

### importation clés SSH et GPG

### récuperer les configuration pacman.conf, crontab, la liste de logiciels et packages

### installation des logiciels avec yay, vscode et npm

```bash
cat .extra/packages/yay.txt | xargs yay -Su
cat .extra/packages/vscode.tx | xargs code --install-extension
cat .extra/packages/yarn.txt | xargs n2,5pm -g i
```

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
#%PAM-1.O
auth sufficient pam_succeed_if.so user ingroup nopasswdlogin
auth include system-login
...

### Activez les services ci-après:

```shell
systemctl enable syslog-ng  #gestion des fichiers d’enregistrement d’activité
systemctl enable networkManager
systemctl enable lightdm.service
systemctl enable vboxservice
systemctl enable cronie  # pour les tâches récurrentes
systemctl enable avahi-daemon  # dépendance de Cups
systemctl enable avahi-dnsconfd  # utre dépendance de Cups
systemctl enable org.cups.cupsd  # cups pour les imprimantes
systemctl enable bluetooth  # uniquement si on a du matériel bluetooth
systemctl enable powertop.service # powertop
```

## Rappel

### Récupérer un système endommagé avec chroot

```shell
sudo mount --bind /dev /mnt/dev
sudo mount -t proc /proc /mnt/proc
sudo mount --bind /run /mnt/run
sudo mount -t sysfs /sys /mnt/sys
net-setup eth0 # connexion internet
sudo cp /etc/resolv.conf /mnt/resolv.conf*
sudo chroot /mnt/ zsh
```

### Renouvellement des clés GPG

```shell
gpg --decrypt gpg_keys.tar.xz.gpg gpg_keys.tar.xz
tar Jxvf gpg_keys.tar.xz
gpg --import D4444496.priv.asc
gpg --edit-key D4444496

gpg --export --armor D4444496 > D4444496.pub.asc
gpg --export-secret-keys --armor D4444496 > D4444496.priv.asc
gpg --export-secret-subkeys --armor D4444496 > D4444496.sub_priv.asc
gpg --output D4444496.rev.asc --gen-revoke D4444496

gpg --delete-secret-key D4444496
gpg --import D4444496.sub_priv.asc
tar Jcvf gpg_keys.tar.xz D4444496.*
gpg -c gpg_keys.tar.xz
srm D4444496.* gpg_keys.tar.xz
```
