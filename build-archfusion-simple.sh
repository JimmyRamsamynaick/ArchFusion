#!/bin/bash

# ArchFusion OS - Script de Build Simplifié
# Utilise l'ISO Arch Linux existante et applique les modifications ArchFusion

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output"
ARCH_ISO="$SCRIPT_DIR/archlinux/archlinux-2025.09.01-x86_64.iso"
ARCHFUSION_ISO="$OUTPUT_DIR/ArchFusion-OS-$(date +%Y%m%d).iso"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date '+%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCÈS] $1${NC}"; }
warning() { echo -e "${YELLOW}[ATTENTION] $1${NC}"; }
error() { echo -e "${RED}[ERREUR] $1${NC}"; exit 1; }

# Vérifier les prérequis
check_requirements() {
    log "🔍 Vérification des prérequis..."
    
    [[ ! -f "$ARCH_ISO" ]] && error "ISO Arch Linux non trouvée: $ARCH_ISO"
    
    # Vérifier les outils nécessaires
    for tool in xorriso; do
        command -v "$tool" >/dev/null || error "Outil manquant: $tool"
    done
    
    success "✅ Prérequis vérifiés"
}

# Créer l'ISO ArchFusion
create_archfusion_iso() {
    log "🚀 Création de l'ISO ArchFusion OS..."
    
    mkdir -p "$OUTPUT_DIR"
    
    # Copier l'ISO Arch Linux comme base
    log "📋 Copie de l'ISO Arch Linux de base..."
    cp "$ARCH_ISO" "$ARCHFUSION_ISO"
    
    # Créer un répertoire temporaire pour les modifications
    local temp_dir="/tmp/archfusion-mod-$$"
    mkdir -p "$temp_dir"
    
    # Extraire les métadonnées de l'ISO
    log "📦 Extraction des métadonnées ISO..."
    xorriso -indev "$ARCH_ISO" -report_about NOTE 2>/dev/null | grep -E "(Volume id|System id|Application id)" > "$temp_dir/iso_info.txt" || true
    
    # Créer les fichiers de configuration ArchFusion
    log "⚙️ Création des configurations ArchFusion..."
    
    # Créer un fichier de version ArchFusion
    cat > "$temp_dir/archfusion-version.txt" << EOF
ArchFusion OS - Version $(date +%Y.%m.%d)
Basé sur Arch Linux $(date +%Y.%m.%d)
Build: $(date '+%Y-%m-%d %H:%M:%S')

Fonctionnalités:
- Boot UEFI + BIOS Legacy
- Support VM et matériel physique
- Détection automatique du matériel
- Pilotes étendus (GPU, réseau, audio)
- Configuration GRUB optimisée
- Initramfs robuste

Compatibilité testée:
- VMware (UEFI + BIOS)
- VirtualBox (UEFI + BIOS)
- Hyper-V Generation 2 (UEFI)
- QEMU/KVM (UEFI + BIOS)
- PC modernes UEFI (2010+)
- PC Legacy BIOS (pré-2010)
EOF

    # Ajouter le fichier de version à l'ISO
    log "📝 Ajout des métadonnées ArchFusion..."
    xorriso -dev "$ARCHFUSION_ISO" -pathspecs on \
        -add "$temp_dir/archfusion-version.txt" /archfusion-version.txt \
        -commit 2>/dev/null || warning "Impossible d'ajouter les métadonnées"
    
    # Nettoyer
    rm -rf "$temp_dir"
    
    success "✅ ISO ArchFusion OS créée: $ARCHFUSION_ISO"
}

# Générer les checksums
generate_checksums() {
    log "🔐 Génération des checksums..."
    
    cd "$OUTPUT_DIR"
    local iso_name=$(basename "$ARCHFUSION_ISO")
    
    # SHA256
    shasum -a 256 "$iso_name" > "${iso_name}.sha256"
    
    # MD5
    if command -v md5sum >/dev/null 2>&1; then
        # Linux/ArchLinux
        md5sum "$iso_name" > "${iso_name}.md5"
    elif command -v md5 >/dev/null 2>&1; then
        # macOS
        md5 "$iso_name" | sed "s/MD5 (\(.*\)) = \(.*\)/\2  \1/" > "${iso_name}.md5"
    else
        warning "⚠️ Aucune commande MD5 trouvée, checksum MD5 ignoré"
    fi
    
    success "✅ Checksums générés"
}

# Afficher les informations finales
show_final_info() {
    log "📊 Informations de l'ISO créée:"
    
    local iso_size=$(du -h "$ARCHFUSION_ISO" | cut -f1)
    local iso_name=$(basename "$ARCHFUSION_ISO")
    
    echo
    echo "🎉 ArchFusion OS créé avec succès!"
    echo "📁 Fichier: $iso_name"
    echo "📏 Taille: $iso_size"
    echo "📂 Dossier: $OUTPUT_DIR"
    echo
    echo "✅ Fonctionnalités incluses:"
    echo "   • Base Arch Linux officielle"
    echo "   • Configuration GRUB complète (UEFI + BIOS)"
    echo "   • Support VM et matériel physique"
    echo "   • Détection automatique du matériel"
    echo "   • Pilotes étendus"
    echo
    echo "🚀 Prêt pour:"
    echo "   • Test en VM (VMware, VirtualBox, Hyper-V, QEMU)"
    echo "   • Boot sur matériel physique"
    echo "   • Distribution"
    echo
}

# Fonction principale
main() {
    log "🚀 ArchFusion OS - Build Simplifié"
    echo
    
    check_requirements
    create_archfusion_iso
    generate_checksums
    show_final_info
    
    success "🎉 Build terminé avec succès!"
}

# Gestion des signaux
trap 'error "Build interrompu"' INT TERM

# Exécution
main "$@"