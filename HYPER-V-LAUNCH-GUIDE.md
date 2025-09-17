# 🚀 Guide de Lancement - ArchFusion OS sur Hyper-V

## 📋 Prérequis

### Système Requis
- **Windows 10/11 Pro, Enterprise ou Education**
- **Hyper-V activé** dans les fonctionnalités Windows
- **Virtualisation matérielle** activée dans le BIOS/UEFI
- **RAM**: 8 GB minimum (4 GB pour la VM)
- **Stockage**: 30 GB d'espace libre

### Vérifier Hyper-V
```powershell
# Vérifier si Hyper-V est installé
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

# Si pas installé, l'activer (redémarrage requis)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

## 📁 Préparation de l'ISO

### Télécharger l'ISO
1. **Récupérer l'ISO** depuis le dossier `output/`
   - Fichier: `ArchFusion-OS-20250917.iso` (1.4 GB)
   - Checksum: `961002fab836819b599e770aa25ff02bff1697d1d051140062066a5ff47d6712`

2. **Copier l'ISO** dans un dossier accessible
   ```cmd
   # Exemple: copier vers C:\VMs\ISOs\
   mkdir C:\VMs\ISOs
   copy "ArchFusion-OS-20250917.iso" "C:\VMs\ISOs\"
   ```

3. **Vérifier l'intégrité** (optionnel)
   ```powershell
   Get-FileHash "C:\VMs\ISOs\ArchFusion-OS-20250917.iso" -Algorithm SHA256
   ```

## 🖥️ Création de la VM Hyper-V

### Méthode 1: Interface Graphique (Recommandée)

#### Étape 1: Ouvrir Hyper-V Manager
1. **Rechercher** "Hyper-V Manager" dans le menu Démarrer
2. **Lancer** en tant qu'administrateur

#### Étape 2: Créer une Nouvelle VM
1. **Clic droit** sur votre serveur Hyper-V
2. **Sélectionner** "Nouvelle" → "Machine virtuelle..."
3. **Suivre l'assistant** avec ces paramètres:

**Configuration Recommandée:**
```
Nom: ArchFusion-OS-Test
Génération: Generation 2 (UEFI) - RECOMMANDÉ
Mémoire de démarrage: 4096 MB (4 GB)
Utiliser la mémoire dynamique: ✅ Activé
Réseau: Default Switch
Disque dur virtuel: 
  - Taille: 40 GB minimum
  - Type: VHDX dynamique
```

#### Étape 3: Configuration Post-Création
1. **Clic droit** sur la VM → "Paramètres"
2. **Sécurité** → Désactiver "Secure Boot" ⚠️ **IMPORTANT**
3. **Processeur** → Nombre de processeurs virtuels: 2
4. **Lecteur DVD** → Monter l'ISO:
   - Sélectionner "Fichier image (.iso)"
   - Parcourir vers `C:\VMs\ISOs\ArchFusion-OS-20250917.iso`

### Méthode 2: PowerShell (Avancée)

```powershell
# Variables de configuration
$VMName = "ArchFusion-OS-Test"
$VMPath = "C:\VMs"
$ISOPath = "C:\VMs\ISOs\ArchFusion-OS-20250917.iso"
$VHDPath = "$VMPath\$VMName\$VMName.vhdx"

# Créer la VM Generation 2 (UEFI)
New-VM -Name $VMName -Generation 2 -MemoryStartupBytes 4GB -Path $VMPath

# Configurer la mémoire dynamique
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes 2GB -MaximumBytes 8GB

# Créer et attacher le disque dur virtuel
New-VHD -Path $VHDPath -SizeBytes 40GB -Dynamic
Add-VMHardDiskDrive -VMName $VMName -Path $VHDPath

# Monter l'ISO
Set-VMDvdDrive -VMName $VMName -Path $ISOPath

# Désactiver Secure Boot (CRITIQUE)
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off

# Configurer l'ordre de boot (DVD en premier)
Set-VMFirmware -VMName $VMName -FirstBootDevice (Get-VMDvdDrive -VMName $VMName)

# Configurer le processeur
Set-VMProcessor -VMName $VMName -Count 2

