# 🖥️ Installation d'ArchFusion OS sur Machine Virtuelle

Ce guide détaille l'installation complète d'ArchFusion OS sur une machine virtuelle, étape par étape.

## 📋 Table des matières

1. [Prérequis système](#prérequis-système)
2. [Téléchargement de l'ISO](#téléchargement-de-liso)
3. [Configuration VirtualBox](#configuration-virtualbox)
4. [Configuration VMware Workstation](#configuration-vmware-workstation)
5. [Installation d'ArchFusion OS](#installation-darchfusion-os)
6. [Optimisations post-installation](#optimisations-post-installation)
7. [Dépannage](#dépannage)

---

## 🔧 Prérequis système

### Configuration minimale recommandée

| Composant | Minimum | Recommandé | Optimal |
|-----------|---------|------------|---------|
| **RAM** | 2 GB | 4 GB | 8 GB+ |
| **Processeur** | 2 cœurs | 4 cœurs | 6+ cœurs |
| **Stockage** | 20 GB | 40 GB | 80 GB+ |
| **Virtualisation** | VT-x/AMD-V | VT-x/AMD-V + VT-d | VT-x/AMD-V + VT-d |

### Logiciels requis

#### Option 1: VirtualBox (Gratuit)
- **VirtualBox 7.0+** : [Télécharger](https://www.virtualbox.org/wiki/Downloads)
- **Extension Pack** : Pour support USB 3.0 et autres fonctionnalités

#### Option 2: VMware Workstation (Payant)
- **VMware Workstation Pro 17+** : [Télécharger](https://www.vmware.com/products/workstation-pro.html)
- **VMware Workstation Player** : Version gratuite pour usage personnel

#### Option 3: Hyper-V (Windows Pro/Enterprise)
- Activé dans les fonctionnalités Windows
- Nécessite Windows 10/11 Pro ou Enterprise

---

## 💿 Téléchargement de l'ISO

### Méthode 1: ISO pré-compilée (Recommandée)
```bash
# Télécharger depuis GitHub Releases
wget https://github.com/JimmyRamsamynaick/ArchFusion/releases/latest/download/ArchFusion-OS-latest.iso

# Vérifier l'intégrité (optionnel)
wget https://github.com/JimmyRamsamynaick/ArchFusion/releases/latest/download/ArchFusion-OS-latest.iso.sha256
sha256sum -c ArchFusion-OS-latest.iso.sha256
```

### Méthode 2: Compilation locale
```bash
# Cloner le repository
git clone https://github.com/JimmyRamsamynaick/ArchFusion.git
cd ArchFusion

# Générer l'ISO (macOS)
chmod +x generate-iso.sh
./generate-iso.sh

# L'ISO sera créée dans le dossier iso/
```

---

## 🔵 Configuration VirtualBox

### Étape 1: Création de la machine virtuelle

1. **Ouvrir VirtualBox** et cliquer sur "Nouvelle"

2. **Configuration de base:**
   ```
   Nom: ArchFusion-OS
   Type: Linux
   Version: Arch Linux (64-bit)
   ```

3. **Allocation mémoire:**
   - Minimum: 2048 MB (2 GB)
   - Recommandé: 4096 MB (4 GB)
   - Optimal: 8192 MB (8 GB)

4. **Disque dur virtuel:**
   - Créer un nouveau disque dur virtuel
   - Type: VDI (VirtualBox Disk Image)
   - Allocation: Dynamiquement alloué
   - Taille: 40 GB minimum

### Étape 2: Configuration avancée

1. **Processeur:**
   ```
   Paramètres → Système → Processeur
   - Processeurs: 2-4 cœurs
   - ✅ Activer PAE/NX
   - ✅ Activer VT-x/AMD-V
   ```

2. **Affichage:**
   ```
   Paramètres → Affichage → Écran
   - Mémoire vidéo: 128 MB
   - ✅ Activer l'accélération 3D
   - Contrôleur graphique: VMSVGA
   ```

3. **Stockage:**
   ```
   Paramètres → Stockage
   - Contrôleur IDE → Ajouter un lecteur optique
   - Sélectionner l'ISO ArchFusion-OS
   ```

4. **Réseau:**
   ```
   Paramètres → Réseau → Carte 1
   - ✅ Activer la carte réseau
   - Mode d'accès réseau: NAT ou Pont
   ```

### Étape 3: Optimisations VirtualBox

```bash
# Paramètres système avancés
Paramètres → Système → Carte mère
- ✅ Activer I/O APIC
- ✅ Activer EFI
- Ordre de démarrage: Optique, Disque dur

Paramètres → Système → Accélération
- ✅ Activer VT-x/AMD-V
- ✅ Activer la pagination imbriquée
```

---

## 🟠 Configuration VMware Workstation

### Étape 1: Création de la VM

1. **Nouveau → Machine virtuelle typique**

2. **Configuration:**
   ```
   Source d'installation: Je vais installer le système plus tard
   Système d'exploitation: Linux
   Version: Autre Linux 5.x kernel 64-bit
   ```

3. **Spécifications:**
   ```
   Nom: ArchFusion-OS
   Emplacement: [Choisir un dossier]
   Taille du disque: 40 GB
   ✅ Diviser le disque virtuel en plusieurs fichiers
   ```

### Étape 2: Configuration matérielle

```
Modifier les paramètres de cette machine virtuelle:

Mémoire: 4096 MB
Processeurs: 4 cœurs
Disque dur: 40 GB (SCSI)
Carte réseau: NAT ou Bridged
Lecteur CD/DVD: Utiliser le fichier image ISO
```

### Étape 3: Options avancées VMware

```
Options → Avancé
- ✅ Activer la virtualisation VT-x/EPT
- ✅ Activer IOMMU
- Firmware: UEFI

Options → Général
- Système d'exploitation invité: Linux
- Version: Autre Linux 5.x kernel 64-bit
```

---

## 🚀 Installation d'ArchFusion OS

### Étape 1: Démarrage depuis l'ISO

1. **Démarrer la machine virtuelle**
2. **Sélectionner "Boot ArchFusion OS"** dans le menu GRUB
3. **Attendre le chargement** du système live

### Étape 2: Configuration initiale

#### A. Sélection de la langue
```
Écran de bienvenue → Langue
- Français (France)
- English (United States)
- [Autres langues disponibles]
```

#### B. Configuration clavier
```
Disposition clavier:
- AZERTY (France)
- QWERTY (US)
- [Autres dispositions]
```

#### C. Connexion réseau
```
Réseau:
- ✅ Connexion automatique (DHCP)
- Configuration manuelle (si nécessaire)
```

### Étape 3: Partitionnement du disque

#### Option 1: Partitionnement automatique (Recommandé)
```
Partitionnement → Automatique
- ✅ Utiliser tout le disque
- ✅ Chiffrement du disque (optionnel)
- Système de fichiers: ext4 ou btrfs
```

#### Option 2: Partitionnement manuel
```
Schéma recommandé pour 40 GB:

/dev/sda1 → /boot/efi → 512 MB → FAT32 → Bootable
/dev/sda2 → /boot     → 1 GB   → ext4
/dev/sda3 → swap      → 2 GB   → swap
/dev/sda4 → /         → 36 GB  → ext4 ou btrfs
```

### Étape 4: Configuration utilisateur

```
Informations utilisateur:
- Nom complet: [Votre nom]
- Nom d'utilisateur: [username]
- Mot de passe: [mot de passe sécurisé]
- ✅ Connexion automatique (optionnel)
- ✅ Utiliser le même mot de passe pour root
```

### Étape 5: Sélection des logiciels

```
Environnements de bureau disponibles:
- KDE Plasma (Recommandé) - Interface moderne et personnalisable
- GNOME - Interface épurée et intuitive
- XFCE - Léger et rapide
- i3wm - Gestionnaire de fenêtres en mosaïque

Logiciels additionnels:
- ✅ Suite bureautique (LibreOffice)
- ✅ Navigateurs web (Firefox, Chromium)
- ✅ Outils de développement
- ✅ Lecteurs multimédia
```

### Étape 6: Installation

1. **Vérifier le résumé** de l'installation
2. **Cliquer sur "Installer"**
3. **Attendre la fin** de l'installation (15-30 minutes)
4. **Redémarrer** et retirer l'ISO

---

## ⚡ Optimisations post-installation

### Installation des Guest Additions/Tools

#### VirtualBox Guest Additions
```bash
# Insérer le CD des Guest Additions
sudo pacman -S virtualbox-guest-utils
sudo systemctl enable vboxservice
sudo reboot
```

#### VMware Tools
```bash
# Installer les outils VMware
sudo pacman -S open-vm-tools
sudo systemctl enable vmtoolsd
sudo systemctl enable vmware-vmblock-fuse
sudo reboot
```

### Optimisations système

#### 1. Mise à jour complète
```bash
# Mettre à jour le système
sudo pacman -Syu

# Nettoyer le cache
sudo pacman -Sc
```

#### 2. Configuration du swap
```bash
# Vérifier le swap
free -h

# Ajuster la swappiness (optionnel)
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```

#### 3. Optimisations graphiques
```bash
# Pour VirtualBox
echo 'MODULES=(vboxguest vboxsf vboxvideo)' | sudo tee -a /etc/mkinitcpio.conf

# Pour VMware
echo 'MODULES=(vmw_balloon vmw_pvscsi vmw_vmci vmwgfx)' | sudo tee -a /etc/mkinitcpio.conf

# Reconstruire l'initramfs
sudo mkinitcpio -P
```

### Configuration des dossiers partagés

#### VirtualBox
```bash
# Créer un dossier partagé dans VirtualBox
# Paramètres VM → Dossiers partagés → Ajouter

# Monter dans ArchFusion OS
sudo mkdir /mnt/shared
sudo mount -t vboxsf nom_partage /mnt/shared

# Montage automatique
echo 'nom_partage /mnt/shared vboxsf defaults,uid=1000,gid=1000 0 0' | sudo tee -a /etc/fstab
```

#### VMware
```bash
# Activer les dossiers partagés dans VMware
# VM → Settings → Options → Shared Folders

# Monter automatiquement
sudo systemctl enable vmware-vmblock-fuse
```

---

## 🔧 Dépannage

### Problèmes courants

#### 1. Écran noir au démarrage
```bash
# Solutions:
- Désactiver l'accélération 3D temporairement
- Changer le contrôleur graphique (VMSVGA → VBoxVGA)
- Augmenter la mémoire vidéo à 128 MB
```

#### 2. Performance lente
```bash
# Vérifications:
- Allouer plus de RAM (minimum 4 GB)
- Activer la virtualisation matérielle (VT-x/AMD-V)
- Installer les Guest Additions/Tools
- Désactiver les effets visuels
```

#### 3. Problèmes réseau
```bash
# Solutions:
- Changer le mode réseau (NAT ↔ Pont)
- Réinitialiser la configuration réseau:
sudo systemctl restart NetworkManager
```

#### 4. Audio non fonctionnel
```bash
# VirtualBox:
Paramètres → Audio → Contrôleur audio: Intel HD Audio

# VMware:
VM Settings → Hardware → Sound Card → Auto detect
```

### Logs de débogage

```bash
# Vérifier les logs système
sudo journalctl -b

# Logs spécifiques VirtualBox
sudo journalctl -u vboxservice

# Logs spécifiques VMware
sudo journalctl -u vmtoolsd
```

---

## 📚 Ressources supplémentaires

- **Documentation officielle**: [ArchFusion Wiki](https://github.com/JimmyRamsamynaick/ArchFusion/wiki)
- **Support communautaire**: [GitHub Issues](https://github.com/JimmyRamsamynaick/ArchFusion/issues)
- **Guide de contribution**: [CONTRIBUTING.md](../CONTRIBUTING.md)
- **FAQ**: [FAQ.md](FAQ.md)

---

## 🎯 Checklist d'installation

- [ ] Prérequis système vérifiés
- [ ] ISO téléchargée et vérifiée
- [ ] Machine virtuelle créée et configurée
- [ ] Installation d'ArchFusion OS terminée
- [ ] Guest Additions/Tools installés
- [ ] Système mis à jour
- [ ] Dossiers partagés configurés (optionnel)
- [ ] Optimisations appliquées

---

**🎉 Félicitations !** Vous avez maintenant ArchFusion OS fonctionnel sur votre machine virtuelle.

Pour toute question ou problème, n'hésitez pas à consulter notre [FAQ](FAQ.md) ou à ouvrir une [issue](https://github.com/JimmyRamsamynaick/ArchFusion/issues) sur GitHub.