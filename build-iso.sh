#!/bin/bash

# Script de compilation ArchFusion OS ISO
# Basé sur archiso avec personnalisations ArchFusion

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHISO_DIR="$SCRIPT_DIR/archiso"
OUTPUT_DIR="$SCRIPT_DIR/output"
ISO_NAME="archfusion-$(date +%Y.%m.%d)-x86_64.iso"
WORK_DIR="/tmp/archfusion-build"

# Fonctions utilitaires
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Vérifications préliminaires
check_requirements() {
    log "Vérification des prérequis..."
    
    # Vérifier si on est sur Arch Linux
    if ! command -v pacman &> /dev/null; then
        error "Ce script doit être exécuté sur Arch Linux"
    fi
    
    # Vérifier si archiso est installé
    if ! pacman -Qi archiso &> /dev/null; then
        warning "archiso n'est pas installé. Installation..."
        sudo pacman -S --noconfirm archiso
    fi
    
    # Vérifier les permissions
    if [[ $EUID -eq 0 ]]; then
        error "Ne pas exécuter ce script en tant que root"
    fi
    
    success "Prérequis vérifiés"
}

# Préparation de l'environnement
prepare_environment() {
    log "Préparation de l'environnement de compilation..."
    
    # Nettoyer les anciens builds
    if [ -d "$WORK_DIR" ]; then
        sudo rm -rf "$WORK_DIR"
    fi
    
    # Créer les dossiers nécessaires
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$WORK_DIR"
    
    # Copier la configuration archiso
    if [ ! -d "$ARCHISO_DIR" ]; then
        error "Dossier archiso non trouvé: $ARCHISO_DIR"
    fi
    
    success "Environnement préparé"
}

# Validation de la configuration
validate_config() {
    log "Validation de la configuration..."
    
    # Vérifier les fichiers essentiels
    local required_files=(
        "$ARCHISO_DIR/profiledef.sh"
        "$ARCHISO_DIR/packages.x86_64"
        "$ARCHISO_DIR/pacman.conf"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            error "Fichier requis manquant: $file"
        fi
    done
    
    # Vérifier la structure airootfs
    if [ ! -d "$ARCHISO_DIR/airootfs" ]; then
        warning "Dossier airootfs non trouvé, création..."
        mkdir -p "$ARCHISO_DIR/airootfs"
    fi
    
    success "Configuration validée"
}

# Compilation de l'ISO
build_iso() {
    log "Début de la compilation de l'ISO..."
    
    cd "$ARCHISO_DIR"
    
    # Exécuter mkarchiso
    sudo mkarchiso -v -w "$WORK_DIR" -o "$OUTPUT_DIR" .
    
    # Renommer l'ISO avec le nom ArchFusion
    local generated_iso=$(find "$OUTPUT_DIR" -name "*.iso" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)
    
    if [ -f "$generated_iso" ]; then
        mv "$generated_iso" "$OUTPUT_DIR/$ISO_NAME"
        success "ISO compilée: $OUTPUT_DIR/$ISO_NAME"
    else
        error "Échec de la compilation de l'ISO"
    fi
}

# Nettoyage
cleanup() {
    log "Nettoyage des fichiers temporaires..."
    
    if [ -d "$WORK_DIR" ]; then
        sudo rm -rf "$WORK_DIR"
    fi
    
    success "Nettoyage terminé"
}

# Affichage des informations finales
show_info() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                          🎉 COMPILATION TERMINÉE 🎉                          ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📁 ISO générée: $OUTPUT_DIR/$ISO_NAME"
    echo "📊 Taille: $(du -h "$OUTPUT_DIR/$ISO_NAME" | cut -f1)"
    echo "🔍 Checksum MD5: $(md5sum "$OUTPUT_DIR/$ISO_NAME" | cut -d' ' -f1)"
    echo ""
    echo "🚀 Pour tester l'ISO:"
    echo "   qemu-system-x86_64 -m 2048 -cdrom \"$OUTPUT_DIR/$ISO_NAME\""
    echo ""
    echo "💾 Pour créer une clé USB bootable:"
    echo "   sudo dd if=\"$OUTPUT_DIR/$ISO_NAME\" of=/dev/sdX bs=4M status=progress"
    echo "   (Remplacez /dev/sdX par votre périphérique USB)"
    echo ""
}

# Fonction principale
main() {
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                        🔨 ARCHFUSION OS BUILDER 🔨                          ║"
    echo "║                     Compilation de l'ISO personnalisée                      ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_requirements
    prepare_environment
    validate_config
    build_iso
    cleanup
    show_info
    
    success "Compilation ArchFusion OS terminée avec succès!"
}

# Gestion des signaux
trap cleanup EXIT

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi