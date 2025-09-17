# Guide de Test - ArchFusion OS Boot Compatibility

## 🎯 Objectif
Ce guide vous permet de tester la compatibilité de boot de l'ISO ArchFusion OS sur différentes plateformes virtuelles et physiques.

## 📁 Fichier ISO à Tester
- **Fichier**: `ArchFusion-OS-20250917.iso`
- **Taille**: 1.4G
- **Checksum SHA256**: `961002fab836819b599e770aa25ff02bff1697d1d051140062066a5ff47d6712`
- **Localisation**: `/Users/jimmyramsamynaick/Downloads/jimmy/test/ArchFusion-OS/output/`

## 🔍 Tests de Compatibilité

### 1. VMware Workstation/Fusion

#### Test UEFI
```bash
# Configuration VM recommandée:
- RAM: 2GB minimum (4GB recommandé)
- Disque: 20GB minimum
- Firmware: UEFI
- Secure Boot: Désactivé
```

**Étapes de test:**
1. Créer une nouvelle VM avec firmware UEFI
2. Monter l'ISO ArchFusion-OS-20250917.iso
3. Démarrer la VM
4. Vérifier le boot GRUB
5. Tester le démarrage du système live

#### Test BIOS Legacy
```bash
# Configuration VM:
- RAM: 2GB minimum
- Disque: 20GB minimum  
- Firmware: BIOS Legacy
```

**Étapes de test:**
1. Créer une nouvelle VM avec BIOS Legacy
2. Monter l'ISO
3. Démarrer et vérifier le boot

### 2. VirtualBox

#### Test UEFI
```bash
# Configuration:
- Type: Linux / Arch Linux (64-bit)
- RAM: 2048MB minimum
- Firmware: EFI activé
- Secure Boot: Désactivé
```

#### Test BIOS
```bash
# Configuration:
- Type: Linux / Arch Linux (64-bit)
- RAM: 2048MB minimum
- Firmware: BIOS Legacy
```

### 3. Hyper-V (Windows)

#### Generation 2 (UEFI uniquement)
```powershell
# Commandes PowerShell pour créer la VM:
New-VM -Name "ArchFusion-Test" -Generation 2 -MemoryStartupBytes 2GB
Set-VMDvdDrive -VMName "ArchFusion-Test" -Path "C:\path\to\ArchFusion-OS-20250917.iso"
Set-VMFirmware -VMName "ArchFusion-Test" -EnableSecureBoot Off
Start-VM -Name "ArchFusion-Test"
```

### 4. QEMU/KVM

#### Test UEFI
```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 2048 \
  -bios /usr/share/ovmf/OVMF.fd \
  -cdrom ArchFusion-OS-20250917.iso \
  -boot d
```

#### Test BIOS Legacy
```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 2048 \
  -cdrom ArchFusion-OS-20250917.iso \
  -boot d
```

## ✅ Critères de Validation

### Boot Réussi
- [ ] GRUB s'affiche correctement
- [ ] Menu de boot accessible
- [ ] Sélection des options de boot fonctionne
- [ ] Démarrage du système live réussi
- [ ] Interface utilisateur accessible

### Détection Matériel
- [ ] Réseau détecté et fonctionnel
- [ ] Audio détecté
- [ ] Affichage correct (résolution adaptée)
- [ ] Clavier/souris fonctionnels

### Fonctionnalités Système
- [ ] Terminal accessible
- [ ] Gestionnaire de fichiers fonctionnel
- [ ] Connexion réseau possible
- [ ] Outils système disponibles

## 🐛 Résolution des Problèmes

### Problème: Boot bloqué sur GRUB
**Solution:**
- Vérifier que Secure Boot est désactivé
- Essayer le mode BIOS Legacy si UEFI échoue
- Augmenter la RAM allouée à la VM

### Problème: Écran noir après GRUB
**Solution:**
- Ajouter `nomodeset` aux paramètres de boot
- Essayer `acpi=off` si nécessaire
- Vérifier l'allocation de VRAM

### Problème: Réseau non détecté
**Solution:**
- Vérifier la configuration réseau de la VM
- Essayer différents types d'adaptateurs réseau
- Redémarrer les services réseau

## 📊 Rapport de Test

### Template de Rapport
```
=== RAPPORT DE TEST ARCHFUSION OS ===
Date: [DATE]
Testeur: [NOM]
ISO: ArchFusion-OS-20250917.iso

PLATEFORME TESTÉE:
- Hyperviseur: [VMware/VirtualBox/Hyper-V/QEMU]
- Firmware: [UEFI/BIOS]
- RAM: [QUANTITÉ]
- Version Host: [VERSION]

RÉSULTATS:
✅/❌ Boot GRUB
✅/❌ Démarrage système
✅/❌ Interface utilisateur
✅/❌ Réseau
✅/❌ Audio
✅/❌ Affichage

NOTES:
[Commentaires et observations]

RECOMMANDATIONS:
[Améliorations suggérées]
```

## 🚀 Tests Avancés

### Test de Performance
```bash
# Dans le système live:
# Test CPU
cat /proc/cpuinfo

# Test RAM
free -h

# Test disque
lsblk

# Test réseau
ip addr show
ping -c 4 8.8.8.8
```

### Test de Compatibilité Matériel
```bash
# Lister le matériel détecté
lspci
lsusb
lscpu
lsmod
```

## 📝 Prochaines Étapes

Après validation des tests:
1. Documenter les résultats
2. Identifier les améliorations nécessaires
3. Créer des versions optimisées si besoin
4. Préparer la distribution finale

---

**Note**: Ce guide doit être utilisé systématiquement avant toute distribution de l'ISO ArchFusion OS.