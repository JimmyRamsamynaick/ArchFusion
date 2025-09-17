#!/bin/bash

# ArchFusion OS - Générateur d'ISO VRAIMENT Bootable
# Basé sur l'ISO Arch Linux officielle avec personnalisations ArchFusion

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/iso"
ISO_NAME="ArchFusion-OS-Bootable-$(date +%Y%m%d).iso"
WORK_DIR="/tmp/archfusion-real-$$"
ARCH_ISO_URL="https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso"
ARCH_ISO_PATH="$SCRIPT_DIR/archlinux-base.iso"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERREUR]${NC} $1" >&2; exit 1; }
success() { echo -e "${GREEN}[SUCCÈS]${NC} $1"; }
warning() { echo -e "${YELLOW}[ATTENTION]${NC} $1"; }

# Vérification des prérequis
check_deps() {
    log "🔍 Vérification des dépendances..."
    
    # Vérifier xorriso
    if ! command -v xorriso &> /dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            warning "xorriso manquant. Installation via Homebrew..."
            brew install xorriso || error "Impossible d'installer xorriso"
        else
            error "xorriso requis mais non trouvé"
        fi
    fi
    
    # Vérifier squashfs-tools
    if ! command -v unsquashfs &> /dev/null || ! command -v mksquashfs &> /dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            warning "squashfs-tools manquant. Installation via Homebrew..."
            brew install squashfs || error "Impossible d'installer squashfs"
        else
            error "squashfs-tools requis mais non trouvé"
        fi
    fi
    
    # Vérifier curl
    if ! command -v curl &> /dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            warning "curl manquant. Installation via Homebrew..."
            brew install curl || error "Impossible d'installer curl"
        else
            error "curl requis mais non trouvé"
        fi
    fi
    
    success "✅ Dépendances vérifiées"
}

# Télécharger l'ISO Arch Linux officielle
download_arch_iso() {
    if [[ ! -f "$ARCH_ISO_PATH" ]]; then
        log "⬇️ Téléchargement de l'ISO Arch Linux officielle..."
        curl -L -o "$ARCH_ISO_PATH" "$ARCH_ISO_URL" || error "Échec du téléchargement"
        success "✅ ISO Arch Linux téléchargée"
    else
        log "📀 ISO Arch Linux déjà présente"
    fi
}

