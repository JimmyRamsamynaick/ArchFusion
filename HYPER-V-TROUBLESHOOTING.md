# 🔧 Guide de Diagnostic Hyper-V - ArchFusion OS

## 🚨 Problème : "The boot loader did not load an operating system"

Cette erreur indique que Hyper-V ne peut pas démarrer l'ISO. Voici un guide complet de résolution.

## 📋 Diagnostic Étape par Étape

### 1. ✅ Vérification de la Configuration VM

#### Configuration Recommandée :
```powershell
# PowerShell - Créer une VM optimisée
New-VM -Name "ArchFusion-Test" -Generation 2 -MemoryStartupBytes 2GB
Set-VMProcessor -VMName "ArchFusion-Test" -Count 2
Set-VMMemory -VMName "ArchFusion-Test" -DynamicMemoryEnabled $false
```

#### Points Critiques :
- ✅ **Generation 2** (UEFI) - OBLIGATOIRE
- ✅ **Secure Boot : DÉSACTIVÉ**
- ✅ **Mémoire : Minimum 1GB**
- ✅ **Processeur : Minimum 1 core**

### 2. 🔒 Désactiver Secure Boot

```powershell
# Désactiver Secure Boot
Set-VMFirmware -VMName "ArchFusion-Test" -EnableSecureBoot Off
```

**Via l'interface graphique :**
1. Clic droit sur la VM → Paramètres
2. Sécurité → Décocher "Activer le démarrage sécurisé"
3. Appliquer

### 3. 💿 Configuration du Boot Order

```powershell
# Définir l'ordre de boot
$dvd = Get-VMDvdDrive -VMName "ArchFusion-Test"
Set-VMFirmware -VMName "ArchFusion-Test" -FirstBootDevice $dvd
```

**Via l'interface graphique :**
1. Paramètres VM → Firmware
2. Ordre de démarrage : DVD en premier
3. Appliquer

### 4. 📀 Montage de l'ISO

```powershell
# Monter l'ISO
Set-VMDvdDrive -VMName "ArchFusion-Test" -Path "C:\path\to\ArchFusion-OS-Real-20250916.iso"
```

## 🔍 Tests de Validation

### Test 1 : Vérification de l'ISO
```bash
# Vérifier l'intégrité de l'ISO
shasum -a 256 ArchFusion-OS-Real-20250916.iso
# Comparer avec le fichier .sha256
```

### Test 2 : Structure de l'ISO
```bash
# Lister le contenu de l'ISO
hdiutil mount ArchFusion-OS-Real-20250916.iso
ls -la /Volumes/ARCHFUSION/
```

**Structure attendue :**
```
/Volumes/ARCHFUSION/
├── boot/
│   ├── grub/
│   │   └── grub.cfg
│   ├── isolinux/
│   │   ├── isolinux.bin
│   │   ├── isolinux.cfg
│   │   └── ldlinux.c32
│   ├── vmlinuz
│   └── initrd.gz
└── EFI/
    └── BOOT/
        ├── BOOTX64.EFI
        └── ldlinux.e64
```

### Test 3 : Validation des Bootloaders
```bash
# Vérifier la signature de boot
hexdump -C /Volumes/ARCHFUSION/boot/isolinux/isolinux.bin | tail -1
# Doit se terminer par 55 aa
```

## 🛠️ Solutions par Symptôme

### Symptôme 1 : "No operating system was loaded"
**Causes possibles :**
- Secure Boot activé
- Mauvais ordre de boot
- ISO corrompue

**Solutions :**
1. Désactiver Secure Boot
2. DVD en premier dans boot order
3. Re-télécharger/recréer l'ISO

### Symptôme 2 : Écran noir après sélection du boot
**Causes possibles :**
- Bootloader UEFI défaillant
- Kernel non compatible

**Solutions :**
1. Utiliser l'ISO avec bootloaders réels
2. Tester en mode BIOS Legacy (Gen 1)

### Symptôme 3 : "Boot image was not found"
**Causes possibles :**
- Chemin ISO incorrect
- Permissions insuffisantes
- ISO non montée

**Solutions :**
1. Vérifier le chemin complet de l'ISO
2. Exécuter PowerShell en administrateur
3. Re-monter l'ISO

## 🔄 Procédure de Test Complète

### Étape 1 : Préparation
```powershell
# Supprimer l'ancienne VM si elle existe
Remove-VM -Name "ArchFusion-Test" -Force

# Créer une nouvelle VM
New-VM -Name "ArchFusion-Test" -Generation 2 -MemoryStartupBytes 2GB -NewVHDPath "C:\VMs\ArchFusion-Test.vhdx" -NewVHDSizeBytes 20GB
```

