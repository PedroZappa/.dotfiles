# Arch Linux Manual Install

____

## Get on a Network

* Check IP Address Information

```sh
ip addr show
```

* Connect to WIFI Network (Get IP)

```sh
iwctl
```

> Drops you into `iwctl`'s prompt

* List all available networks (in Ex.: `wlon0`)

```sh
[iwd]# station wlon0 get-networks
```

> `Ctrl+C` out of `iwctl`

* Connect to chosen `<network>`

```sh
iwctl --passphrase "networkPassphrase" station wlon0 connect <network>
```

____

## Setup Drives

* Check local drives information

```sh
lsblk
```

### Setup Partitions

* Open chosen device with `fdisk` partitioniong utility (Ex.: `nvme0n1`)

```sh
fdisk /dev/nvme0n1
```

> Gives `Command (m for help):` promnpt.

* Print partition layout

```sh
p
```

* Create empty partition table

```sh
g
```

* Create new partition (`boot`)

```sh
n
```

> Set: Default, Default, +1G
> Accept: y

* Create new partition (`EFI`)

```sh
n
```

> Set: Default, Default, +1G
> Accept: y

* Create new partition (`/`)

```sh
n
```

> Set: Default, Default, Default
> Accept: y

* Save and exit `fdisk`

```sh
w
```

### Format Partitions

* Format `boot` partition

```sh
mkfs.fat -F32 /dev/nvme0n1p1
```

* Format `EFI` partition

```sh
mkfs.ext4 /dev/nvme0n1p2
```

* Format `/` partition

```sh
mkfs.ext4 /dev/nvme0n1p3
```

### Install Kernel Modules

* Get Advanced Storage Configuration support (to be safe)

```sh
modprobe dm_mod
```

### Mount Partitions

#### Handle `/` (root)

* Mount `/` (root)

```sh
mount /dev/nvme0n1p3 /mnt
```

#### Handle `boot`

* Create `/mnt/boot/` directory

```sh
mkdir /mnt/boot
```

* Mount `boot`

```sh
mount /dev/nvme0n1p2 /mnt/boot
```

### Install Minimal Required Packages

```sh
pacstrap -i /mnt base
```

### Generate `fstab` file

> Tell the file system filesystems to mount

```sh
genfstab -U /mnt >> /mnt/etc/fstab
```

* To check the current filesystems

```sh
cat /mnt/etc/fstab
```

____

## Log into Arch Linux installation

```sh
arch-chroot /mnt
```

### Set root password

```sh
passwd
```

### Create user (ex.: `zedro`) & set user password

```sh
useradd -m -g users -G wheel zedro
passwd zedro
```

### Get User Packages

```sh
pacman -S base-devel dosfstools grub efibootmgr gnome gnome-tweaks mtools vim git firefox networkmanager openssh sudo
```

### Get Linux Kernels (bleeding edge & lts)

```sh
pacman -S linux linux-headers linux-lts linux-lts-headers
```

### Get Optional Firmware (Recommended)

```sh
pacman -S linux-firmware
```

### Setup Video Card Driver (Ex.: `NVidia`)

```sh
pacman -S nvidia nvidia-utils nvidia-lts
```

### Generate Kernel Utils

```sh
mkinitcpio -p linux     # for bleeding-edge kernel
mkinitcpio -p linux-lts # for lts kernel
```

### Set Locale Information

```sh
vim /etc/locale.gen
```

> Uncomment the desired local UTF-8 option

#### Generate Selected Locale

```sh
locale-gen
```

### Setup `EFI` Partition

```sh
mkdir /boot/EFI
mouunt /dev/nvme0n1p1 /boot/EFI
```

### Setup `GRUB`

#### Install `GRUB`

```sh
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
```

#### Setup `boot` Directory

```sh
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
```

#### Generate `GRUB` configuration file

```sh
grub-mkconfig -o /boot/grub/grub.cfg
```

____

## Enable Services

### Enable `OpenSSH`

```sh
systemctl enable sshd
```

### Enable `gdm`

```sh
systemctl enable gdm
```

### Enable `Network Manager`

```sh
systemctl enable NetworkManager
```

## Finish & Reboot

```sh
exit      # Leave chroot
umount -a # Unmount
reboot    # Reboot system
```
