# 📖 Guide d'Installation ArchFusion OS

Bienvenue dans le guide d'installation complet d'ArchFusion OS ! Ce guide vous accompagnera étape par étape pour installer votre nouvelle distribution Linux.

## 📋 Table des Matières

- [Prérequis](#-prérequis)
- [Téléchargement](#-téléchargement)
- [Création du Média d'Installation](#-création-du-média-dinstallation)
- [Démarrage depuis l'ISO](#-démarrage-depuis-liso)
- [Installation Graphique](#-installation-graphique)
- [Installation en Ligne de Commande](#-installation-en-ligne-de-commande)
- [Configuration Post-Installation](#-configuration-post-installation)
- [Dépannage](#-dépannage)
- [Support](#-support)

## 🔧 Prérequis

### Configuration Matérielle Minimale
- **Processeur** : x86_64 (64-bit) compatible
- **RAM** : 2 GB minimum (4 GB recommandé)
- **Stockage** : 20 GB d'espace libre minimum (50 GB recommandé)
- **Carte graphique** : Compatible avec les pilotes open-source ou propriétaires
- **Connexion Internet** : Recommandée pour les mises à jour

### Configuration Matérielle Recommandée
- **Processeur** : Intel Core i5 / AMD Ryzen 5 ou supérieur
- **RAM** : 8 GB ou plus
- **Stockage** : SSD de 100 GB ou plus
- **Carte graphique** : Dédiée avec 2 GB VRAM ou plus

## 📥 Téléchargement

### 1. Télécharger l'ISO
Téléchargez la dernière version d'ArchFusion OS depuis notre dépôt GitHub :

```bash
# Via wget
wget https://github.com/JimmyRamsamynaick/ArchFusion/releases/latest/download/ArchFusion-OS.iso

# Via curl
curl -L -o ArchFusion-OS.iso https://github.com/JimmyRamsamynaick/ArchFusion/releases/latest/download/ArchFusion-OS.iso
```

### 2. Vérifier l'Intégrité
Téléchargez également les fichiers de vérification :

```bash
# Télécharger les checksums
wget https://github.com/JimmyRamsamynaick/ArchFusion/releases/latest/download/ArchFusion-OS.iso.sha256
wget https://github.com/JimmyRamsamynaick/ArchFusion/releases/latest/download/ArchFusion-OS.iso.md5

# Vérifier avec SHA256
sha256sum -c ArchFusion-OS.iso.sha256

# Vérifier avec MD5
md5sum -c ArchFusion-OS.iso.md5
```

## 💾 Création du Média d'Installation

### Option 1 : Clé USB (Recommandé)

#### Sur Linux
```bash
# Identifier votre clé USB
lsblk

# Créer la clé bootable (remplacez /dev/sdX par votre clé)
sudo dd if=ArchFusion-OS.iso of=/dev/sdX bs=4M status=progress && sync
```

#### Sur macOS
```bash
# Identifier votre clé USB
diskutil list

# Démonter la clé (remplacez diskN par votre clé)
diskutil unmountDisk /dev/diskN

# Créer la clé bootable
sudo dd if=ArchFusion-OS.iso of=/dev/rdiskN bs=4m && sync
```

#### Sur Windows
Utilisez un outil comme **Rufus** ou **Balena Etcher** :
1. Téléchargez [Rufus](https://rufus.ie/) ou [Balena Etcher](https://www.balena.io/etcher/)
2. Sélectionnez votre clé USB
3. Sélectionnez l'ISO ArchFusion OS
4. Cliquez sur "Démarrer" ou "Flash"

### Option 2 : DVD
Gravez l'ISO sur un DVD en utilisant votre logiciel de gravure préféré.

## 🚀 Démarrage depuis l'ISO

### 1. Configuration du BIOS/UEFI
1. Redémarrez votre ordinateur
2. Appuyez sur `F2`, `F12`, `Del` ou `Esc` (selon votre carte mère) pour accéder au BIOS/UEFI
3. Activez le démarrage depuis USB/DVD
4. Désactivez le Secure Boot si nécessaire
5. Sauvegardez et redémarrez

### 2. Menu de Démarrage
Au démarrage, vous verrez le menu ArchFusion OS avec les options suivantes :
- **ArchFusion OS - Installation** (par défaut)
- **ArchFusion OS - Mode Live**
- **Outils de Diagnostic**

## 🖥️ Installation Graphique

L'installation graphique est la méthode recommandée pour les utilisateurs débutants.

### 1. Lancement de l'Installateur
```bash
# L'installateur se lance automatiquement, ou manuellement :
python3 /archfusion/scripts/install/gui-installer.py
```

### 2. Étapes d'Installation

#### Étape 1 : Bienvenue
- Sélectionnez votre langue
- Lisez les informations de bienvenue
- Cliquez sur "Suivant"

#### Étape 2 : Configuration Clavier
- Choisissez votre disposition clavier
- Testez la saisie
- Cliquez sur "Suivant"

#### Étape 3 : Connexion Réseau
- Configurez votre connexion Internet (Wi-Fi ou Ethernet)
- Testez la connectivité
- Cliquez sur "Suivant"

#### Étape 4 : Partitionnement
Choisissez votre méthode de partitionnement :

**Option A : Automatique (Recommandé)**
- Sélectionnez le disque cible
- Choisissez "Effacer le disque et installer ArchFusion OS"
- L'installateur créera automatiquement les partitions

**Option B : Manuel**
- Créez manuellement vos partitions :
  - `/boot/efi` : 512 MB (FAT32) pour UEFI
  - `/` : 20+ GB (ext4) pour le système
  - `/home` : Espace restant (ext4) pour les données utilisateur
  - `swap` : 2-8 GB selon votre RAM

#### Étape 5 : Compte Utilisateur
- Créez votre compte utilisateur principal
- Définissez un mot de passe fort
- Configurez le mot de passe root (optionnel)

#### Étape 6 : Configuration Système
- Choisissez votre fuseau horaire
- Sélectionnez les logiciels à installer
- Configurez les services système

#### Étape 7 : Installation
- Vérifiez le résumé de l'installation
- Cliquez sur "Installer"
- Attendez la fin de l'installation (15-30 minutes)

#### Étape 8 : Finalisation
- Redémarrez le système
- Retirez le média d'installation
- Profitez d'ArchFusion OS !

## 💻 Installation en Ligne de Commande

Pour les utilisateurs avancés qui préfèrent l'installation en CLI.

### 1. Lancement de l'Installateur CLI
```bash
bash /archfusion/scripts/install/install.sh
```

### 2. Étapes d'Installation CLI

#### Préparation du Système
```bash
# Mise à jour de l'horloge système
timedatectl set-ntp true

# Vérification de la connectivité
ping -c 3 archlinux.org
```

#### Partitionnement Manuel
```bash
# Lister les disques
lsblk

# Partitionner avec fdisk (exemple pour /dev/sda)
fdisk /dev/sda

# Créer les partitions :
# /dev/sda1 : 512M (EFI System)
# /dev/sda2 : 20G+ (Linux filesystem)
# /dev/sda3 : Reste (Linux filesystem)
```

#### Formatage des Partitions
```bash
# Formater la partition EFI
mkfs.fat -F32 /dev/sda1

# Formater la partition root
mkfs.ext4 /dev/sda2

# Formater la partition home
mkfs.ext4 /dev/sda3
```

#### Montage des Partitions
```bash
# Monter la partition root
mount /dev/sda2 /mnt

# Créer les points de montage
mkdir -p /mnt/{boot/efi,home}

# Monter les autres partitions
mount /dev/sda1 /mnt/boot/efi
mount /dev/sda3 /mnt/home
```

#### Installation du Système de Base
```bash
# Installation des paquets de base
pacstrap /mnt base base-devel linux linux-firmware

# Génération du fstab
genfstab -U /mnt >> /mnt/etc/fstab
```

#### Configuration du Système
```bash
# Chroot dans le nouveau système
arch-chroot /mnt

# Configuration du fuseau horaire
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

# Configuration des locales
echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=fr_FR.UTF-8" > /etc/locale.conf

# Configuration du clavier
echo "KEYMAP=fr" > /etc/vconsole.conf

# Configuration du nom d'hôte
echo "archfusion" > /etc/hostname
```

#### Installation du Bootloader
```bash
# Installation de GRUB pour UEFI
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchFusion
grub-mkconfig -o /boot/grub/grub.cfg
```

#### Création de l'Utilisateur
```bash
# Définir le mot de passe root
passwd

# Créer un utilisateur
useradd -m -G wheel -s /bin/bash votre_nom_utilisateur
passwd votre_nom_utilisateur

# Activer sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
```

## ⚙️ Configuration Post-Installation

### 1. Première Connexion
Après le redémarrage, connectez-vous avec votre compte utilisateur.

### 2. Mise à Jour du Système
```bash
# Mise à jour complète
sudo pacman -Syu

# Installation des pilotes propriétaires (si nécessaire)
sudo pacman -S nvidia nvidia-utils  # Pour NVIDIA
# ou
sudo pacman -S xf86-video-amdgpu    # Pour AMD
```

### 3. Configuration de l'Environnement de Bureau
ArchFusion OS est livré avec KDE Plasma personnalisé :

```bash
# Démarrer le gestionnaire de connexion
sudo systemctl enable sddm
sudo systemctl start sddm
```

### 4. Installation de Logiciels Supplémentaires
```bash
# Navigateurs
sudo pacman -S firefox chromium

# Outils de développement
sudo pacman -S git vim code

# Multimédia
sudo pacman -S vlc gimp

# Outils système
sudo pacman -S htop neofetch
```

### 5. Configuration du Pare-feu
```bash
# Activer le pare-feu
sudo systemctl enable ufw
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

## 🔧 Dépannage

### Problèmes de Démarrage

#### L'ordinateur ne démarre pas depuis l'USB/DVD
- Vérifiez que le Secure Boot est désactivé
- Changez l'ordre de démarrage dans le BIOS
- Essayez un autre port USB
- Recréez le média d'installation

#### Écran noir au démarrage
- Ajoutez `nomodeset` aux paramètres du kernel
- Appuyez sur `e` dans GRUB et ajoutez `nomodeset` à la ligne linux

### Problèmes d'Installation

#### Erreur de partitionnement
- Vérifiez que le disque n'est pas monté
- Utilisez `umount` pour démonter les partitions
- Vérifiez l'espace disque disponible

#### Erreur de réseau
- Vérifiez votre connexion Internet
- Configurez manuellement le réseau :
```bash
# Pour Ethernet
dhcpcd

# Pour Wi-Fi
wifi-menu
```

### Problèmes Post-Installation

#### Pas de son
```bash
# Installer PulseAudio
sudo pacman -S pulseaudio pulseaudio-alsa
pulseaudio --start
```

#### Problèmes graphiques
```bash
# Réinstaller les pilotes
sudo pacman -S xorg-server xorg-xinit

# Pour NVIDIA
sudo pacman -S nvidia nvidia-utils

# Pour AMD
sudo pacman -S xf86-video-amdgpu
```

## 📞 Support

### Documentation
- **Wiki ArchFusion** : [wiki.archfusion.org](https://wiki.archfusion.org)
- **FAQ** : [docs/FAQ.md](FAQ.md)
- **Guide de Dépannage** : [docs/TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### Communauté
- **Forum** : [forum.archfusion.org](https://forum.archfusion.org)
- **Discord** : [discord.gg/archfusion](https://discord.gg/archfusion)
- **Reddit** : [r/ArchFusionOS](https://reddit.com/r/ArchFusionOS)

### Signaler un Bug
- **GitHub Issues** : [github.com/JimmyRamsamynaick/ArchFusion/issues](https://github.com/JimmyRamsamynaick/ArchFusion/issues)
- **Email** : support@archfusion.org

### Contribuer
Consultez notre [Guide de Contribution](../CONTRIBUTING.md) pour apprendre comment contribuer au projet.

---

## 🎉 Félicitations !

Vous avez maintenant installé ArchFusion OS avec succès ! Profitez de votre nouvelle distribution Linux optimisée et personnalisée.

Pour aller plus loin :
- Explorez les [Guides de Configuration](CONFIGURATION.md)
- Découvrez les [Astuces et Conseils](TIPS.md)
- Rejoignez notre [Communauté](COMMUNITY.md)

**Bienvenue dans l'écosystème ArchFusion OS !** 🚀