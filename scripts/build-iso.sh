#!/bin/bash

# ArchFusion OS - Script de Génération d'ISO
# Auteur: Jimmy Ramsamynaick
# Version: 1.0.0
# Description: Génère l'ISO bootable d'ArchFusion OS

set -euo pipefail

# ==========================================
# CONFIGURATION ET VARIABLES
# ==========================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly BUILD_DIR="${PROJECT_ROOT}/build"
readonly ISO_DIR="${PROJECT_ROOT}/iso"
readonly WORK_DIR="${BUILD_DIR}/work"
readonly OUT_DIR="${BUILD_DIR}/out"

# Informations de la distribution
readonly DISTRO_NAME="ArchFusion"
readonly DISTRO_VERSION="1.0.0"
readonly DISTRO_CODENAME="Fusion"
readonly ISO_LABEL="ARCHFUSION_${DISTRO_VERSION//./_}"
readonly ISO_FILENAME="archfusion-${DISTRO_VERSION}-x86_64.iso"

# Configuration archiso
readonly ARCHISO_PROFILE="${BUILD_DIR}/archiso-profile"
readonly ARCHISO_CONFIG="${ARCHISO_PROFILE}/profiledef.sh"

# Couleurs pour l'affichage
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# ==========================================
# FONCTIONS UTILITAIRES
# ==========================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${timestamp} [${level}] ${message}"
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
    ║     █████╗ ██████╗  ██████╗██╗  ██╗███████╗██╗   ██╗     ║
    ║    ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝██║   ██║     ║
    ║    ███████║██████╔╝██║     ███████║█████╗  ██║   ██║     ║
    ║    ██╔══██║██╔══██╗██║     ██╔══██║██╔══╝  ██║   ██║     ║
    ║    ██║  ██║██║  ██║╚██████╗██║  ██║██║     ╚██████╔╝     ║
    ║    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝      ╚═════╝      ║
    ║                                                           ║
    ║    ███████╗██╗   ██╗███████╗██╗ ██████╗ ███╗   ██╗       ║
    ║    ██╔════╝██║   ██║██╔════╝██║██╔═══██╗████╗  ██║       ║
    ║    █████╗  ██║   ██║███████╗██║██║   ██║██╔██╗ ██║       ║
    ║    ██╔══╝  ██║   ██║╚════██║██║██║   ██║██║╚██╗██║       ║
    ║    ██║     ╚██████╔╝███████║██║╚██████╔╝██║ ╚████║       ║
    ║    ╚═╝      ╚═════╝ ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝       ║
    ║                                                           ║
    ║                  🔥 Générateur d'ISO                      ║
    ║              Distribution Linux Révolutionnaire           ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${WHITE}Version ${DISTRO_VERSION} - Génération ISO${NC}"
    echo -e "${PURPLE}Par Jimmy Ramsamynaick - jimmyramsamynaick@gmail.com${NC}"
    echo ""
}

# Vérification des prérequis
check_prerequisites() {
    info "Vérification des prérequis pour la génération d'ISO..."
    
    # Vérifier si on est root
    if [[ $EUID -ne 0 ]]; then
        fatal "Ce script doit être exécuté en tant que root"
    fi
    
    # Vérifier les outils requis
    local required_tools=("archiso" "mkarchiso" "pacman" "mksquashfs" "xorriso")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            error "Outil requis manquant: $tool"
            if [[ "$tool" == "archiso" ]] || [[ "$tool" == "mkarchiso" ]]; then
                info "Installation d'archiso..."
                pacman -S --noconfirm archiso
            fi
        else
            success "Outil trouvé: $tool"
        fi
    done
    
    # Vérifier l'espace disque (au moins 4GB)
    local available_space=$(df "${BUILD_DIR%/*}" | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 4194304 ]]; then # 4GB en KB
        fatal "Au moins 4GB d'espace libre requis pour la génération d'ISO"
    fi
    success "Espace disque suffisant: $(( available_space / 1024 / 1024 ))GB disponibles"
    
    # Vérifier la connexion internet
    if ! ping -c 1 archlinux.org &> /dev/null; then
        warning "Pas de connexion internet - utilisation du cache local uniquement"
    else
        success "Connexion internet OK"
    fi
}

# Préparation des répertoires
prepare_directories() {
    info "Préparation des répertoires de build..."
    
    # Nettoyer les anciens builds
    if [[ -d "$BUILD_DIR" ]]; then
        warning "Nettoyage de l'ancien répertoire de build..."
        rm -rf "$BUILD_DIR"
    fi
    
    # Créer la structure de répertoires
    mkdir -p "$BUILD_DIR" "$WORK_DIR" "$OUT_DIR" "$ISO_DIR"
    mkdir -p "$ARCHISO_PROFILE"
    
    success "Répertoires de build préparés"
}

# Création du profil archiso
create_archiso_profile() {
    info "Création du profil archiso personnalisé..."
    
    # Copier le profil de base
    cp -r /usr/share/archiso/configs/releng/* "$ARCHISO_PROFILE/"
    
    # Configuration du profil
    cat > "$ARCHISO_CONFIG" << EOF
#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="$DISTRO_NAME"
iso_label="$ISO_LABEL"
iso_publisher="Jimmy Ramsamynaick <jimmyramsamynaick@gmail.com>"
iso_application="$DISTRO_NAME Live/Rescue CD"
iso_version="$DISTRO_VERSION"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.grub.esp' 'uefi-x64.grub.esp'
           'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)
EOF
    
    success "Profil archiso créé"
}

# Configuration des paquets
configure_packages() {
    info "Configuration de la liste des paquets..."
    
    # Liste des paquets ArchFusion
    cat > "${ARCHISO_PROFILE}/packages.x86_64" << 'EOF'
# Système de base
base
base-devel
linux
linux-firmware
linux-headers

# Bootloader et outils système
grub
efibootmgr
os-prober
intel-ucode
amd-ucode

# Réseau
networkmanager
network-manager-applet
wireless_tools
wpa_supplicant
dhcpcd
openssh

# Outils essentiels
git
vim
nano
sudo
zsh
fish
bash-completion
man-db
which
wget
curl
rsync
unzip
zip
tar
htop
neofetch
tree
lsof

# Interface graphique - KDE Plasma
plasma-meta
kde-applications-meta
sddm
sddm-kcm
xorg-server
xorg-apps
xorg-xinit
plasma-wayland-session

# Applications essentielles
firefox
kitty
dolphin
kate
konsole
spectacle
gwenview
okular
ark
kdeconnect
kcalc

# Multimédia
pipewire
pipewire-alsa
pipewire-pulse
pipewire-jack
wireplumber
pavucontrol
alsa-utils
vlc
mpv

# Polices
ttf-dejavu
ttf-liberation
ttf-roboto
noto-fonts
noto-fonts-emoji
ttf-fira-code
ttf-jetbrains-mono

# Thèmes et icônes
papirus-icon-theme
arc-gtk-theme
kvantum-qt5

# Outils de développement
code
python
python-pip
nodejs
npm

# Utilitaires système
gparted
timeshift
bleachbit
synaptic
software-properties-common
apt-transport-https
ca-certificates
gnupg
lsb-release

# Support matériel
mesa
xf86-video-intel
xf86-video-amdgpu
nvidia
bluez
bluez-utils
cups
ghostscript

# Archiso spécifique
archiso
arch-install-scripts
cloud-init
hyperv
open-vm-tools
qemu-guest-agent
virtualbox-guest-utils
EOF
    
    success "Liste des paquets configurée"
}

# Configuration du système live
configure_live_system() {
    info "Configuration du système live..."
    
    local airootfs="${ARCHISO_PROFILE}/airootfs"
    mkdir -p "$airootfs"
    
    # Copier les configurations ArchFusion
    if [[ -d "${PROJECT_ROOT}/configs" ]]; then
        cp -r "${PROJECT_ROOT}/configs"/* "${airootfs}/etc/" 2>/dev/null || true
    fi
    
    # Copier les assets
    if [[ -d "${PROJECT_ROOT}/assets" ]]; then
        mkdir -p "${airootfs}/usr/share/archfusion"
        cp -r "${PROJECT_ROOT}/assets"/* "${airootfs}/usr/share/archfusion/"
    fi
    
    # Copier les scripts d'installation
    if [[ -d "${PROJECT_ROOT}/scripts" ]]; then
        mkdir -p "${airootfs}/usr/share/archfusion/scripts"
        cp -r "${PROJECT_ROOT}/scripts"/* "${airootfs}/usr/share/archfusion/scripts/"
        chmod +x "${airootfs}/usr/share/archfusion/scripts/install"/*.sh
        chmod +x "${airootfs}/usr/share/archfusion/scripts/install"/*.py
    fi
    
    # Configuration utilisateur live
    mkdir -p "${airootfs}/etc/skel/.config"
    
    # Script de démarrage automatique
    mkdir -p "${airootfs}/etc/systemd/system/getty@tty1.service.d"
    cat > "${airootfs}/etc/systemd/system/getty@tty1.service.d/autologin.conf" << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin archfusion - $TERM
EOF
    
    # Configuration de l'utilisateur live
    mkdir -p "${airootfs}/etc/systemd/system/multi-user.target.wants"
    cat > "${airootfs}/etc/systemd/system/archfusion-live.service" << 'EOF'
[Unit]
Description=ArchFusion Live System Setup
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/share/archfusion/scripts/live-setup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    ln -sf ../archfusion-live.service "${airootfs}/etc/systemd/system/multi-user.target.wants/"
    
    success "Système live configuré"
}

# Création du script de setup live
create_live_setup_script() {
    info "Création du script de setup live..."
    
    local airootfs="${ARCHISO_PROFILE}/airootfs"
    mkdir -p "${airootfs}/usr/share/archfusion/scripts"
    
    cat > "${airootfs}/usr/share/archfusion/scripts/live-setup.sh" << 'EOF'
#!/bin/bash

# ArchFusion OS - Script de Setup Live
# Configure l'environnement live au démarrage

# Créer l'utilisateur live
useradd -m -G wheel,audio,video,optical,storage -s /bin/zsh archfusion
echo "archfusion:archfusion" | chpasswd

# Configuration sudo sans mot de passe pour l'utilisateur live
echo "archfusion ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/archfusion

# Activer les services
systemctl enable NetworkManager
systemctl enable sddm
systemctl enable bluetooth

# Configuration du thème
if [[ -d /usr/share/archfusion/themes ]]; then
    cp -r /usr/share/archfusion/themes/* /usr/share/themes/ 2>/dev/null || true
fi

# Wallpapers
if [[ -d /usr/share/archfusion/wallpapers ]]; then
    cp -r /usr/share/archfusion/wallpapers/* /usr/share/wallpapers/ 2>/dev/null || true
fi

# Message de bienvenue
cat > /etc/motd << 'MOTD'

    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║     █████╗ ██████╗  ██████╗██╗  ██╗███████╗██╗   ██╗     ║
    ║    ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝██║   ██║     ║
    ║    ███████║██████╔╝██║     ███████║█████╗  ██║   ██║     ║
    ║    ██╔══██║██╔══██╗██║     ██╔══██║██╔══╝  ██║   ██║     ║
    ║    ██║  ██║██║  ██║╚██████╗██║  ██║██║     ╚██████╔╝     ║
    ║    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝      ╚═════╝      ║
    ║                                                           ║
    ║              🚀 Bienvenue dans ArchFusion OS!             ║
    ║                                                           ║
    ║  Pour installer ArchFusion sur votre système:             ║
    ║  • Interface graphique: sudo archfusion-installer-gui     ║
    ║  • Ligne de commande: sudo archfusion-installer           ║
    ║                                                           ║
    ║  Utilisateur: archfusion | Mot de passe: archfusion       ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝

MOTD

# Créer les liens symboliques pour les installateurs
ln -sf /usr/share/archfusion/scripts/install/install.sh /usr/local/bin/archfusion-installer
ln -sf /usr/share/archfusion/scripts/install/gui-installer.py /usr/local/bin/archfusion-installer-gui

# Configuration du bureau pour l'utilisateur live
mkdir -p /home/archfusion/.config/autostart
cat > /home/archfusion/.config/autostart/archfusion-welcome.desktop << 'DESKTOP'
[Desktop Entry]
Type=Application
Name=ArchFusion Welcome
Exec=/usr/share/archfusion/scripts/welcome.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
DESKTOP

chown -R archfusion:archfusion /home/archfusion
EOF
    
    chmod +x "${airootfs}/usr/share/archfusion/scripts/live-setup.sh"
    
    success "Script de setup live créé"
}

# Configuration du bootloader
configure_bootloader() {
    info "Configuration du bootloader..."
    
    local syslinux_dir="${ARCHISO_PROFILE}/syslinux"
    local grub_dir="${ARCHISO_PROFILE}/grub"
    
    # Configuration SYSLINUX
    if [[ -f "${syslinux_dir}/archiso_sys-linux.cfg" ]]; then
        sed -i "s/Arch Linux/ArchFusion OS/g" "${syslinux_dir}"/*.cfg
        sed -i "s/archiso/${ISO_LABEL}/g" "${syslinux_dir}"/*.cfg
    fi
    
    # Configuration GRUB
    if [[ -f "${grub_dir}/grub.cfg" ]]; then
        sed -i "s/Arch Linux/ArchFusion OS/g" "${grub_dir}/grub.cfg"
        sed -i "s/archiso/${ISO_LABEL}/g" "${grub_dir}/grub.cfg"
    fi
    
    success "Bootloader configuré"
}

# Génération de l'ISO
generate_iso() {
    info "Génération de l'ISO ArchFusion..."
    
    # Mise à jour des miroirs
    info "Mise à jour des miroirs Pacman..."
    reflector --country France,Germany,Netherlands --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    
    # Génération avec mkarchiso
    info "Lancement de mkarchiso..."
    cd "$BUILD_DIR"
    
    mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$ARCHISO_PROFILE"
    
    # Déplacer l'ISO vers le répertoire final
    if [[ -f "${OUT_DIR}/${ISO_FILENAME}" ]]; then
        mv "${OUT_DIR}/${ISO_FILENAME}" "${ISO_DIR}/"
        success "ISO générée avec succès: ${ISO_DIR}/${ISO_FILENAME}"
    else
        # Chercher l'ISO générée (le nom peut varier)
        local generated_iso=$(find "$OUT_DIR" -name "*.iso" | head -1)
        if [[ -n "$generated_iso" ]]; then
            mv "$generated_iso" "${ISO_DIR}/${ISO_FILENAME}"
            success "ISO générée avec succès: ${ISO_DIR}/${ISO_FILENAME}"
        else
            fatal "Échec de la génération de l'ISO"
        fi
    fi
}

# Calcul des checksums
generate_checksums() {
    info "Génération des checksums..."
    
    cd "$ISO_DIR"
    
    # SHA256
    sha256sum "${ISO_FILENAME}" > "${ISO_FILENAME}.sha256"
    success "SHA256: $(cat "${ISO_FILENAME}.sha256")"
    
    # MD5
    md5sum "${ISO_FILENAME}" > "${ISO_FILENAME}.md5"
    success "MD5: $(cat "${ISO_FILENAME}.md5")"
    
    # Informations sur l'ISO
    local iso_size=$(du -h "${ISO_FILENAME}" | cut -f1)
    info "Taille de l'ISO: $iso_size"
}

# Nettoyage
cleanup() {
    info "Nettoyage des fichiers temporaires..."
    
    if [[ -d "$WORK_DIR" ]]; then
        rm -rf "$WORK_DIR"
        success "Répertoire de travail nettoyé"
    fi
    
    if [[ -d "$OUT_DIR" ]]; then
        rm -rf "$OUT_DIR"
        success "Répertoire de sortie nettoyé"
    fi
}

# Test de l'ISO (optionnel)
test_iso() {
    info "Test de l'ISO générée..."
    
    if command -v qemu-system-x86_64 &> /dev/null; then
        read -p "$(echo -e "${CYAN}Voulez-vous tester l'ISO avec QEMU? (y/N): ${NC}")" test_qemu
        if [[ $test_qemu =~ ^[Yy]$ ]]; then
            info "Lancement de QEMU pour tester l'ISO..."
            qemu-system-x86_64 -cdrom "${ISO_DIR}/${ISO_FILENAME}" -m 2048 -enable-kvm &
            success "QEMU lancé en arrière-plan"
        fi
    else
        info "QEMU non disponible - test manuel requis"
    fi
}

# ==========================================
# FONCTION PRINCIPALE
# ==========================================

main() {
    # Affichage du banner
    show_banner
    
    # Vérification des prérequis
    check_prerequisites
    
    # Étapes de génération
    prepare_directories
    create_archiso_profile
    configure_packages
    configure_live_system
    create_live_setup_script
    configure_bootloader
    generate_iso
    generate_checksums
    cleanup
    
    # Résumé final
    echo ""
    success "🎉 ISO ArchFusion générée avec succès!"
    echo ""
    echo -e "${CYAN}Informations de l'ISO:${NC}"
    echo -e "  Fichier: ${ISO_DIR}/${ISO_FILENAME}"
    echo -e "  Taille: $(du -h "${ISO_DIR}/${ISO_FILENAME}" | cut -f1)"
    echo -e "  SHA256: $(cat "${ISO_DIR}/${ISO_FILENAME}.sha256" | cut -d' ' -f1)"
    echo ""
    echo -e "${YELLOW}Pour utiliser l'ISO:${NC}"
    echo -e "  1. Gravez sur USB: dd if=${ISO_DIR}/${ISO_FILENAME} of=/dev/sdX bs=4M status=progress"
    echo -e "  2. Ou utilisez un outil comme Rufus, Etcher, Ventoy"
    echo -e "  3. Bootez depuis l'USB et suivez les instructions"
    echo ""
    
    # Test optionnel
    test_iso
}

# ==========================================
# GESTION DES ARGUMENTS
# ==========================================

show_help() {
    cat << EOF
ArchFusion OS - Générateur d'ISO

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Afficher cette aide
    -c, --clean             Nettoyer avant la génération
    -t, --test              Tester l'ISO avec QEMU après génération
    -v, --verbose           Mode verbeux
    --no-cleanup            Ne pas nettoyer les fichiers temporaires

EXEMPLES:
    $0                      # Génération standard
    $0 -c -t                # Nettoyage + génération + test
    $0 --verbose            # Mode verbeux

EOF
}

# Variables par défaut
CLEAN_BEFORE=false
TEST_AFTER=false
VERBOSE=false
NO_CLEANUP=false

# Parsing des arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--clean)
            CLEAN_BEFORE=true
            shift
            ;;
        -t|--test)
            TEST_AFTER=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            set -x
            shift
            ;;
        --no-cleanup)
            NO_CLEANUP=true
            shift
            ;;
        *)
            error "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Nettoyage préalable si demandé
if [[ $CLEAN_BEFORE == true ]]; then
    info "Nettoyage préalable..."
    [[ -d "$BUILD_DIR" ]] && rm -rf "$BUILD_DIR"
    [[ -d "$ISO_DIR" ]] && rm -rf "$ISO_DIR"
fi

# Lancement du script principal
main "$@"