# ❓ FAQ - Questions Fréquemment Posées

Cette FAQ répond aux questions les plus courantes concernant ArchFusion OS.

## 📋 Table des Matières

- [Général](#-général)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Logiciels](#-logiciels)
- [Performance](#-performance)
- [Sécurité](#-sécurité)
- [Dépannage](#-dépannage)

## 🌟 Général

### Qu'est-ce qu'ArchFusion OS ?
ArchFusion OS est une distribution Linux basée sur Arch Linux, conçue pour offrir une expérience utilisateur moderne avec l'esthétique de macOS et la puissance d'Arch Linux. Elle combine stabilité, performance et facilité d'utilisation.

### Quelle est la différence avec Arch Linux standard ?
- **Installation simplifiée** avec interface graphique
- **Environnement de bureau pré-configuré** (KDE Plasma avec thème macOS)
- **Logiciels essentiels pré-installés**
- **Configuration optimisée** pour les performances
- **Support communautaire dédié**

### ArchFusion OS est-il gratuit ?
Oui, ArchFusion OS est entièrement gratuit et open-source sous licence GPL v3.

### Puis-je utiliser ArchFusion OS sur mon ordinateur portable ?
Oui, ArchFusion OS est compatible avec la plupart des ordinateurs portables modernes. Vérifiez la [liste de compatibilité matérielle](HARDWARE.md).

## 💾 Installation

### Quelle est la configuration minimale requise ?
- **CPU** : x86_64 (64-bit)
- **RAM** : 2 GB minimum (4 GB recommandé)
- **Stockage** : 20 GB minimum (50 GB recommandé)
- **Connexion Internet** : Recommandée

### Puis-je installer ArchFusion OS à côté de Windows ?
Oui, ArchFusion OS supporte le dual-boot avec Windows. L'installateur peut automatiquement redimensionner les partitions Windows existantes.

### L'installation efface-t-elle mes données ?
L'installation complète efface le disque sélectionné. Pour préserver vos données :
- Sauvegardez vos fichiers importants
- Utilisez l'option de partitionnement manuel
- Considérez l'installation sur un disque séparé

### Combien de temps prend l'installation ?
L'installation prend généralement 15-30 minutes selon :
- La vitesse de votre matériel
- La connexion Internet
- Les logiciels sélectionnés

### Puis-je installer ArchFusion OS sur une machine virtuelle ?
Oui, ArchFusion OS fonctionne parfaitement sur :
- **VirtualBox** (4 GB RAM recommandé)
- **VMware** (4 GB RAM recommandé)
- **QEMU/KVM** (2 GB RAM minimum)

## ⚙️ Configuration

### Comment changer la langue du système ?
```bash
# Via l'interface graphique
Paramètres Système → Régionalisation → Langue

# Via la ligne de commande
sudo localectl set-locale LANG=fr_FR.UTF-8
```

### Comment configurer le Wi-Fi ?
```bash
# Interface graphique
Clic sur l'icône réseau → Sélectionner le réseau → Entrer le mot de passe

# Ligne de commande
nmcli device wifi connect "NomDuRéseau" password "MotDePasse"
```

### Comment activer les pilotes propriétaires ?
```bash
# Pour NVIDIA
sudo pacman -S nvidia nvidia-utils

# Pour AMD
sudo pacman -S xf86-video-amdgpu

# Redémarrer après installation
sudo reboot
```

### Comment personnaliser l'apparence ?
- **Thèmes** : Paramètres Système → Apparence → Thèmes globaux
- **Icônes** : Paramètres Système → Apparence → Icônes
- **Curseurs** : Paramètres Système → Apparence → Curseurs
- **Fond d'écran** : Clic droit sur le bureau → Configurer le bureau

## 📦 Logiciels

### Comment installer de nouveaux logiciels ?
```bash
# Gestionnaire de paquets Pacman
sudo pacman -S nom_du_paquet

# Interface graphique
Discover (dans le menu des applications)

# AUR (Arch User Repository)
yay -S nom_du_paquet_aur
```

### Quels logiciels sont pré-installés ?
- **Navigateur** : Firefox
- **Suite bureautique** : LibreOffice
- **Éditeur de texte** : Kate, Vim
- **Terminal** : Konsole
- **Gestionnaire de fichiers** : Dolphin
- **Lecteur multimédia** : VLC
- **Éditeur d'images** : GIMP

### Comment mettre à jour le système ?
```bash
# Mise à jour complète
sudo pacman -Syu

# Interface graphique
Discover → Mises à jour
```

### Puis-je installer des logiciels Windows ?
Oui, via :
- **Wine** : Pour les applications Windows
- **PlayOnLinux** : Interface graphique pour Wine
- **Steam Proton** : Pour les jeux Windows

## 🚀 Performance

### Comment optimiser les performances ?
```bash
# Activer les services de performance
sudo systemctl enable irqbalance
sudo systemctl enable thermald

# Optimiser le swappiness
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Utiliser un SSD avec TRIM
sudo systemctl enable fstrim.timer
```

### Mon système est lent, que faire ?
1. **Vérifier l'utilisation des ressources** : `htop`
2. **Désactiver les services inutiles** : `systemctl list-unit-files --state=enabled`
3. **Nettoyer le cache** : `sudo pacman -Sc`
4. **Vérifier l'espace disque** : `df -h`

### Comment améliorer l'autonomie de la batterie ?
```bash
# Installer TLP pour la gestion d'énergie
sudo pacman -S tlp tlp-rdw
sudo systemctl enable tlp
sudo systemctl start tlp

# Configurer la luminosité automatique
sudo pacman -S light
```

## 🔒 Sécurité

### ArchFusion OS est-il sécurisé ?
Oui, ArchFusion OS inclut :
- **Pare-feu activé par défaut** (UFW)
- **Mises à jour de sécurité régulières**
- **Chiffrement de disque optionnel**
- **AppArmor pour la sécurité des applications**

### Comment activer le chiffrement du disque ?
Le chiffrement doit être configuré lors de l'installation :
1. Choisir "Partitionnement manuel"
2. Sélectionner "Chiffrer la partition"
3. Définir une phrase de passe forte

### Comment configurer un pare-feu ?
```bash
# UFW est pré-installé et activé
sudo ufw status

# Autoriser un port spécifique
sudo ufw allow 22/tcp

# Bloquer une IP
sudo ufw deny from 192.168.1.100
```

### Comment sauvegarder mes données ?
```bash
# Sauvegarde avec rsync
rsync -av --progress /home/utilisateur/ /media/sauvegarde/

# Sauvegarde automatique avec Timeshift
sudo pacman -S timeshift
sudo timeshift --create --comments "Sauvegarde manuelle"
```

## 🔧 Dépannage

### Le système ne démarre plus après une mise à jour
1. **Démarrer en mode de récupération** depuis GRUB
2. **Vérifier les logs** : `journalctl -b`
3. **Restaurer une sauvegarde** : `sudo timeshift --restore`
4. **Réinstaller le kernel** : `sudo pacman -S linux`

### Pas de son après l'installation
```bash
# Vérifier les périphériques audio
aplay -l

# Réinstaller PulseAudio
sudo pacman -S pulseaudio pulseaudio-alsa
pulseaudio --kill
pulseaudio --start

# Interface graphique
Paramètres Système → Multimédia → Configuration audio
```

### L'écran reste noir au démarrage
1. **Ajouter nomodeset** aux paramètres du kernel
2. **Appuyer sur 'e' dans GRUB**
3. **Ajouter 'nomodeset'** à la ligne linux
4. **Appuyer sur Ctrl+X** pour démarrer

### Wi-Fi ne fonctionne pas
```bash
# Vérifier la carte réseau
lspci | grep -i network

# Installer les pilotes manquants
sudo pacman -S linux-firmware

# Redémarrer NetworkManager
sudo systemctl restart NetworkManager
```

### Comment réinitialiser le mot de passe root ?
1. **Démarrer en mode single-user** depuis GRUB
2. **Ajouter 'single'** aux paramètres du kernel
3. **Monter le système en écriture** : `mount -o remount,rw /`
4. **Changer le mot de passe** : `passwd root`

### L'installation échoue
- **Vérifier l'intégrité de l'ISO** avec les checksums
- **Tester la RAM** avec memtest86+
- **Utiliser un autre port USB** ou recréer le média
- **Désactiver le Secure Boot** dans le BIOS

### Comment obtenir de l'aide ?
1. **Consulter les logs** : `journalctl -xe`
2. **Rechercher sur le forum** : [forum.archfusion.org](https://forum.archfusion.org)
3. **Poser une question** sur Discord ou Reddit
4. **Signaler un bug** sur GitHub

## 📚 Ressources Supplémentaires

### Documentation
- [Guide d'Installation](INSTALLATION.md)
- [Guide de Configuration](CONFIGURATION.md)
- [Dépannage Avancé](TROUBLESHOOTING.md)

### Communauté
- **Forum** : [forum.archfusion.org](https://forum.archfusion.org)
- **Discord** : [discord.gg/archfusion](https://discord.gg/archfusion)
- **Reddit** : [r/ArchFusionOS](https://reddit.com/r/ArchFusionOS)

### Développement
- **GitHub** : [github.com/JimmyRamsamynaick/ArchFusion](https://github.com/JimmyRamsamynaick/ArchFusion)
- **Guide de Contribution** : [CONTRIBUTING.md](../CONTRIBUTING.md)

---

**Cette FAQ ne répond pas à votre question ?**
N'hésitez pas à nous contacter via nos canaux de support communautaire !