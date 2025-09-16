#!/bin/bash

# ArchFusion OS - Script d'Installation Principal
# Auteur: Jimmy Ramsamynaick
# Version: 1.0.0
# Description: Installation automatisée d'ArchFusion OS

set -euo pipefail

# ==========================================
# CONFIGURATION ET VARIABLES
# ==========================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly LOG_FILE="/tmp/archfusion-install.log"
readonly CONFIG_FILE="${PROJECT_ROOT}/configs/install.conf"

# Couleurs pour l'affichage
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Variables d'installation
INSTALL_MODE="auto"
TARGET_DISK=""
USERNAME=""
HOSTNAME="archfusion"
TIMEZONE="Europe/Paris"
LOCALE="fr_FR.UTF-8"
KEYMAP="fr"
DESKTOP_ENVIRONMENT="kde"
ENABLE_ENCRYPTION=false
SWAP_SIZE="4G"

# ==========================================
# FONCTIONS UTILITAIRES
# ==========================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

info() {
    log "INFO" "${BLUE}ℹ${NC} $*"
}

success() {
    log "SUCCESS" "${GREEN}✓${NC} $*"
}

warning() {
    log "WARNING" "${YELLOW}⚠${NC} $*"
}

error() {
    log "ERROR" "${RED}✗${NC} $*"
}

fatal() {
    error "$*"
    exit 1
}

# Affichage du banner ArchFusion
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║     █████╗ ██████╗  ██████╗██╗  ██╗███████╗██╗   ██╗      ║
    ║    ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝██║   ██║      ║
    ║    ███████║██████╔╝██║     ███████║█████╗  ██║   ██║      ║
    ║    ██╔══██║██╔══██╗██║     ██╔══██║██╔══╝  ██║   ██║      ║
    ║    ██║  ██║██║  ██║╚██████╗██║  ██║██║     ╚██████╔╝      ║
    ║    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝      ╚═════╝       ║
    ║                                                           ║
    ║    ███████╗██╗   ██╗███████╗██╗ ██████╗ ███╗   ██╗        ║
    ║    ██╔════╝██║   ██║██╔════╝██║██╔═══██╗████╗  ██║        ║
    ║    █████╗  ██║   ██║███████╗██║██║   ██║██╔██╗ ██║        ║
    ║    ██╔══╝  ██║   ██║╚════██║██║██║   ██║██║╚██╗██║        ║
    ║    ██║     ╚██████╔╝███████║██║╚██████╔╝██║ ╚████║        ║
    ║    ╚═╝      ╚═════╝ ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝        ║
    ║                                                           ║
    ║              🚀 Distribution Linux Révolutionnaire        ║
    ║           macOS + Windows + Arch Linux = ArchFusion       ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${WHITE}Version 1.0.0 - Installation Automatisée${NC}"
    echo -e "${PURPLE}Par Jimmy Ramsamynaick - jimmyramsamynaick@gmail.com${NC}"
    echo ""
}

# Vérification des prérequis
check_prerequisites() {
    info "Vérification des prérequis..."
    
    # Vérifier si on est en mode UEFI
    if [[ ! -d /sys/firmware/efi ]]; then
        warning "Mode BIOS détecté. UEFI est recommandé pour une meilleure expérience."
    else
        success "Mode UEFI détecté"
    fi
    
    # Vérifier la connexion internet
    if ! ping -c 1 archlinux.org &> /dev/null; then
        fatal "Connexion internet requise pour l'installation"
    fi
    success "Connexion internet OK"
    
    # Vérifier l'espace disque disponible
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 20971520 ]]; then # 20GB en KB
        fatal "Au moins 20GB d'espace libre requis"
    fi
    success "Espace disque suffisant"
    
    # Vérifier la RAM
    local ram_mb=$(free -m | awk 'NR==2{print $2}')
    if [[ $ram_mb -lt 2048 ]]; then
        warning "Moins de 2GB de RAM détectée. 4GB recommandés."
    else
        success "RAM suffisante: ${ram_mb}MB"
    fi
}

# Configuration interactive
interactive_setup() {
    info "Configuration interactive d'ArchFusion OS"
    echo ""
    
    # Sélection du disque
    echo -e "${YELLOW}Disques disponibles:${NC}"
    lsblk -d -o NAME,SIZE,MODEL | grep -E "sd|nvme|vd"
    echo ""
    
    while true; do
        read -p "$(echo -e "${CYAN}Sélectionnez le disque d'installation (ex: sda, nvme0n1): ${NC}")" TARGET_DISK
        if [[ -b "/dev/${TARGET_DISK}" ]]; then
            break
        else
            error "Disque /dev/${TARGET_DISK} non trouvé"
        fi
    done
    
    # Nom d'utilisateur
    while true; do
        read -p "$(echo -e "${CYAN}Nom d'utilisateur: ${NC}")" USERNAME
        if [[ $USERNAME =~ ^[a-z][a-z0-9_-]*$ ]]; then
            break
        else
            error "Nom d'utilisateur invalide (minuscules, chiffres, - et _ uniquement)"
        fi
    done
    
    # Nom d'hôte
    read -p "$(echo -e "${CYAN}Nom d'hôte [${HOSTNAME}]: ${NC}")" input
    [[ -n $input ]] && HOSTNAME="$input"
    
    # Fuseau horaire
    echo -e "${YELLOW}Fuseaux horaires populaires:${NC}"
    echo "1) Europe/Paris    2) Europe/London    3) America/New_York"
    echo "4) America/Los_Angeles    5) Asia/Tokyo    6) Autre"
    
    read -p "$(echo -e "${CYAN}Choisissez (1-6) [1]: ${NC}")" tz_choice
    case ${tz_choice:-1} in
        1) TIMEZONE="Europe/Paris" ;;
        2) TIMEZONE="Europe/London" ;;
        3) TIMEZONE="America/New_York" ;;
        4) TIMEZONE="America/Los_Angeles" ;;
        5) TIMEZONE="Asia/Tokyo" ;;
        6) 
            read -p "$(echo -e "${CYAN}Fuseau horaire personnalisé: ${NC}")" TIMEZONE
            ;;
    esac
    
    # Chiffrement
    read -p "$(echo -e "${CYAN}Activer le chiffrement du disque? (y/N): ${NC}")" encrypt
    [[ $encrypt =~ ^[Yy]$ ]] && ENABLE_ENCRYPTION=true
    
    # Taille du swap
    read -p "$(echo -e "${CYAN}Taille du swap [${SWAP_SIZE}]: ${NC}")" input
    [[ -n $input ]] && SWAP_SIZE="$input"
    
    echo ""
    info "Configuration terminée!"
}

# Partitionnement du disque
partition_disk() {
    info "Partitionnement du disque /dev/${TARGET_DISK}..."
    
    # Avertissement
    echo -e "${RED}⚠ ATTENTION: Toutes les données sur /dev/${TARGET_DISK} seront EFFACÉES!${NC}"
    read -p "$(echo -e "${YELLOW}Continuer? (y/N): ${NC}")" confirm
    [[ ! $confirm =~ ^[Yy]$ ]] && fatal "Installation annulée par l'utilisateur"
    
    # Effacer la table de partition
    wipefs -af "/dev/${TARGET_DISK}"
    
    if [[ -d /sys/firmware/efi ]]; then
        # Partitionnement UEFI
        parted -s "/dev/${TARGET_DISK}" \
            mklabel gpt \
            mkpart "EFI" fat32 1MiB 513MiB \
            set 1 esp on \
            mkpart "Boot" ext4 513MiB 1537MiB \
            mkpart "Swap" linux-swap 1537MiB $((1537 + ${SWAP_SIZE%G} * 1024))MiB \
            mkpart "Root" ext4 $((1537 + ${SWAP_SIZE%G} * 1024))MiB 100%
        
        # Variables des partitions
        EFI_PART="/dev/${TARGET_DISK}1"
        BOOT_PART="/dev/${TARGET_DISK}2"
        SWAP_PART="/dev/${TARGET_DISK}3"
        ROOT_PART="/dev/${TARGET_DISK}4"
    else
        # Partitionnement BIOS
        parted -s "/dev/${TARGET_DISK}" \
            mklabel msdos \
            mkpart primary ext4 1MiB 513MiB \
            set 1 boot on \
            mkpart primary linux-swap 513MiB $((513 + ${SWAP_SIZE%G} * 1024))MiB \
            mkpart primary ext4 $((513 + ${SWAP_SIZE%G} * 1024))MiB 100%
        
        # Variables des partitions
        BOOT_PART="/dev/${TARGET_DISK}1"
        SWAP_PART="/dev/${TARGET_DISK}2"
        ROOT_PART="/dev/${TARGET_DISK}3"
    fi
    
    success "Partitionnement terminé"
}

# Formatage des partitions
format_partitions() {
    info "Formatage des partitions..."
    
    if [[ -n ${EFI_PART:-} ]]; then
        mkfs.fat -F32 -n "EFI" "$EFI_PART"
        success "Partition EFI formatée"
    fi
    
    mkfs.ext4 -L "Boot" "$BOOT_PART"
    success "Partition Boot formatée"
    
    mkswap -L "Swap" "$SWAP_PART"
    success "Partition Swap formatée"
    
    if [[ $ENABLE_ENCRYPTION == true ]]; then
        info "Configuration du chiffrement LUKS..."
        cryptsetup luksFormat --type luks2 "$ROOT_PART"
        cryptsetup open "$ROOT_PART" cryptroot
        mkfs.ext4 -L "Root" /dev/mapper/cryptroot
        ROOT_MOUNT="/dev/mapper/cryptroot"
    else
        mkfs.ext4 -L "Root" "$ROOT_PART"
        ROOT_MOUNT="$ROOT_PART"
    fi
    
    success "Toutes les partitions formatées"
}

# Montage des partitions
mount_partitions() {
    info "Montage des partitions..."
    
    mount "$ROOT_MOUNT" /mnt
    
    mkdir -p /mnt/boot
    mount "$BOOT_PART" /mnt/boot
    
    if [[ -n ${EFI_PART:-} ]]; then
        mkdir -p /mnt/boot/efi
        mount "$EFI_PART" /mnt/boot/efi
    fi
    
    swapon "$SWAP_PART"
    
    success "Partitions montées"
}

# Installation du système de base
install_base_system() {
    info "Installation du système de base..."
    
    # Mise à jour des miroirs
    reflector --country France,Germany,Netherlands --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    
    # Installation des paquets de base
    pacstrap /mnt base base-devel linux linux-firmware \
        networkmanager grub efibootmgr \
        git vim nano sudo zsh \
        intel-ucode amd-ucode
    
    success "Système de base installé"
}

# Configuration du système
configure_system() {
    info "Configuration du système..."
    
    # Génération du fstab
    genfstab -U /mnt >> /mnt/etc/fstab
    
    # Configuration dans le chroot
    arch-chroot /mnt /bin/bash << EOF
# Fuseau horaire
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

# Localisation
echo "${LOCALE} UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

# Nom d'hôte
echo "${HOSTNAME}" > /etc/hostname
cat > /etc/hosts << EOH
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOH

# Utilisateur
useradd -m -G wheel,audio,video,optical,storage -s /bin/zsh ${USERNAME}
echo "${USERNAME} ALL=(ALL) ALL" >> /etc/sudoers

# Services
systemctl enable NetworkManager
systemctl enable fstrim.timer

# Bootloader
if [[ -d /sys/firmware/efi ]]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchFusion
else
    grub-install --target=i386-pc /dev/${TARGET_DISK}
fi

# Configuration GRUB
sed -i 's/GRUB_DISTRIBUTOR="Arch"/GRUB_DISTRIBUTOR="ArchFusion"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
EOF

    success "Système configuré"
}

# Installation de l'environnement de bureau
install_desktop_environment() {
    info "Installation de l'environnement de bureau KDE Plasma..."
    
    arch-chroot /mnt /bin/bash << 'EOF'
# Installation KDE Plasma
pacman -S --noconfirm plasma-meta kde-applications-meta \
    sddm firefox kitty dolphin kate \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack \
    ttf-dejavu ttf-liberation noto-fonts \
    packagekit-qt5

# Activation de SDDM
systemctl enable sddm

# Configuration PipeWire
systemctl --user enable pipewire pipewire-pulse
EOF

    success "Environnement de bureau installé"
}

