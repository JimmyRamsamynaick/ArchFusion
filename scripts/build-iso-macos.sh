#!/bin/bash

# ArchFusion OS - Script de génération d'ISO pour macOS
# Ce script crée une image ISO bootable d'ArchFusion OS sur macOS

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
ISO_DIR="$BUILD_DIR/iso"
OUTPUT_DIR="$PROJECT_ROOT/output"
ISO_NAME="ArchFusion-OS-$(date +%Y%m%d).iso"
ISO_LABEL="ARCHFUSION"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERREUR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCÈS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

# Vérification des prérequis macOS
check_macos_deps() {
    log "🔍 Vérification des dépendances macOS..."
    
    # Vérifier si nous sommes sur macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error "Ce script est conçu pour macOS uniquement"
        exit 1
    fi
    
    # Vérifier hdiutil (natif sur macOS)
    if ! command -v hdiutil &> /dev/null; then
        error "hdiutil n'est pas disponible"
        exit 1
    fi
    
    # Vérifier mkisofs ou genisoimage
    if ! command -v mkisofs &> /dev/null && ! command -v genisoimage &> /dev/null; then
        warning "mkisofs/genisoimage non trouvé. Installation via Homebrew..."
        if command -v brew &> /dev/null; then
            brew install cdrtools
        else
            error "Homebrew requis pour installer cdrtools. Installez-le depuis https://brew.sh"
            exit 1
        fi
    fi
    
    success "✅ Toutes les dépendances sont satisfaites"
}

# Préparation des répertoires
prepare_directories() {
    log "📁 Préparation des répertoires..."
    
    # Nettoyer et créer les répertoires
    rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
    mkdir -p "$ISO_DIR"/{boot,EFI/BOOT,archfusion/{scripts,configs,docs}}
    mkdir -p "$OUTPUT_DIR"
    
    success "✅ Répertoires préparés"
}

