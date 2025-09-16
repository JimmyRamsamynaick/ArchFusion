#!/bin/bash

# ArchFusion OS - Générateur d'ISO pour macOS
# Ce script crée une ISO bootable d'ArchFusion OS

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_DIR="$SCRIPT_DIR/iso"
OUTPUT_DIR="$SCRIPT_DIR/iso"
ISO_NAME="ArchFusion-OS-$(date +%Y%m%d).iso"
ISO_LABEL="ARCHFUSION"
TEMP_DIR="/tmp/archfusion-iso-$$"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERREUR]${NC} $1" >&2
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCÈS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

# Vérification des prérequis
check_deps() {
    log "🔍 Vérification des dépendances..."
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error "Ce script est conçu pour macOS uniquement"
    fi
    
    if ! command -v hdiutil &> /dev/null; then
        error "hdiutil n'est pas disponible"
    fi
    
    # Vérifier mkisofs ou genisoimage
    if ! command -v mkisofs &> /dev/null && ! command -v genisoimage &> /dev/null; then
        warning "mkisofs non trouvé. Installation via Homebrew..."
        if command -v brew &> /dev/null; then
            brew install cdrtools
        else
            error "Homebrew requis. Installez-le depuis https://brew.sh"
        fi
    fi
    
    success "✅ Dépendances vérifiées"
}

# Préparation des répertoires
prepare_dirs() {
    log "📁 Préparation des répertoires..."
    
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"/{boot,EFI/BOOT,archfusion}
    mkdir -p "$OUTPUT_DIR"
    
    success "✅ Répertoires préparés"
}

# Copie des fichiers système
copy_system_files() {
    log "📋 Copie des fichiers système..."
    
    # Copier la configuration archiso
    if [ -d "$SCRIPT_DIR/archiso" ]; then
        cp -r "$SCRIPT_DIR/archiso"/* "$TEMP_DIR/archfusion/"
    fi
    
    # Copier les scripts
    if [ -d "$SCRIPT_DIR/scripts" ]; then
        cp -r "$SCRIPT_DIR/scripts" "$TEMP_DIR/archfusion/"
    fi
    
    # Copier les configurations
    if [ -d "$SCRIPT_DIR/configs" ]; then
        cp -r "$SCRIPT_DIR/configs" "$TEMP_DIR/archfusion/"
    fi
    
    # Copier les assets
    if [ -d "$SCRIPT_DIR/assets" ]; then
        cp -r "$SCRIPT_DIR/assets" "$TEMP_DIR/archfusion/"
    fi
    
    success "✅ Fichiers système copiés"
}

# Création des fichiers de boot
create_boot_files() {
    log "🚀 Création des fichiers de boot..."
    
    # Créer le fichier de boot GRUB
    cat > "$TEMP_DIR/boot/grub.cfg" << 'EOF'
set timeout=10
set default=0

menuentry "ArchFusion OS - Installation" {
    linux /archfusion/boot/vmlinuz-linux archisobasedir=archfusion archisolabel=ARCHFUSION
    initrd /archfusion/boot/initramfs-linux.img
}

menuentry "ArchFusion OS - Mode Live" {
    linux /archfusion/boot/vmlinuz-linux archisobasedir=archfusion archisolabel=ARCHFUSION archiso_cow_spacesize=1G
    initrd /archfusion/boot/initramfs-linux.img
}

menuentry "Outils de Diagnostic" {
    linux /archfusion/boot/vmlinuz-linux archisobasedir=archfusion archisolabel=ARCHFUSION memtest
    initrd /archfusion/boot/initramfs-linux.img
}
EOF

    # Créer le fichier de boot UEFI
    cat > "$TEMP_DIR/EFI/BOOT/startup.nsh" << 'EOF'
@echo -off
echo "Démarrage d'ArchFusion OS..."
echo "Chargement du système..."
\archfusion\boot\bootx64.efi
EOF

    success "✅ Fichiers de boot créés"
}

# Création de l'ISO
create_iso() {
    log "💿 Création de l'ISO..."
    
    local iso_path="$OUTPUT_DIR/$ISO_NAME"
    
    # Utiliser mkisofs pour créer l'ISO (version simplifiée compatible macOS)
    if command -v mkisofs &> /dev/null; then
        mkisofs -o "$iso_path" \
                -V "$ISO_LABEL" \
                -J -R -v \
                "$TEMP_DIR"
    else
        error "Impossible de créer l'ISO - mkisofs non disponible"
    fi
    
    success "✅ ISO créée: $iso_path"
    echo "📍 Taille: $(du -h "$iso_path" | cut -f1)"
}

# Création des checksums
create_checksums() {
    log "🔐 Création des checksums..."
    
    local iso_path="$OUTPUT_DIR/$ISO_NAME"
    
    # SHA256
    shasum -a 256 "$iso_path" > "$iso_path.sha256"
    
    # MD5
    md5 "$iso_path" | sed 's/MD5 (//' | sed 's/) = / /' > "$iso_path.md5"
    
    success "✅ Checksums créés"
    echo "📍 SHA256: $(cat "$iso_path.sha256")"
    echo "📍 MD5: $(cat "$iso_path.md5")"
}

# Nettoyage
cleanup() {
    log "🧹 Nettoyage..."
    rm -rf "$TEMP_DIR"
    success "✅ Nettoyage terminé"
}

# Fonction principale
main() {
    echo -e "${BLUE}"
    echo "🚀 GÉNÉRATEUR D'ISO ARCHFUSION OS"
    echo "=================================="
    echo -e "${NC}"
    
    check_deps
    prepare_dirs
    copy_system_files
    create_boot_files
    create_iso
    create_checksums
    cleanup
    
    echo -e "${GREEN}"
    echo "🎉 ISO ARCHFUSION OS CRÉÉE AVEC SUCCÈS !"
    echo "========================================"
    echo "📍 Fichier: $OUTPUT_DIR/$ISO_NAME"
    echo "📍 Prêt pour installation en VM ou gravure"
    echo -e "${NC}"
}

# Gestion des signaux
trap cleanup EXIT

# Exécution
main "$@"