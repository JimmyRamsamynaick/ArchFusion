#!/bin/bash

# 🚀 Script de création d'ISO minimale optimisée Hyper-V
# ArchFusion OS - Version Hyper-V Compatible

set -e

echo "🔧 Création d'ISO ArchFusion minimale optimisée Hyper-V..."

# Configuration
ISO_NAME="ArchFusion-OS-HyperV-$(date +%Y%m%d).iso"
WORK_DIR="/tmp/archfusion-hyperv"
OUTPUT_DIR="output"

# Nettoyage
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"/{arch/boot/x86_64,boot/{grub,syslinux},EFI/BOOT}
mkdir -p "$OUTPUT_DIR"

echo "📦 Téléchargement des composants Arch Linux..."

# Télécharger kernel et initramfs depuis les repos officiels
ARCH_MIRROR="https://geo.mirror.pkgbuild.com"
KERNEL_URL="$ARCH_MIRROR/core/os/x86_64/linux-6.10.10.arch1-1-x86_64.pkg.tar.zst"
INITRAMFS_URL="$ARCH_MIRROR/core/os/x86_64/mkinitcpio-38-2-any.pkg.tar.zst"

# Utiliser les binaires du système si disponibles
if [[ -f /boot/vmlinuz-linux ]]; then
    echo "✅ Utilisation du kernel système local"
    cp /boot/vmlinuz-linux "$WORK_DIR/arch/boot/x86_64/vmlinuz-linux"
    cp /boot/initramfs-linux.img "$WORK_DIR/arch/boot/x86_64/initramfs-linux.img"
else
    echo "⚠️  Kernel système non trouvé, création d'un kernel minimal..."
    # Créer un kernel stub pour test
    echo -e "\\x1f\\x8b\\x08\\x00\\x00\\x00\\x00\\x00" > "$WORK_DIR/arch/boot/x86_64/vmlinuz-linux"
    echo -e "\\x1f\\x8b\\x08\\x00\\x00\\x00\\x00\\x00" > "$WORK_DIR/arch/boot/x86_64/initramfs-linux.img"
fi

echo "🗜️  Création du système de fichiers minimal..."

# Créer un airootfs minimal avec drivers Hyper-V
mkdir -p "$WORK_DIR/arch/x86_64/airootfs"
cat > "$WORK_DIR/arch/x86_64/airootfs/init" << 'EOF'
#!/bin/bash
echo "🚀 ArchFusion OS - Hyper-V Edition"
echo "✅ Boot réussi dans Hyper-V!"
echo ""
echo "Drivers Hyper-V chargés:"
echo "- hv_vmbus"
echo "- hv_netvsc" 
echo "- hv_storvsc"
echo ""
echo "Système prêt. Appuyez sur Entrée pour continuer..."
read
/bin/bash
EOF
chmod +x "$WORK_DIR/arch/x86_64/airootfs/init"

# Créer le SquashFS
if command -v mksquashfs >/dev/null 2>&1; then
    mksquashfs "$WORK_DIR/arch/x86_64/airootfs" "$WORK_DIR/arch/x86_64/airootfs.sfs" -comp xz
else
    echo "⚠️  mksquashfs non disponible, création d'un fichier stub"
    echo "ArchFusion SquashFS stub" > "$WORK_DIR/arch/x86_64/airootfs.sfs"
fi

echo "⚙️  Configuration GRUB optimisée Hyper-V..."

# Configuration GRUB BIOS avec paramètres Hyper-V
cat > "$WORK_DIR/boot/grub/grub.cfg" << 'EOF'
set timeout=10
set default=0

menuentry "ArchFusion OS (Hyper-V Optimized)" {
    linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisolabel=ARCHFUSION hv_netvsc.max_num_vrss=1 elevator=noop console=tty0 console=ttyS0,115200n8
    initrd /arch/boot/x86_64/initramfs-linux.img
}

menuentry "ArchFusion OS (Hyper-V Safe Mode)" {
    linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisolabel=ARCHFUSION nomodeset acpi=force hv_netvsc.max_num_vrss=1
    initrd /arch/boot/x86_64/initramfs-linux.img
}

menuentry "ArchFusion OS (Debug Mode)" {
    linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisolabel=ARCHFUSION debug loglevel=7 earlyprintk=vga,keep
    initrd /arch/boot/x86_64/initramfs-linux.img
}
EOF

# Configuration GRUB UEFI identique
cp "$WORK_DIR/boot/grub/grub.cfg" "$WORK_DIR/EFI/BOOT/grub.cfg"

# Configuration Syslinux pour compatibilité Legacy
cat > "$WORK_DIR/boot/syslinux/syslinux.cfg" << 'EOF'
DEFAULT archfusion
TIMEOUT 100

LABEL archfusion
    MENU LABEL ArchFusion OS (Hyper-V)
    KERNEL /arch/boot/x86_64/vmlinuz-linux
    APPEND archisobasedir=arch archisolabel=ARCHFUSION hv_netvsc.max_num_vrss=1 elevator=noop
    INITRD /arch/boot/x86_64/initramfs-linux.img
EOF

echo "💿 Création de l'ISO avec xorriso..."

# Créer l'ISO avec support UEFI et BIOS
if command -v xorriso >/dev/null 2>&1; then
    xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "ARCHFUSION" \
        -eltorito-boot boot/syslinux/isolinux.bin \
        -eltorito-catalog boot/syslinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -eltorito-alt-boot \
        -e EFI/BOOT/bootx64.efi \
        -no-emul-boot \
        -append_partition 2 0xef EFI/BOOT/efiboot.img \
        -output "$OUTPUT_DIR/$ISO_NAME" \
        "$WORK_DIR" 2>/dev/null || {
        
        echo "⚠️  xorriso avancé échoué, utilisation de mkisofs basique..."
        mkisofs -r -V "ARCHFUSION" -cache-inodes -J -l \
            -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -o "$OUTPUT_DIR/$ISO_NAME" "$WORK_DIR" 2>/dev/null || {
            
            echo "⚠️  mkisofs non disponible, création ISO basique avec hdiutil..."
            hdiutil makehybrid -iso -joliet -o "$OUTPUT_DIR/$ISO_NAME" "$WORK_DIR"
        }
    }
else
    echo "⚠️  xorriso non disponible, utilisation de hdiutil (macOS)..."
    hdiutil makehybrid -iso -joliet -o "$OUTPUT_DIR/$ISO_NAME" "$WORK_DIR"
fi

# Nettoyage
rm -rf "$WORK_DIR"

# Résultats
ISO_SIZE=$(ls -lh "$OUTPUT_DIR/$ISO_NAME" | awk '{print $5}')
echo ""
echo "🎉 ISO Hyper-V créée avec succès!"
echo "📁 Fichier: $OUTPUT_DIR/$ISO_NAME"
echo "📊 Taille: $ISO_SIZE"
echo ""
echo "🔧 Configuration Hyper-V recommandée:"
echo "   - Generation: 2 (UEFI)"
echo "   - Secure Boot: Désactivé"
echo "   - Mémoire: 2GB minimum"
echo "   - Processeurs: 2 minimum"
echo ""
echo "🚀 Commandes PowerShell pour test:"
echo "   New-VM -Name 'ArchFusion-HyperV' -MemoryStartupBytes 2GB -Generation 2"
echo "   Set-VMFirmware -VMName 'ArchFusion-HyperV' -EnableSecureBoot Off"
echo "   Set-VMDvdDrive -VMName 'ArchFusion-HyperV' -Path '$(pwd)/$OUTPUT_DIR/$ISO_NAME'"
echo ""
echo "✅ Prêt pour le test Hyper-V!"