# Configurer le réseau
Connect-VMNetworkAdapter -VMName $VMName -SwitchName "Default Switch"
```

## 🚀 Démarrage de la VM

### Lancement Initial
1. **Sélectionner** la VM dans Hyper-V Manager
2. **Cliquer** sur "Démarrer" ou "Start"
3. **Double-cliquer** sur la VM pour ouvrir la console

### Séquence de Boot Attendue
1. **Écran Hyper-V** - Logo de démarrage
2. **Menu GRUB** - Sélectionner "ArchFusion OS Live"
3. **Boot Linux** - Messages de démarrage
4. **Interface ArchFusion** - Bureau ou terminal

## ⚙️ Configuration Optimale

### Paramètres VM Recommandés
```
Génération: 2 (UEFI)
RAM: 4-8 GB
CPU: 2-4 cœurs
Disque: 40 GB (dynamique)
Réseau: Default Switch
Secure Boot: DÉSACTIVÉ ⚠️
```

### Fonctionnalités Hyper-V
- **Enhanced Session Mode**: Activé pour meilleure expérience
- **Integration Services**: Installés automatiquement
- **Dynamic Memory**: Activé pour optimisation RAM
- **Checkpoints**: Créer un point de restauration après installation

## 🐛 Résolution des Problèmes

### Problème: VM ne démarre pas
**Solutions:**
```powershell
# Vérifier que Secure Boot est désactivé
Get-VMFirmware -VMName "ArchFusion-OS-Test" | Select-Object SecureBoot

# Désactiver si nécessaire
Set-VMFirmware -VMName "ArchFusion-OS-Test" -EnableSecureBoot Off
```

### Problème: Écran noir après GRUB
**Solutions:**
1. **Redémarrer** la VM
2. **Dans GRUB**, appuyer sur `e` pour éditer
3. **Ajouter** `nomodeset` à la ligne de boot
4. **Appuyer** sur `Ctrl+X` pour démarrer

### Problème: Réseau non fonctionnel
**Solutions:**
```powershell
# Vérifier la connexion réseau
Get-VMNetworkAdapter -VMName "ArchFusion-OS-Test"

# Reconnecter au switch par défaut
Connect-VMNetworkAdapter -VMName "ArchFusion-OS-Test" -SwitchName "Default Switch"
```

### Problème: Performance lente
**Solutions:**
1. **Augmenter la RAM** allouée
2. **Activer Dynamic Memory**
3. **Ajouter plus de CPU virtuels**
4. **Utiliser un SSD** pour le stockage

## 📊 Commandes de Gestion Utiles

### Gestion de la VM
```powershell
# Démarrer la VM
Start-VM -Name "ArchFusion-OS-Test"

# Arrêter la VM proprement
Stop-VM -Name "ArchFusion-OS-Test"

# Forcer l'arrêt
Stop-VM -Name "ArchFusion-OS-Test" -Force

# Créer un checkpoint
Checkpoint-VM -Name "ArchFusion-OS-Test" -SnapshotName "Installation-Complete"

# Voir les informations de la VM
Get-VM -Name "ArchFusion-OS-Test" | Format-List
```

### Monitoring
```powershell
# Voir l'utilisation des ressources
Get-VM -Name "ArchFusion-OS-Test" | Measure-VM

# Voir l'état de la VM
Get-VM -Name "ArchFusion-OS-Test" | Select-Object Name, State, Status
```

## 🎯 Première Utilisation

### Après le Boot Réussi
1. **Explorer l'interface** ArchFusion OS
2. **Tester la connectivité réseau**
3. **Vérifier la détection matériel**
4. **Créer un checkpoint** pour sauvegarde

### Tests de Validation
```bash
# Dans la VM ArchFusion OS
# Tester le réseau
ping -c 4 8.8.8.8

# Vérifier les ressources
free -h
lscpu
lsblk

# Tester l'interface graphique
startx  # Si en mode console
```

## 🔧 Optimisations Avancées

### Performance
- **Nested Virtualization**: Si besoin de Docker/containers
- **SR-IOV**: Pour performance réseau maximale
- **RemoteFX**: Pour accélération graphique (si supporté)

### Sécurité
- **Shielded VM**: Pour environnements sensibles
- **Encryption**: Chiffrement du disque virtuel
- **Network Isolation**: Switches privés pour isolation

## 📝 Checklist de Démarrage

- [ ] Hyper-V installé et activé
- [ ] ISO ArchFusion OS téléchargée et vérifiée
- [ ] VM créée avec Generation 2
- [ ] Secure Boot désactivé ⚠️
- [ ] RAM suffisante allouée (4GB+)
- [ ] ISO montée dans le lecteur DVD
- [ ] Ordre de boot configuré (DVD first)
- [ ] VM démarrée et GRUB visible
- [ ] ArchFusion OS booté avec succès

---

**🎉 Votre VM ArchFusion OS est maintenant prête à l'utilisation sur Hyper-V !**

*Pour plus d'aide, consultez les guides de troubleshooting dans le dossier `docs/`*