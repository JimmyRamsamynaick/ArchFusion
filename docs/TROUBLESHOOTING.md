# 🔧 Guide de Dépannage ArchFusion OS

Ce guide vous aide à résoudre les problèmes les plus courants rencontrés avec ArchFusion OS.

## 📋 Table des Matières

- [Problèmes de Démarrage](#-problèmes-de-démarrage)
- [Problèmes d'Installation](#-problèmes-dinstallation)
- [Problèmes Réseau](#-problèmes-réseau)
- [Problèmes Audio](#-problèmes-audio)
- [Problèmes Graphiques](#-problèmes-graphiques)
- [Problèmes de Performance](#-problèmes-de-performance)
- [Problèmes de Mise à Jour](#-problèmes-de-mise-à-jour)
- [Outils de Diagnostic](#-outils-de-diagnostic)

## 🚀 Problèmes de Démarrage

### Le système ne démarre pas depuis l'USB/DVD

**Symptômes :**
- L'ordinateur démarre sur le système existant
- Message "No bootable device found"
- Écran noir sans activité

**Solutions :**

1. **Vérifier l'ordre de démarrage dans le BIOS/UEFI**
   ```
   1. Redémarrer et appuyer sur F2/F12/Del/Esc
   2. Aller dans "Boot Order" ou "Boot Priority"
   3. Placer USB/DVD en première position
   4. Sauvegarder et redémarrer
   ```

2. **Désactiver le Secure Boot**
   ```
   1. Dans le BIOS/UEFI, aller dans "Security"
   2. Désactiver "Secure Boot"
   3. Activer "Legacy Boot" si nécessaire
   4. Sauvegarder et redémarrer
   ```

3. **Recréer le média d'installation**
   ```bash
   # Vérifier l'intégrité de l'ISO
   sha256sum ArchFusion-OS.iso
   
   # Recréer la clé USB
   sudo dd if=ArchFusion-OS.iso of=/dev/sdX bs=4M status=progress
   ```

### Écran noir au démarrage

**Symptômes :**
- Écran noir après la sélection dans GRUB
- Curseur clignotant sans progression
- Système semble figé

**Solutions :**

1. **Ajouter nomodeset aux paramètres du kernel**
   ```
   1. Dans GRUB, appuyer sur 'e' sur l'entrée ArchFusion OS
   2. Trouver la ligne commençant par 'linux'
   3. Ajouter 'nomodeset' à la fin de la ligne
   4. Appuyer sur Ctrl+X pour démarrer
   ```

2. **Utiliser des paramètres de compatibilité**
   ```
   Paramètres à essayer :
   - nomodeset acpi=off
   - nomodeset noapic
   - nomodeset nouveau.modeset=0
   ```

3. **Vérifier la compatibilité graphique**
   ```bash
   # Identifier la carte graphique
   lspci | grep -i vga
   
   # Installer les pilotes appropriés après démarrage
   sudo pacman -S xf86-video-vesa  # Pilote générique
   ```

### Kernel Panic au démarrage

**Symptômes :**
- Message "Kernel panic - not syncing"
- Système s'arrête brutalement
- Trace d'erreur affichée

**Solutions :**

1. **Vérifier la RAM**
   ```
   1. Démarrer avec memtest86+ depuis GRUB
   2. Laisser tourner plusieurs passes
   3. Remplacer la RAM défectueuse si erreurs
   ```

2. **Paramètres de démarrage alternatifs**
   ```
   Essayer ces paramètres :
   - mem=2G (limiter la RAM utilisée)
   - maxcpus=1 (utiliser un seul CPU)
   - acpi=off (désactiver ACPI)
   ```

## 💾 Problèmes d'Installation

### L'installateur ne se lance pas

**Symptômes :**
- Erreur Python au lancement
- Interface graphique ne s'affiche pas
- Message d'erreur de dépendances

**Solutions :**

1. **Vérifier les dépendances Python**
   ```bash
   # Installer les dépendances manquantes
   pip3 install -r /archfusion/scripts/install/requirements.txt
   
   # Lancer l'installateur manuellement
   python3 /archfusion/scripts/install/gui-installer.py
   ```

2. **Utiliser l'installateur CLI**
   ```bash
   # Si l'interface graphique échoue
   bash /archfusion/scripts/install/install.sh
   ```

3. **Vérifier l'environnement X11**
   ```bash
   # Tester l'affichage
   echo $DISPLAY
   xhost +
   
   # Redémarrer le serveur X si nécessaire
   sudo systemctl restart display-manager
   ```

### Erreur de partitionnement

**Symptômes :**
- "Device is busy" lors du partitionnement
- Impossible de créer/modifier les partitions
- Erreur d'écriture sur le disque

**Solutions :**

1. **Démonter les partitions actives**
   ```bash
   # Lister les partitions montées
   lsblk
   
   # Démonter toutes les partitions du disque
   sudo umount /dev/sda*
   
   # Forcer le démontage si nécessaire
   sudo umount -l /dev/sda*
   ```

2. **Nettoyer la table de partitions**
   ```bash
   # Effacer complètement la table de partitions
   sudo wipefs -a /dev/sda
   
   # Créer une nouvelle table GPT
   sudo parted /dev/sda mklabel gpt
   ```

3. **Vérifier l'intégrité du disque**
   ```bash
   # Test SMART du disque
   sudo smartctl -a /dev/sda
   
   # Test de surface
   sudo badblocks -v /dev/sda
   ```

### Installation interrompue

**Symptômes :**
- Installation s'arrête à un pourcentage
- Erreur de téléchargement de paquets
- Espace disque insuffisant

**Solutions :**

1. **Vérifier l'espace disque**
   ```bash
   # Vérifier l'espace disponible
   df -h
   
   # Nettoyer si nécessaire
   sudo pacman -Sc
   rm -rf /tmp/*
   ```

2. **Changer de miroir**
   ```bash
   # Éditer la liste des miroirs
   sudo nano /etc/pacman.d/mirrorlist
   
   # Mettre un miroir local en premier
   # Relancer l'installation
   ```

3. **Installation hors ligne**
   ```bash
   # Utiliser les paquets de l'ISO
   sudo pacman -U /run/archiso/bootmnt/arch/x86_64/*.pkg.tar.xz
   ```

## 🌐 Problèmes Réseau

### Wi-Fi ne fonctionne pas

**Symptômes :**
- Aucun réseau Wi-Fi détecté
- Impossible de se connecter
- Connexion instable

**Solutions :**

1. **Vérifier la carte Wi-Fi**
   ```bash
   # Lister les interfaces réseau
   ip link show
   
   # Vérifier les pilotes
   lspci -k | grep -A 3 -i network
   
   # Activer l'interface si nécessaire
   sudo ip link set wlan0 up
   ```

2. **Installer les pilotes manquants**
   ```bash
   # Pilotes firmware Linux
   sudo pacman -S linux-firmware
   
   # Pilotes spécifiques
   sudo pacman -S broadcom-wl  # Pour Broadcom
   sudo pacman -S rtl8821ce-dkms-git  # Pour Realtek
   ```

3. **Configuration manuelle**
   ```bash
   # Scanner les réseaux
   sudo iwlist wlan0 scan | grep ESSID
   
   # Se connecter manuellement
   sudo wpa_supplicant -B -i wlan0 -c <(wpa_passphrase "SSID" "password")
   sudo dhcpcd wlan0
   ```

### Ethernet ne fonctionne pas

**Symptômes :**
- Pas de connexion filaire
- Interface non détectée
- Pas d'adresse IP

**Solutions :**

1. **Vérifier la connexion physique**
   ```bash
   # Vérifier l'état du lien
   ethtool eth0
   
   # Tester avec un autre câble
   # Vérifier les LEDs sur la carte réseau
   ```

2. **Configuration DHCP**
   ```bash
   # Redémarrer NetworkManager
   sudo systemctl restart NetworkManager
   
   # Ou utiliser dhcpcd directement
   sudo dhcpcd eth0
   ```

3. **Configuration IP statique**
   ```bash
   # Configuration temporaire
   sudo ip addr add 192.168.1.100/24 dev eth0
   sudo ip route add default via 192.168.1.1
   
   # Configuration permanente dans NetworkManager
   nmcli con add type ethernet ifname eth0 con-name "Ethernet"
   nmcli con mod "Ethernet" ipv4.addresses 192.168.1.100/24
   nmcli con mod "Ethernet" ipv4.gateway 192.168.1.1
   nmcli con mod "Ethernet" ipv4.dns 8.8.8.8
   nmcli con mod "Ethernet" ipv4.method manual
   ```

## 🔊 Problèmes Audio

### Pas de son

**Symptômes :**
- Aucun son dans les applications
- Périphériques audio non détectés
- Volume muet par défaut

**Solutions :**

1. **Vérifier les périphériques audio**
   ```bash
   # Lister les cartes son
   aplay -l
   
   # Vérifier PulseAudio
   pulseaudio --check -v
   
   # Redémarrer PulseAudio
   pulseaudio --kill
   pulseaudio --start
   ```

2. **Configuration ALSA**
   ```bash
   # Démueter les canaux
   alsamixer
   # Utiliser les flèches et 'M' pour démueter
   
   # Sauvegarder la configuration
   sudo alsactl store
   ```

3. **Réinstaller les composants audio**
   ```bash
   # Réinstaller PulseAudio
   sudo pacman -S pulseaudio pulseaudio-alsa pavucontrol
   
   # Redémarrer la session utilisateur
   ```

### Audio crachotant ou coupé

**Symptômes :**
- Son de mauvaise qualité
- Interruptions audio
- Latence élevée

**Solutions :**

1. **Ajuster la configuration PulseAudio**
   ```bash
   # Éditer la configuration
   sudo nano /etc/pulse/daemon.conf
   
   # Modifier ces valeurs :
   default-sample-rate = 44100
   default-fragments = 4
   default-fragment-size-msec = 25
   ```

2. **Désactiver l'économie d'énergie audio**
   ```bash
   # Créer un fichier de configuration
   echo 'options snd_hda_intel power_save=0' | sudo tee /etc/modprobe.d/audio.conf
   ```

## 🖥️ Problèmes Graphiques

### Résolution d'écran incorrecte

**Symptômes :**
- Résolution trop basse
- Écran étiré ou déformé
- Plusieurs écrans mal configurés

**Solutions :**

1. **Configuration avec xrandr**
   ```bash
   # Lister les modes disponibles
   xrandr
   
   # Définir une résolution
   xrandr --output HDMI-1 --mode 1920x1080
   
   # Configuration multi-écrans
   xrandr --output HDMI-1 --right-of eDP-1
   ```

2. **Configuration permanente**
   ```bash
   # Créer un script de démarrage
   echo 'xrandr --output HDMI-1 --mode 1920x1080' >> ~/.xprofile
   
   # Ou utiliser les paramètres système KDE
   # Paramètres Système → Affichage et Moniteur
   ```

### Pilotes graphiques

**Symptômes :**
- Performance graphique faible
- Plantages d'applications 3D
- Artefacts visuels

**Solutions :**

1. **Identifier la carte graphique**
   ```bash
   # Informations détaillées
   lspci -k | grep -A 2 -i "VGA\|3D"
   
   # Pilote actuellement utilisé
   lsmod | grep -i video
   ```

2. **Installer les pilotes appropriés**
   ```bash
   # Pour NVIDIA
   sudo pacman -S nvidia nvidia-utils nvidia-settings
   
   # Pour AMD
   sudo pacman -S xf86-video-amdgpu mesa vulkan-radeon
   
   # Pour Intel
   sudo pacman -S xf86-video-intel mesa vulkan-intel
   ```

3. **Configuration NVIDIA Optimus**
   ```bash
   # Installer optimus-manager
   yay -S optimus-manager optimus-manager-qt
   
   # Configurer le basculement GPU
   sudo systemctl enable optimus-manager
   ```

## ⚡ Problèmes de Performance

### Système lent

**Symptômes :**
- Démarrage long
- Applications lentes à s'ouvrir
- Interface qui rame

**Solutions :**

1. **Analyser l'utilisation des ressources**
   ```bash
   # Processus consommant le plus
   htop
   
   # Utilisation disque
   iotop
   
   # Services actifs
   systemctl list-unit-files --state=enabled
   ```

2. **Optimisations système**
   ```bash
   # Réduire le swappiness
   echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
   
   # Activer TRIM pour SSD
   sudo systemctl enable fstrim.timer
   
   # Nettoyer le cache
   sudo pacman -Sc
   ```

3. **Désactiver les services inutiles**
   ```bash
   # Lister tous les services
   systemctl list-unit-files --type=service
   
   # Désactiver un service
   sudo systemctl disable nom_du_service
   ```

### Surchauffe

**Symptômes :**
- Ventilateurs bruyants
- Ralentissements thermiques
- Arrêts inattendus

**Solutions :**

1. **Surveiller les températures**
   ```bash
   # Installer les outils de monitoring
   sudo pacman -S lm_sensors
   
   # Détecter les capteurs
   sudo sensors-detect
   
   # Afficher les températures
   sensors
   ```

2. **Gestion thermique**
   ```bash
   # Installer thermald
   sudo pacman -S thermald
   sudo systemctl enable thermald
   
   # Configuration CPU
   sudo pacman -S cpupower
   sudo cpupower frequency-set -g powersave
   ```

## 🔄 Problèmes de Mise à Jour

### Erreur lors des mises à jour

**Symptômes :**
- Conflits de paquets
- Erreurs de signature
- Dépendances non satisfaites

**Solutions :**

1. **Mettre à jour les clés GPG**
   ```bash
   # Actualiser les clés
   sudo pacman -S archlinux-keyring
   sudo pacman-key --refresh-keys
   
   # Réinitialiser si nécessaire
   sudo pacman-key --init
   sudo pacman-key --populate archlinux
   ```

2. **Résoudre les conflits**
   ```bash
   # Forcer la mise à jour
   sudo pacman -Syu --overwrite "*"
   
   # Supprimer les paquets en conflit
   sudo pacman -Rdd paquet_en_conflit
   sudo pacman -S paquet_de_remplacement
   ```

3. **Nettoyer le cache**
   ```bash
   # Nettoyer complètement
   sudo pacman -Scc
   
   # Reconstruire la base de données
   sudo pacman-db-upgrade
   ```

## 🛠️ Outils de Diagnostic

### Logs système

```bash
# Logs du démarrage actuel
journalctl -b

# Logs d'un service spécifique
journalctl -u nom_du_service

# Logs en temps réel
journalctl -f

# Logs avec priorité d'erreur
journalctl -p err
```

### Tests matériel

```bash
# Test de la RAM
memtest86+

# Test du disque dur
sudo smartctl -a /dev/sda
sudo badblocks -v /dev/sda

# Test du processeur
stress --cpu 4 --timeout 60s

# Informations système
inxi -Fxz
```

### Sauvegarde et récupération

```bash
# Créer un point de restauration
sudo timeshift --create --comments "Avant modification"

# Restaurer le système
sudo timeshift --restore

# Sauvegarde manuelle
rsync -av /home/user/ /backup/
```

## 📞 Obtenir de l'Aide

Si ces solutions ne résolvent pas votre problème :

1. **Collecter les informations système**
   ```bash
   # Créer un rapport de diagnostic
   inxi -Fxz > diagnostic.txt
   journalctl -b > system.log
   dmesg > kernel.log
   ```

2. **Contacter la communauté**
   - **Forum** : [forum.archfusion.org](https://forum.archfusion.org)
   - **Discord** : [discord.gg/archfusion](https://discord.gg/archfusion)
   - **GitHub Issues** : [github.com/JimmyRamsamynaick/ArchFusion/issues](https://github.com/JimmyRamsamynaick/ArchFusion/issues)

3. **Informations à fournir**
   - Description détaillée du problème
   - Étapes pour reproduire l'erreur
   - Messages d'erreur exacts
   - Configuration matérielle
   - Fichiers de logs pertinents

---

**N'hésitez pas à contribuer à ce guide en signalant de nouveaux problèmes et leurs solutions !**