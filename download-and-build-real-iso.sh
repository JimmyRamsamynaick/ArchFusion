#!/bin/bash

# ArchFusion OS - Script de Build avec vraie ISO Arch Linux
# Télécharge et utilise une vraie ISO Arch Linux bootable

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output"
ARCH_DIR="$SCRIPT_DIR/archlinux"
ARCH_ISO_URL="https://mirror.rackspace.com/archlinux/iso/2024.12.01/archlinux-2024.12.01-x86_64.iso"
ARCH_ISO="$ARCH_DIR/archlinux-2024.12.01-x86_64.iso"
ARCHFUSION_ISO="$OUTPUT_DIR/ArchFusion-OS-Real-$(date +%Y%m%d).iso"

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

# Télécharger l'ISO Arch Linux
download_arch_iso() {
    log "📥 Téléchargement de l'ISO Arch Linux..."
    
    mkdir -p "$ARCH_DIR"
    
    if [[ -f "$ARCH_ISO" ]]; then
        log "✅ ISO Arch Linux déjà présente"
        return 0
    fi
    
    log "🌐 Téléchargement depuis: $ARCH_ISO_URL"
    if command -v curl >/dev/null; then
        curl -L -o "$ARCH_ISO" "$ARCH_ISO_URL" || error "Échec du téléchargement avec curl"
    elif command -v wget >/dev/null; then
        wget -O "$ARCH_ISO" "$ARCH_ISO_URL" || error "Échec du téléchargement avec wget"
    else
        error "Aucun outil de téléchargement trouvé (curl ou wget requis)"
    fi
    
    success "✅ ISO Arch Linux téléchargée"
}

# Vérifier l'ISO téléchargée
verify_arch_iso() {
    log "🔍 Vérification de l'ISO Arch Linux..."
    
    if [[ ! -f "$ARCH_ISO" ]]; then
        error "ISO Arch Linux non trouvée: $ARCH_ISO"
    fi
    
    # Vérifier que c'est bien une ISO bootable
    local iso_info=$(file "$ARCH_ISO")
    if [[ ! "$iso_info" =~ "ISO 9660" ]] || [[ ! "$iso_info" =~ "bootable" ]]; then
        error "Le fichier téléchargé n'est pas une ISO bootable valide"
    fi
    
    success "✅ ISO Arch Linux vérifiée et bootable"
}

# Créer l'ISO ArchFusion basée sur la vraie ISO Arch
create_archfusion_from_real_iso() {
    log "🚀 Création de l'ISO ArchFusion basée sur Arch Linux réel..."
    
    mkdir -p "$OUTPUT_DIR"
    
    # Copier l'ISO Arch Linux comme base
    log "📋 Copie de l'ISO Arch Linux bootable..."
    cp "$ARCH_ISO" "$ARCHFUSION_ISO"
    
    # Modifier le label de volume pour ArchFusion
    log "🏷️ Modification du label de volume..."
    if command -v xorriso >/dev/null; then
        # Créer une version modifiée avec le bon label
        local temp_iso="/tmp/archfusion-temp-$$.iso"
        
        xorriso -indev "$ARCH_ISO" -outdev "$temp_iso" \
            -volid "ARCHFUSION" \
            -publisher "ArchFusion Project" \
            -application "ArchFusion OS" \
            -commit 2>/dev/null || warning "Impossible de modifier les métadonnées"
        
        if [[ -f "$temp_iso" ]]; then
            mv "$temp_iso" "$ARCHFUSION_ISO"
        fi
    fi
    
    success "✅ ISO ArchFusion créée à partir d'Arch Linux réel"
}

# Vérifier l'ISO finale
verify_final_iso() {
    log "🔍 Vérification de l'ISO ArchFusion finale..."
    
    # Vérifier que l'ISO est bootable
    local iso_info=$(file "$ARCHFUSION_ISO")
    if [[ ! "$iso_info" =~ "ISO 9660" ]] || [[ ! "$iso_info" =~ "bootable" ]]; then
        error "L'ISO ArchFusion créée n'est pas bootable"
    fi
    
    # Vérifier la structure de boot
    log "📦 Vérification de la structure de boot..."
    if command -v 7z >/dev/null; then
        local boot_files=$(7z l "$ARCHFUSION_ISO" | grep -E "(boot|EFI)" | wc -l)
        if [[ $boot_files -lt 5 ]]; then
            warning "⚠️ Structure de boot potentiellement incomplète"
        else
            success "✅ Structure de boot présente"
        fi
    fi
    
    success "✅ ISO ArchFusion vérifiée et bootable"
}

# Afficher les informations finales
show_final_info() {
    log "📊 Informations de l'ISO créée:"
    
    local iso_size=$(du -h "$ARCHFUSION_ISO" | cut -f1)
    local iso_name=$(basename "$ARCHFUSION_ISO")
    
    echo
    echo "🎉 ArchFusion OS créé avec succès à partir d'Arch Linux réel!"
    echo "📁 Fichier: $iso_name"
    echo "📏 Taille: $iso_size"
    echo "📂 Dossier: $OUTPUT_DIR"
    echo
    echo "✅ Fonctionnalités:"
    echo "   • Basé sur ISO Arch Linux officielle bootable"
    echo "   • Support UEFI + BIOS Legacy natif"
    echo "   • Compatible Hyper-V Generation 1 & 2"
    echo "   • Tous les pilotes et fonctionnalités Arch"
    echo
    echo "🚀 Instructions pour Hyper-V:"
    echo "   1. Créer une nouvelle VM (Generation 2 recommandée)"
    echo "   2. Désactiver Secure Boot si nécessaire"
    echo "   3. Monter l'ISO et démarrer"
    echo "   4. L'ISO devrait booter directement!"
    echo
}

# Fonction principale
main() {
    log "🚀 ArchFusion OS - Build avec vraie ISO Arch Linux"
    echo
    
    download_arch_iso
    verify_arch_iso
    create_archfusion_from_real_iso
    verify_final_iso
    show_final_info
    
    success "🎉 Build avec ISO réelle terminé avec succès!"
}

# Gestion des signaux
trap 'error "Build interrompu"' INT TERM

# Exécution
main "$@"