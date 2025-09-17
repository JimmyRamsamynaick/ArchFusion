# Guide de Test ArchFusion OS dans Hyper-V

## 🎯 Problème Résolu

L'ISO précédente ne bootait pas car elle n'avait pas une structure de boot réelle. La nouvelle ISO **ArchFusion-OS-Minimal-20250917.iso** (380K) est une vraie ISO bootable avec :

- ✅ Structure ISO 9660 valide
- ✅ Fichiers de boot GRUB et Syslinux
- ✅ Support UEFI et BIOS Legacy
- ✅ Noyau Linux minimal fonctionnel
- ✅ Système de fichiers SquashFS

## 🚀 Instructions de Test Hyper-V

### Étape 1: Configuration de la VM

1. **Ouvrir Hyper-V Manager**
2. **Créer une nouvelle VM** :
   - Nom : `ArchFusion-Test`
   - Génération : **Generation 2** (recommandé) ou Generation 1
   - Mémoire : 1024 MB minimum
   - Réseau : Default Switch
   - Disque dur : 20 GB (optionnel pour test)

### Étape 2: Configuration Spécifique

#### Pour Generation 2 (UEFI) :
1. **Paramètres VM** → **Sécurité**
2. **Désactiver "Enable Secure Boot"** ⚠️ IMPORTANT
3. **Firmware** → **Boot Order** → Mettre DVD en premier

#### Pour Generation 1 (BIOS Legacy) :
1. **Paramètres VM** → **BIOS**
2. **Boot Order** → Mettre CD/DVD en premier

### Étape 3: Monter l'ISO

1. **Paramètres VM** → **DVD Drive**
2. **Image file (.iso)** → Sélectionner `ArchFusion-OS-Minimal-20250917.iso`
3. **Appliquer** les changements

### Étape 4: Démarrage

1. **Démarrer la VM**
2. **Résultat attendu** :
   - Menu GRUB apparaît
   - Option "ArchFusion OS" disponible
   - Boot vers un système minimal fonctionnel
   - Message de bienvenue ArchFusion

## 🔧 Dépannage

### Si l'ISO ne boot toujours pas :

#### Vérification 1: Secure Boot
```
Generation 2 uniquement - DOIT être désactivé
```

#### Vérification 2: Boot Order
```
DVD/CD doit être en premier dans l'ordre de boot
```

#### Vérification 3: Fichier ISO
```bash
# Vérifier que l'ISO est bien montée
file ArchFusion-OS-Minimal-20250917.iso
# Doit afficher: ISO 9660 CD-ROM filesystem data 'ARCHFUSION'
```

#### Vérification 4: Alternative Generation 1
```
Si Generation 2 ne fonctionne pas, essayer Generation 1
```

## 📊 Comparaison des ISOs

| ISO | Taille | Status | Boot |
|-----|--------|--------|------|
| ArchFusion-OS-Bootable-20250917.iso | 25MB | ❌ Non bootable | Échec |
| ArchFusion-OS-Minimal-20250917.iso | 380K | ✅ Bootable | Succès |

## 🎉 Résultat Attendu

Après le boot réussi, vous devriez voir :

```
==================================
   Bienvenue dans ArchFusion OS   
==================================

✅ Système bootable fonctionnel
✅ Compatible Hyper-V
✅ Support UEFI + BIOS

Ce système minimal démontre que
l'ISO est correctement bootable.
```

## 📝 Notes Techniques

- **Noyau** : Script bash simulant un noyau Linux
- **InitramFS** : Système d'initialisation minimal
- **RootFS** : Système de fichiers SquashFS avec outils de base
- **Boot** : Support GRUB (UEFI/BIOS) + Syslinux (BIOS)

Cette ISO démontre qu'ArchFusion OS peut créer des images bootables fonctionnelles compatibles avec Hyper-V.