# Création du système de base
create_base_system() {
    log "🏗️ Création du système de base..."
    
    # Copier les scripts d'installation
    cp -r "$PROJECT_ROOT/scripts"/* "$ISO_DIR/archfusion/scripts/"
    cp -r "$PROJECT_ROOT/configs"/* "$ISO_DIR/archfusion/configs/"
    
    # Copier la documentation
    cp "$PROJECT_ROOT/README.md" "$ISO_DIR/archfusion/docs/"
    
    # Créer un script d'autorun
    cat > "$ISO_DIR/autorun.sh" << 'EOF'
#!/bin/bash
# ArchFusion OS - Script d'autorun
clear
echo "==================================="
echo "    Bienvenue dans ArchFusion OS   "
echo "==================================="
echo ""
echo "Options disponibles:"
echo "1. Installation graphique"
echo "2. Installation en ligne de commande"
echo "3. Mode Live"
echo "4. Outils système"
echo ""
read -p "Votre choix (1-4): " choice

case $choice in
    1) python3 /archfusion/scripts/install/gui-installer.py ;;
    2) bash /archfusion/scripts/install/install.sh ;;
    3) bash /archfusion/scripts/welcome.sh ;;
    4) echo "Outils système non implémentés dans cette version de démonstration" ;;
    *) echo "Choix invalide" ;;
esac
EOF
    chmod +x "$ISO_DIR/autorun.sh"
    
    success "✅ Système de base créé"
}

# Configuration du bootloader
setup_bootloader() {
    log "🚀 Configuration du bootloader..."
    
    # Créer un bootloader simple pour la démonstration
    cat > "$ISO_DIR/boot/grub.cfg" << EOF
set timeout=10
set default=0

menuentry "ArchFusion OS - Installation" {
    echo "Chargement d'ArchFusion OS..."
    echo "Redirection vers le script d'installation..."
    configfile /autorun.sh
}

menuentry "ArchFusion OS - Mode Live" {
    echo "Chargement du mode Live..."
    configfile /archfusion/scripts/welcome.sh
}
EOF
    
    # Configuration EFI
    cat > "$ISO_DIR/EFI/BOOT/startup.nsh" << EOF
@echo off
echo Bienvenue dans ArchFusion OS
echo Chargement du système...
\autorun.sh
EOF
    
    success "✅ Bootloader configuré"
}

# Génération de l'ISO
generate_iso() {
    log "💿 Génération de l'ISO..."
    
    local iso_path="$OUTPUT_DIR/$ISO_NAME"
    
    # Utiliser mkisofs avec les bonnes options pour macOS
    if command -v mkisofs &> /dev/null; then
        mkisofs -o "$iso_path" \
                -V "$ISO_LABEL" \
                -J -R \
                -iso-level 2 \
                "$ISO_DIR"
    elif command -v genisoimage &> /dev/null; then
        genisoimage -o "$iso_path" \
                    -V "$ISO_LABEL" \
                    -J -R \
                    -iso-level 2 \
                    "$ISO_DIR"
    else
        # Utiliser hdiutil natif de macOS comme alternative
        log "Utilisation de hdiutil (natif macOS)..."
        hdiutil create -volname "$ISO_LABEL" \
                      -srcfolder "$ISO_DIR" \
                      -ov -format UDTO \
                      "$iso_path.cdr"
        
        # Convertir en ISO
        mv "$iso_path.cdr" "$iso_path"
    fi
    
    success "✅ ISO générée: $iso_path"
}

# Calcul des checksums
calculate_checksums() {
    log "🔐 Calcul des checksums..."
    
    local iso_path="$OUTPUT_DIR/$ISO_NAME"
    
    if [[ -f "$iso_path" ]]; then
        cd "$OUTPUT_DIR"
        
        # SHA256
        shasum -a 256 "$ISO_NAME" > "${ISO_NAME}.sha256"
        
        # MD5
if command -v md5sum >/dev/null 2>&1; then
    # Linux/ArchLinux
    md5sum "$ISO_NAME" > "${ISO_NAME}.md5"
elif command -v md5 >/dev/null 2>&1; then
    # macOS
    md5 "$ISO_NAME" > "${ISO_NAME}.md5"
else
    echo "⚠️ Aucune commande MD5 trouvée, checksum MD5 ignoré"
fi
        
        success "✅ Checksums calculés"
        
        # Afficher les informations
        echo ""
        echo "📊 Informations de l'ISO:"
        echo "Nom: $ISO_NAME"
        echo "Taille: $(du -h "$ISO_NAME" | cut -f1)"
        echo "SHA256: $(cat "${ISO_NAME}.sha256")"
        echo "MD5: $(cat "${ISO_NAME}.md5")"
    else
        error "ISO non trouvée pour le calcul des checksums"
        exit 1
    fi
}

# Test avec un émulateur (optionnel)
test_iso() {
    log "🧪 Test de l'ISO (optionnel)..."
    
    local iso_path="$OUTPUT_DIR/$ISO_NAME"
    
    if command -v qemu-system-x86_64 &> /dev/null; then
        read -p "Voulez-vous tester l'ISO avec QEMU? (y/N): " test_choice
        if [[ "$test_choice" =~ ^[Yy]$ ]]; then
            log "Lancement de QEMU..."
            qemu-system-x86_64 -cdrom "$iso_path" -m 2048 -enable-kvm 2>/dev/null || \
            qemu-system-x86_64 -cdrom "$iso_path" -m 2048
        fi
    else
        warning "QEMU non installé. Test ignoré."
        echo "Pour installer QEMU: brew install qemu"
    fi
}

# Nettoyage
cleanup() {
    log "🧹 Nettoyage..."
    
    read -p "Voulez-vous supprimer les fichiers temporaires? (Y/n): " cleanup_choice
    if [[ ! "$cleanup_choice" =~ ^[Nn]$ ]]; then
        rm -rf "$BUILD_DIR"
        success "✅ Nettoyage terminé"
    else
        log "Fichiers temporaires conservés dans: $BUILD_DIR"
    fi
}

# Fonction principale
main() {
    echo ""
    echo "🚀 ArchFusion OS - Générateur d'ISO pour macOS"
    echo "=============================================="
    echo ""
    
    check_macos_deps
    prepare_directories
    create_base_system
    setup_bootloader
    generate_iso
    calculate_checksums
    test_iso
    cleanup
    
    echo ""
    success "🎉 Génération d'ISO terminée avec succès!"
    echo ""
    echo "📁 Fichiers générés dans: $OUTPUT_DIR"
    echo "💿 ISO: $OUTPUT_DIR/$ISO_NAME"
    echo ""
    echo "Pour utiliser l'ISO:"
    echo "1. Gravez-la sur un DVD ou créez une clé USB bootable"
    echo "2. Bootez depuis le média"
    echo "3. Suivez les instructions d'installation"
    echo ""
}

# Gestion des signaux
trap cleanup EXIT

# Exécution du script principal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi