#!/bin/bash

# ArchFusion OS Setup Script
# Configuration automatique du système live

set -e

LOGFILE="/var/log/archfusion-setup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

log "=== Démarrage de la configuration ArchFusion OS ==="

# Configuration du réseau
configure_network() {
    log "Configuration du réseau..."
    systemctl enable NetworkManager
    systemctl start NetworkManager
}

# Configuration audio
configure_audio() {
    log "Configuration audio..."
    systemctl --user enable pipewire
    systemctl --user enable pipewire-pulse
    systemctl --user enable wireplumber
}

# Configuration KDE
configure_kde() {
    log "Configuration de l'environnement KDE..."
    
    # Activer SDDM
    systemctl enable sddm
    
    # Configuration du thème par défaut
    mkdir -p /etc/skel/.config/kdeglobals
    cat > /etc/skel/.config/kdeglobals << 'EOF'
[General]
ColorScheme=BreezeDark
Name=Breeze Dark
shadeSortColumn=true

[Icons]
Theme=breeze-dark

[KDE]
LookAndFeelPackage=org.kde.breezedark.desktop
SingleClick=false
widgetStyle=Breeze
EOF
}

# Configuration des services système
configure_services() {
    log "Configuration des services système..."
    
    # Services essentiels
    systemctl enable bluetooth
    systemctl enable cups
    systemctl enable ufw
    
    # Configuration du pare-feu
    ufw --force enable
    ufw default deny incoming
    ufw default allow outgoing
}

# Configuration gaming
configure_gaming() {
    log "Configuration des optimisations gaming..."
    
    # GameMode
    systemctl --user enable gamemoded
    
    # Steam
    if command -v steam &> /dev/null; then
        log "Steam détecté, configuration des optimisations..."
    fi
}

# Préparation pour les fonctionnalités futures
prepare_future_features() {
    log "Préparation des fonctionnalités futures..."
    
    # Docker (pour containers futurs)
    systemctl enable docker
    usermod -aG docker archfusion 2>/dev/null || true
    
    # Création des dossiers pour les fonctionnalités futures
    mkdir -p /opt/archfusion/{themes,plugins,containers}
    mkdir -p /etc/archfusion/{wayland,ai-assistant,cloud-sync}
    
    # Marqueurs pour les fonctionnalités futures
    touch /etc/archfusion/wayland/.ready-for-wayland
    touch /etc/archfusion/containers/.ready-for-containers
    touch /etc/archfusion/ai-assistant/.ready-for-ai
}

# Configuration des utilisateurs
configure_users() {
    log "Configuration des utilisateurs..."
    
    # Utilisateur live par défaut
    if ! id "archfusion" &>/dev/null; then
        useradd -m -G wheel,audio,video,optical,storage,docker -s /bin/zsh archfusion
        echo "archfusion:archfusion" | chpasswd
    fi
    
    # Configuration sudo
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
}

# Configuration des optimisations système
configure_optimizations() {
    log "Application des optimisations système..."
    
    # Optimisations SSD
    echo 'ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"' > /etc/udev/rules.d/60-ioschedulers.rules
    
    # Optimisations mémoire
    echo 'vm.swappiness=10' >> /etc/sysctl.d/99-archfusion.conf
    echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.d/99-archfusion.conf
    
    # Optimisations réseau
    echo 'net.core.default_qdisc=fq' >> /etc/sysctl.d/99-archfusion.conf
    echo 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.d/99-archfusion.conf
}

# Installation des outils AUR
install_aur_tools() {
    log "Installation des outils AUR..."
    
    # Installation de yay (AUR helper)
    if ! command -v yay &> /dev/null; then
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd /
        rm -rf /tmp/yay
    fi
}

# Configuration des thèmes
configure_themes() {
    log "Configuration des thèmes..."
    
    # Copier les thèmes personnalisés
    if [ -d "/opt/archfusion/themes" ]; then
        cp -r /opt/archfusion/themes/* /usr/share/themes/ 2>/dev/null || true
    fi
    
    # Configuration des wallpapers
    mkdir -p /usr/share/pixmaps/archfusion
    if [ -d "/opt/archfusion/wallpapers" ]; then
        cp -r /opt/archfusion/wallpapers/* /usr/share/pixmaps/archfusion/ 2>/dev/null || true
    fi
}

# Fonction principale
main() {
    log "Début de la configuration ArchFusion OS..."
    
    configure_network
    configure_audio
    configure_kde
    configure_services
    configure_gaming
    configure_users
    configure_optimizations
    configure_themes
    prepare_future_features
    
    # Installation des outils AUR (en arrière-plan pour ne pas bloquer)
    install_aur_tools &
    
    log "Configuration ArchFusion OS terminée avec succès!"
    
    # Affichage du message de bienvenue
    if [ -f "/usr/local/bin/welcome.sh" ]; then
        /usr/local/bin/welcome.sh
    fi
}

# Exécution uniquement si ce n'est pas déjà fait
if [ ! -f "/var/lib/archfusion-setup-done" ]; then
    main
    touch /var/lib/archfusion-setup-done
    log "Marqueur de configuration créé."
else
    log "Configuration déjà effectuée, passage ignoré."
fi