# Extraire l'ISO Arch Linux
extract_arch_iso() {
    log "📦 Extraction de l'ISO Arch Linux..."
    
    rm -rf "$WORK_DIR"
    mkdir -p "$WORK_DIR"/{extract,custom,squashfs}
    
    # Monter l'ISO (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local mount_point="/tmp/arch_iso_mount_$$"
        mkdir -p "$mount_point"
        hdiutil attach "$ARCH_ISO_PATH" -mountpoint "$mount_point" -readonly
        cp -R "$mount_point"/* "$WORK_DIR/extract/"
        hdiutil detach "$mount_point"
        rmdir "$mount_point"
    else
        # Linux
        sudo mount -o loop "$ARCH_ISO_PATH" "$WORK_DIR/extract"
        cp -R "$WORK_DIR/extract"/* "$WORK_DIR/custom/"
        sudo umount "$WORK_DIR/extract"
    fi
    
    success "✅ ISO extraite"
}

# Extraire le système de fichiers racine
extract_rootfs() {
    log "🗂️ Extraction du système de fichiers racine..."
    
    local airootfs_sfs="$WORK_DIR/extract/arch/x86_64/airootfs.sfs"
    if [[ -f "$airootfs_sfs" ]]; then
        unsquashfs -d "$WORK_DIR/squashfs" "$airootfs_sfs"
        success "✅ Système de fichiers extrait"
    else
        error "Fichier airootfs.sfs non trouvé"
    fi
}

# Personnaliser le système
customize_system() {
    log "🎨 Personnalisation du système ArchFusion..."
    
    local rootfs="$WORK_DIR/squashfs"
    
    # Copier les configurations ArchFusion
    if [[ -d "$SCRIPT_DIR/archiso/airootfs" ]]; then
        cp -R "$SCRIPT_DIR/archiso/airootfs"/* "$rootfs/"
    fi
    
    # Installer les paquets ArchFusion
    if [[ -f "$SCRIPT_DIR/archiso/packages.x86_64" ]]; then
        log "📦 Installation des paquets ArchFusion..."
        
        # Créer un script d'installation dans le chroot
        cat > "$rootfs/install_packages.sh" << 'EOF'
#!/bin/bash
pacman-key --init
pacman-key --populate archlinux
pacman -Sy

# Lire et installer les paquets
while IFS= read -r package; do
    [[ "$package" =~ ^#.*$ ]] && continue
    [[ -z "$package" ]] && continue
    echo "Installation de $package..."
    pacman -S --noconfirm "$package" || echo "Échec: $package"
done < /packages.x86_64
EOF
        
        cp "$SCRIPT_DIR/archiso/packages.x86_64" "$rootfs/packages.x86_64"
        chmod +x "$rootfs/install_packages.sh"
        
        # Exécuter dans chroot (simulation pour macOS)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            warning "Installation des paquets simulée sur macOS"
        else
            sudo arch-chroot "$rootfs" /install_packages.sh
        fi
        
        rm -f "$rootfs/install_packages.sh" "$rootfs/packages.x86_64"
    fi
    
    # Configuration ArchFusion
    cat > "$rootfs/etc/os-release" << EOF
NAME="ArchFusion OS"
PRETTY_NAME="ArchFusion OS"
ID=archfusion
ID_LIKE=arch
BUILD_ID=$(date +%Y%m%d)
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://github.com/JimmyRamsamynaick/ArchFusion-OS"
DOCUMENTATION_URL="https://github.com/JimmyRamsamynaick/ArchFusion-OS/wiki"
SUPPORT_URL="https://github.com/JimmyRamsamynaick/ArchFusion-OS/issues"
BUG_REPORT_URL="https://github.com/JimmyRamsamynaick/ArchFusion-OS/issues"
LOGO=archfusion
EOF
    
    # Hostname
    echo "archfusion" > "$rootfs/etc/hostname"
    
    # Configuration réseau
    cat > "$rootfs/etc/systemd/network/20-ethernet.network" << EOF
[Match]
Name=en*

[Network]
DHCP=yes
EOF
    
    # Services par défaut
    mkdir -p "$rootfs/etc/systemd/system/multi-user.target.wants"
    ln -sf /usr/lib/systemd/system/NetworkManager.service "$rootfs/etc/systemd/system/multi-user.target.wants/"
    ln -sf /usr/lib/systemd/system/sshd.service "$rootfs/etc/systemd/system/multi-user.target.wants/"
    
    success "✅ Système personnalisé"
}

# Configurer le bootloader GRUB
configure_grub() {
    log "🥾 Configuration du bootloader GRUB..."
    
    local boot_dir="$WORK_DIR/custom/boot"
    local grub_dir="$boot_dir/grub"
    
    mkdir -p "$grub_dir"
    
    # Configuration GRUB principale
    cat > "$grub_dir/grub.cfg" << 'EOF'
# ArchFusion OS GRUB Configuration
# Compatible UEFI et BIOS

set timeout=30
set default=0

# Variables
set iso_label="ARCHFUSION"
set install_dir="arch"

# Entrée principale ArchFusion OS
menuentry "ArchFusion OS (x86_64)" --class archfusion --class gnu-linux --class gnu --class os {
    set gfxpayload=keep
    linux /%install_dir%/boot/x86_64/vmlinuz-linux archisobasedir=%install_dir% archisolabel=%iso_label% cow_spacesize=1G copytoram=n
    initrd /%install_dir%/boot/x86_64/initramfs-linux.img
}

# Mode sans échec
menuentry "ArchFusion OS (Safe Mode)" --class archfusion --class gnu-linux --class gnu --class os {
    set gfxpayload=keep
    linux /%install_dir%/boot/x86_64/vmlinuz-linux archisobasedir=%install_dir% archisolabel=%iso_label% nomodeset nouveau.modeset=0 radeon.modeset=0 i915.modeset=0
    initrd /%install_dir%/boot/x86_64/initramfs-linux.img
}

# Mode RAM
menuentry "ArchFusion OS (Copy to RAM)" --class archfusion --class gnu-linux --class gnu --class os {
    set gfxpayload=keep
    linux /%install_dir%/boot/x86_64/vmlinuz-linux archisobasedir=%install_dir% archisolabel=%iso_label% copytoram=y
    initrd /%install_dir%/boot/x86_64/initramfs-linux.img
}

# Outils système
submenu "Outils système" {
    menuentry "Test mémoire (Memtest86+)" {
        linux16 /boot/memtest86+/memtest.bin
    }
    
    menuentry "Détection matériel (HDT)" {
        linux /boot/syslinux/hdt.c32
    }
}

# Redémarrage et arrêt
menuentry "Redémarrer" --class restart {
    reboot
}

menuentry "Arrêter" --class shutdown {
    halt
}
EOF

    # Configuration EFI
    mkdir -p "$WORK_DIR/custom/EFI/BOOT"
    
    # Copier GRUB EFI depuis l'ISO Arch
    if [[ -f "$WORK_DIR/extract/EFI/BOOT/BOOTX64.EFI" ]]; then
        cp "$WORK_DIR/extract/EFI/BOOT/BOOTX64.EFI" "$WORK_DIR/custom/EFI/BOOT/"
    fi
    
    success "✅ GRUB configuré"
}

# Recréer le système de fichiers
rebuild_rootfs() {
    log "🔄 Reconstruction du système de fichiers..."
    
    local output_sfs="$WORK_DIR/custom/arch/x86_64/airootfs.sfs"
    mkdir -p "$(dirname "$output_sfs")"
    
    mksquashfs "$WORK_DIR/squashfs" "$output_sfs" \
        -comp xz -Xbcj x86 -b 1M -Xdict-size 1M \
        -noappend -no-exports -no-recovery
    
    success "✅ Système de fichiers reconstruit"
}

# Créer l'ISO finale
create_iso() {
    log "💿 Création de l'ISO finale..."
    
    mkdir -p "$OUTPUT_DIR"
    
    xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "ARCHFUSION" \
        -appid "ArchFusion OS Live/Rescue CD" \
        -publisher "ArchFusion Team" \
        -preparer "ArchFusion Build System" \
        -eltorito-boot isolinux/isolinux.bin \
        -eltorito-catalog isolinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -eltorito-alt-boot \
        -e EFI/BOOT/BOOTX64.EFI \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
        -output "$OUTPUT_DIR/$ISO_NAME" \
        "$WORK_DIR/custom"
    
    success "✅ ISO créée: $OUTPUT_DIR/$ISO_NAME"
}

# Génération des checksums
generate_checksums() {
    log "🔐 Génération des checksums..."
    
    cd "$OUTPUT_DIR"
    
    # MD5
    md5sum "$ISO_NAME" > "$ISO_NAME.md5"
    
    # SHA256
    sha256sum "$ISO_NAME" > "$ISO_NAME.sha256"
    
    success "✅ Checksums générés"
}

# Nettoyage
cleanup() {
    log "🧹 Nettoyage..."
    rm -rf "$WORK_DIR"
    success "✅ Nettoyage terminé"
}

# Fonction principale
main() {
    log "🚀 Démarrage de la construction ArchFusion OS..."
    
    check_deps
    download_arch_iso
    extract_arch_iso
    extract_rootfs
    customize_system
    configure_grub
    rebuild_rootfs
    create_iso
    generate_checksums
    cleanup
    
    success "🎉 ArchFusion OS ISO créée avec succès !"
    log "📍 Fichier: $OUTPUT_DIR/$ISO_NAME"
    log "📊 Taille: $(du -h "$OUTPUT_DIR/$ISO_NAME" | cut -f1)"
}

# Gestion des signaux
trap cleanup EXIT

# Exécution
main "$@"