### Étape 2 : Configuration
```powershell
# Configuration optimale
Set-VMProcessor -VMName "ArchFusion-Test" -Count 2
Set-VMMemory -VMName "ArchFusion-Test" -DynamicMemoryEnabled $false
Set-VMFirmware -VMName "ArchFusion-Test" -EnableSecureBoot Off

# Monter l'ISO
Set-VMDvdDrive -VMName "ArchFusion-Test" -Path "C:\path\to\ArchFusion-OS-Real-20250916.iso"

# Boot order
$dvd = Get-VMDvdDrive -VMName "ArchFusion-Test"
Set-VMFirmware -VMName "ArchFusion-Test" -FirstBootDevice $dvd
```

### Étape 3 : Test de Boot
```powershell
# Démarrer la VM
Start-VM -Name "ArchFusion-Test"

# Ouvrir la console
vmconnect.exe localhost "ArchFusion-Test"
```

## 🎯 Alternatives de Test

### Option 1 : VirtualBox (Test de Référence)
```bash
# Créer une VM VirtualBox pour comparaison
VBoxManage createvm --name "ArchFusion-VBox" --register
VBoxManage modifyvm "ArchFusion-VBox" --memory 2048 --cpus 2
VBoxManage storagectl "ArchFusion-VBox" --name "IDE" --add ide
VBoxManage storageattach "ArchFusion-VBox" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium ArchFusion-OS-Real-20250916.iso
```

### Option 2 : VMware Workstation
1. Nouvelle VM → Installer depuis un disque ou une image ISO
2. Sélectionner l'ISO ArchFusion
3. Configuration : 2GB RAM, 1 CPU
4. Démarrer et comparer

### Option 3 : QEMU (Test Avancé)
```bash
# Test UEFI avec QEMU
qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -cdrom ArchFusion-OS-Real-20250916.iso -m 2048 -enable-kvm
```

## 📊 Matrice de Compatibilité

| Hyperviseur | BIOS Legacy | UEFI | Secure Boot | Status |
|-------------|-------------|------|-------------|---------|
| Hyper-V Gen1 | ✅ | ❌ | ❌ | Compatible |
| Hyper-V Gen2 | ❌ | ✅ | ❌ | Compatible |
| VirtualBox | ✅ | ✅ | ❌ | Compatible |
| VMware | ✅ | ✅ | ❌ | Compatible |
| QEMU | ✅ | ✅ | ❌ | Compatible |

## 🚀 Script de Test Automatique

```powershell
# Test-ArchFusionISO.ps1
param(
    [string]$ISOPath = ".\iso\ArchFusion-OS-Real-20250916.iso",
    [string]$VMName = "ArchFusion-AutoTest"
)

Write-Host "🔍 Test automatique d'ArchFusion OS sur Hyper-V" -ForegroundColor Cyan

# Vérifier l'ISO
if (!(Test-Path $ISOPath)) {
    Write-Error "❌ ISO non trouvée : $ISOPath"
    exit 1
}

Write-Host "✅ ISO trouvée : $ISOPath" -ForegroundColor Green

# Supprimer l'ancienne VM
if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    Write-Host "🗑️ Suppression de l'ancienne VM..." -ForegroundColor Yellow
    Stop-VM -Name $VMName -Force -ErrorAction SilentlyContinue
    Remove-VM -Name $VMName -Force
}

# Créer la VM
Write-Host "🏗️ Création de la VM de test..." -ForegroundColor Yellow
New-VM -Name $VMName -Generation 2 -MemoryStartupBytes 2GB -NewVHDPath "C:\temp\$VMName.vhdx" -NewVHDSizeBytes 10GB

# Configuration
Write-Host "⚙️ Configuration de la VM..." -ForegroundColor Yellow
Set-VMProcessor -VMName $VMName -Count 2
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $false
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off

# Monter l'ISO
Write-Host "💿 Montage de l'ISO..." -ForegroundColor Yellow
Set-VMDvdDrive -VMName $VMName -Path (Resolve-Path $ISOPath).Path

# Boot order
$dvd = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $dvd

Write-Host "🚀 VM prête ! Démarrage..." -ForegroundColor Green
Start-VM -Name $VMName

Write-Host "🖥️ Ouverture de la console..." -ForegroundColor Green
vmconnect.exe localhost $VMName

Write-Host "✅ Test terminé ! Vérifiez le boot dans la console." -ForegroundColor Green
```

## 📞 Support et Dépannage

### Logs Hyper-V
```powershell
# Consulter les logs d'événements
Get-WinEvent -LogName "Microsoft-Windows-Hyper-V-Worker-Admin" | Where-Object {$_.Id -eq 18590}
```

### Informations Système
```powershell
# Vérifier les fonctionnalités Hyper-V
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

### Contact
- 📧 Email : support@archfusion-os.org
- 🐛 Issues : https://github.com/ArchFusion-OS/issues
- 💬 Discord : https://discord.gg/archfusion

---

**Note :** Ce guide couvre les problèmes les plus courants. Si le problème persiste, utilisez le script de test automatique et partagez les logs avec l'équipe de support.