# Application des configurations ArchFusion
apply_archfusion_configs() {
    info "Application des configurations ArchFusion..."
    
    # Copier les configurations personnalisées
    if [[ -d "${PROJECT_ROOT}/configs" ]]; then
        cp -r "${PROJECT_ROOT}/configs"/* /mnt/etc/
        success "Configurations ArchFusion appliquées"
    fi
    
    # Copier les thèmes et wallpapers
    if [[ -d "${PROJECT_ROOT}/assets" ]]; then
        mkdir -p /mnt/usr/share/archfusion
        cp -r "${PROJECT_ROOT}/assets"/* /mnt/usr/share/archfusion/
        success "Assets ArchFusion installés"
    fi
}

# Finalisation
finalize_installation() {
    info "Finalisation de l'installation..."
    
    # Définir les mots de passe
    echo -e "${CYAN}Configuration des mots de passe:${NC}"
    
    echo "Mot de passe root:"
    arch-chroot /mnt passwd
    
    echo "Mot de passe pour ${USERNAME}:"
    arch-chroot /mnt passwd "$USERNAME"
    
    # Nettoyage
    umount -R /mnt
    [[ $ENABLE_ENCRYPTION == true ]] && cryptsetup close cryptroot
    
    success "Installation terminée!"
    
    echo ""
    echo -e "${GREEN}🎉 ArchFusion OS a été installé avec succès!${NC}"
    echo -e "${YELLOW}Vous pouvez maintenant redémarrer votre système.${NC}"
    echo ""
    echo -e "${CYAN}Informations de connexion:${NC}"
    echo -e "  Utilisateur: ${USERNAME}"
    echo -e "  Hostname: ${HOSTNAME}"
    echo ""
    
    read -p "$(echo -e "${CYAN}Redémarrer maintenant? (y/N): ${NC}")" reboot_now
    [[ $reboot_now =~ ^[Yy]$ ]] && reboot
}

# ==========================================
# FONCTION PRINCIPALE
# ==========================================

main() {
    # Vérifier les privilèges root
    [[ $EUID -ne 0 ]] && fatal "Ce script doit être exécuté en tant que root"
    
    # Initialiser le log
    echo "=== ArchFusion OS Installation - $(date) ===" > "$LOG_FILE"
    
    # Affichage du banner
    show_banner
    
    # Vérification des prérequis
    check_prerequisites
    
    # Configuration
    if [[ $INSTALL_MODE == "interactive" ]] || [[ $# -eq 0 ]]; then
        interactive_setup
    fi
    
    # Étapes d'installation
    partition_disk
    format_partitions
    mount_partitions
    install_base_system
    configure_system
    install_desktop_environment
    apply_archfusion_configs
    finalize_installation
}

# ==========================================
# GESTION DES ARGUMENTS
# ==========================================

show_help() {
    cat << EOF
ArchFusion OS - Script d'Installation

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Afficher cette aide
    -a, --auto              Installation automatique (non-interactive)
    -i, --interactive       Installation interactive (défaut)
    -d, --disk DISK         Disque cible (ex: sda, nvme0n1)
    -u, --username USER     Nom d'utilisateur
    -H, --hostname HOST     Nom d'hôte
    -t, --timezone TZ       Fuseau horaire
    -e, --encrypt           Activer le chiffrement
    --swap-size SIZE        Taille du swap (ex: 4G)

EXEMPLES:
    $0                      # Installation interactive
    $0 -a -d sda -u jimmy   # Installation automatique
    $0 -i                   # Force le mode interactif

EOF
}

# Parsing des arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -a|--auto)
            INSTALL_MODE="auto"
            shift
            ;;
        -i|--interactive)
            INSTALL_MODE="interactive"
            shift
            ;;
        -d|--disk)
            TARGET_DISK="$2"
            shift 2
            ;;
        -u|--username)
            USERNAME="$2"
            shift 2
            ;;
        -H|--hostname)
            HOSTNAME="$2"
            shift 2
            ;;
        -t|--timezone)
            TIMEZONE="$2"
            shift 2
            ;;
        -e|--encrypt)
            ENABLE_ENCRYPTION=true
            shift
            ;;
        --swap-size)
            SWAP_SIZE="$2"
            shift 2
            ;;
        *)
            error "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Lancement du script principal
main "$@"