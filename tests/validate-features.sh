#!/bin/bash

# Script de validation des fonctionnalités ArchFusion OS
# Teste les fonctionnalités spécifiques sans installation complète

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ARCHISO_DIR="$PROJECT_ROOT/archiso"
FEATURES_PASSED=0
FEATURES_FAILED=0
FEATURES_WARNINGS=0

# Fonctions utilitaires
log() {
    echo -e "${BLUE}[FEATURE-TEST]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((FEATURES_PASSED++))
}

fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    ((FEATURES_FAILED++))
}

warning() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $1"
    ((FEATURES_WARNINGS++))
}

info() {
    echo -e "${CYAN}[ℹ INFO]${NC} $1"
}

# Test des fonctionnalités ArchFusion 1.1
test_archfusion_v11_features() {
    log "🔍 Test des fonctionnalités ArchFusion 1.1..."
    
    # Interface utilisateur moderne
    if [ -f "$ARCHISO_DIR/airootfs/etc/skel/.config/kdeglobals" ]; then
        if grep -q "ColorScheme=BreezeDark" "$ARCHISO_DIR/airootfs/etc/skel/.config/kdeglobals"; then
            success "Interface moderne KDE configurée"
        else
            fail "Configuration interface KDE manquante"
        fi
    else
        fail "Fichier de configuration KDE manquant"
    fi
    
    # Optimisations système
    if [ -f "$ARCHISO_DIR/airootfs/etc/modprobe.d/archfusion.conf" ]; then
        local optimizations=("snd-hda-intel" "iwlwifi" "i915" "amdgpu")
        for opt in "${optimizations[@]}"; do
            if grep -q "$opt" "$ARCHISO_DIR/airootfs/etc/modprobe.d/archfusion.conf"; then
                success "Optimisation $opt présente"
            else
                warning "Optimisation $opt manquante"
            fi
        done
    else
        fail "Fichier d'optimisations système manquant"
    fi
    
    # Outils de productivité
    if [ -f "$ARCHISO_DIR/packages.x86_64" ]; then
        local productivity_tools=("firefox" "libreoffice-fresh" "gimp" "vlc")
        for tool in "${productivity_tools[@]}"; do
            if grep -q "^$tool$" "$ARCHISO_DIR/packages.x86_64"; then
                success "Outil de productivité: $tool"
            else
                warning "Outil de productivité manquant: $tool"
            fi
        done
    fi
}

# Test des fonctionnalités ArchFusion 1.2
test_archfusion_v12_features() {
    log "🎮 Test des fonctionnalités ArchFusion 1.2 (Gaming)..."
    
    # Support gaming
    if [ -f "$ARCHISO_DIR/packages.x86_64" ]; then
        local gaming_packages=("steam" "lutris" "wine" "gamemode" "mangohud")
        for package in "${gaming_packages[@]}"; do
            if grep -q "^$package$" "$ARCHISO_DIR/packages.x86_64"; then
                success "Paquet gaming: $package"
            else
                warning "Paquet gaming optionnel: $package"
            fi
        done
    fi
    
    # Optimisations gaming dans modprobe
    if [ -f "$ARCHISO_DIR/airootfs/etc/modprobe.d/archfusion.conf" ]; then
        if grep -q "gamemode" "$ARCHISO_DIR/airootfs/etc/modprobe.d/archfusion.conf" || 
           grep -q "performance" "$ARCHISO_DIR/airootfs/etc/modprobe.d/archfusion.conf"; then
            success "Optimisations gaming configurées"
        else
            warning "Optimisations gaming non détectées"
        fi
    fi
    
    # Pilotes graphiques
    if [ -f "$ARCHISO_DIR/packages.x86_64" ]; then
        local gpu_drivers=("mesa" "vulkan-radeon" "vulkan-intel" "nvidia-dkms")
        local drivers_found=0
        for driver in "${gpu_drivers[@]}"; do
            if grep -q "^$driver$" "$ARCHISO_DIR/packages.x86_64"; then
                success "Pilote graphique: $driver"
                ((drivers_found++))
            fi
        done
        
        if [ $drivers_found -gt 0 ]; then
            success "Support multi-GPU configuré"
        else
            fail "Aucun pilote graphique détecté"
        fi
    fi
}

# Test des fonctionnalités ArchFusion 2.0
test_archfusion_v20_features() {
    log "🚀 Test des fonctionnalités ArchFusion 2.0 (Avancées)..."
    
    # Scripts d'automatisation
    local automation_scripts=(
        "$ARCHISO_DIR/airootfs/usr/local/bin/archfusion-setup.sh"
        "$ARCHISO_DIR/airootfs/usr/local/bin/welcome.sh"
        "$ARCHISO_DIR/airootfs/usr/local/bin/archfusion-help"
    )
    
    for script in "${automation_scripts[@]}"; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            success "Script d'automatisation: $(basename "$script")"
        else
            fail "Script d'automatisation manquant: $(basename "$script")"
        fi
    done
    
    # Configuration réseau avancée
    if [ -f "$ARCHISO_DIR/airootfs/etc/NetworkManager/NetworkManager.conf" ]; then
        local network_features=("dhcp=internal" "dns=systemd-resolved" "connectivity-check")
        for feature in "${network_features[@]}"; do
            if grep -q "$feature" "$ARCHISO_DIR/airootfs/etc/NetworkManager/NetworkManager.conf"; then
                success "Fonctionnalité réseau: $feature"
            else
                warning "Fonctionnalité réseau manquante: $feature"
            fi
        done
    else
        fail "Configuration NetworkManager manquante"
    fi
    
    # Sécurité renforcée
    if [ -f "$ARCHISO_DIR/airootfs/etc/ufw/ufw.conf" ]; then
        if grep -q "ENABLED=yes" "$ARCHISO_DIR/airootfs/etc/ufw/ufw.conf"; then
            success "Pare-feu UFW activé"
        else
            fail "Pare-feu UFW non activé"
        fi
    else
        fail "Configuration UFW manquante"
    fi
    
    # Shell Zsh personnalisé
    if [ -f "$ARCHISO_DIR/airootfs/etc/skel/.zshrc" ]; then
        local zsh_features=("archfusion-update" "archfusion-clean" "archfusion-info" "archfusion-backup")
        for feature in "${zsh_features[@]}"; do
            if grep -q "$feature" "$ARCHISO_DIR/airootfs/etc/skel/.zshrc"; then
                success "Commande Zsh: $feature"
            else
                warning "Commande Zsh manquante: $feature"
            fi
        done
    else
        fail "Configuration Zsh manquante"
    fi
}

# Test de l'intégration des services
test_service_integration() {
    log "🔧 Test de l'intégration des services..."
    
    # Service ArchFusion Setup
    local service_file="$ARCHISO_DIR/airootfs/etc/systemd/system/archfusion-setup.service"
    if [ -f "$service_file" ]; then
        local service_checks=("ExecStart" "WantedBy=multi-user.target" "Type=oneshot")
        for check in "${service_checks[@]}"; do
            if grep -q "$check" "$service_file"; then
                success "Configuration service: $check"
            else
                fail "Configuration service manquante: $check"
            fi
        done
    else
        fail "Fichier service ArchFusion manquant"
    fi
    
    # Vérification des liens symboliques de services
    local service_link="$ARCHISO_DIR/airootfs/etc/systemd/system/multi-user.target.wants/archfusion-setup.service"
    if [ -L "$service_link" ] || [ -f "$service_link" ]; then
        success "Service ArchFusion activé au démarrage"
    else
        fail "Service ArchFusion non activé"
    fi
}

# Test des thèmes et personnalisation
test_theming_customization() {
    log "🎨 Test des thèmes et personnalisation..."
    
    # Configuration KWin (effets et animations)
    if [ -f "$ARCHISO_DIR/airootfs/etc/skel/.config/kwinrc" ]; then
        local kwin_effects=("kwin4_effect_blur" "kwin4_effect_translucency" "slideEnabled")
        for effect in "${kwin_effects[@]}"; do
            if grep -q "$effect" "$ARCHISO_DIR/airootfs/etc/skel/.config/kwinrc"; then
                success "Effet KWin: $effect"
            else
                warning "Effet KWin manquant: $effect"
            fi
        done
    else
        fail "Configuration KWin manquante"
    fi
    
    # Configuration Plasma
    if [ -f "$ARCHISO_DIR/airootfs/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc" ]; then
        if grep -q "org.kde.plasma.taskmanager" "$ARCHISO_DIR/airootfs/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc"; then
            success "Configuration Plasma taskmanager"
        else
            warning "Configuration Plasma taskmanager manquante"
        fi
    else
        fail "Configuration Plasma manquante"
    fi
    
    # Configuration SDDM
    if [ -f "$ARCHISO_DIR/airootfs/etc/sddm.conf" ]; then
        if grep -q "Theme=" "$ARCHISO_DIR/airootfs/etc/sddm.conf"; then
            success "Thème SDDM configuré"
        else
            warning "Thème SDDM non configuré"
        fi
    else
        fail "Configuration SDDM manquante"
    fi
}

# Test de compatibilité matérielle
test_hardware_compatibility() {
    log "💻 Test de compatibilité matérielle..."
    
    # Pilotes réseau
    if [ -f "$ARCHISO_DIR/packages.x86_64" ]; then
        local network_drivers=("networkmanager" "wpa_supplicant" "dhcpcd")
        for driver in "${network_drivers[@]}"; do
            if grep -q "^$driver$" "$ARCHISO_DIR/packages.x86_64"; then
                success "Pilote réseau: $driver"
            else
                fail "Pilote réseau manquant: $driver"
            fi
        done
    fi
    
    # Support Bluetooth
    if [ -f "$ARCHISO_DIR/packages.x86_64" ]; then
        local bluetooth_packages=("bluez" "bluez-utils")
        for package in "${bluetooth_packages[@]}"; do
            if grep -q "^$package$" "$ARCHISO_DIR/packages.x86_64"; then
                success "Support Bluetooth: $package"
            else
                warning "Paquet Bluetooth manquant: $package"
            fi
        done
    fi
    
    # Support audio
    if [ -f "$ARCHISO_DIR/packages.x86_64" ]; then
        local audio_packages=("pipewire" "pipewire-pulse" "pipewire-alsa")
        for package in "${audio_packages[@]}"; do
            if grep -q "^$package$" "$ARCHISO_DIR/packages.x86_64"; then
                success "Support audio: $package"
            else
                warning "Paquet audio manquant: $package"
            fi
        done
    fi
}

# Test de performance et optimisation
test_performance_optimization() {
    log "⚡ Test des optimisations de performance..."
    
    # Optimisations SSD
    if [ -f "$ARCHISO_DIR/airootfs/etc/modprobe.d/archfusion.conf" ]; then
        if grep -q "elevator=noop\|elevator=deadline" "$ARCHISO_DIR/airootfs/etc/modprobe.d/archfusion.conf"; then
            success "Optimisations SSD configurées"
        else
            warning "Optimisations SSD non détectées"
        fi
    fi
    
    # Configuration mémoire
    if [ -f "$ARCHISO_DIR/airootfs/etc/sysctl.d/99-archfusion.conf" ]; then
        local memory_opts=("vm.swappiness" "vm.vfs_cache_pressure" "vm.dirty_ratio")
        for opt in "${memory_opts[@]}"; do
            if grep -q "$opt" "$ARCHISO_DIR/airootfs/etc/sysctl.d/99-archfusion.conf"; then
                success "Optimisation mémoire: $opt"
            else
                warning "Optimisation mémoire manquante: $opt"
            fi
        done
    else
        warning "Fichier d'optimisations sysctl manquant"
    fi
}

# Test de sécurité
test_security_features() {
    log "🔒 Test des fonctionnalités de sécurité..."
    
    # Configuration UFW détaillée
    if [ -f "$ARCHISO_DIR/airootfs/etc/ufw/ufw.conf" ]; then
        local security_settings=("DEFAULT_INPUT_POLICY=\"DROP\"" "DEFAULT_OUTPUT_POLICY=\"ACCEPT\"")
        for setting in "${security_settings[@]}"; do
            if grep -q "$setting" "$ARCHISO_DIR/airootfs/etc/ufw/ufw.conf"; then
                success "Paramètre sécurité UFW: $setting"
            else
                warning "Paramètre sécurité UFW manquant: $setting"
            fi
        done
    fi
    
    # Désactivation des services non nécessaires
    if [ -f "$ARCHISO_DIR/airootfs/etc/modprobe.d/archfusion.conf" ]; then
        if grep -q "blacklist" "$ARCHISO_DIR/airootfs/etc/modprobe.d/archfusion.conf"; then
            success "Modules non sécurisés désactivés"
        else
            warning "Aucun module blacklisté détecté"
        fi
    fi
}

# Génération du rapport détaillé
generate_detailed_report() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                     📊 RAPPORT DÉTAILLÉ DES FONCTIONNALITÉS 📊              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Statistiques générales
    echo -e "${CYAN}📈 STATISTIQUES GÉNÉRALES${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Fonctionnalités validées: $FEATURES_PASSED"
    echo "❌ Fonctionnalités échouées: $FEATURES_FAILED"
    echo "⚠️  Avertissements: $FEATURES_WARNINGS"
    echo "📊 Total testé: $((FEATURES_PASSED + FEATURES_FAILED + FEATURES_WARNINGS))"
    echo ""
    
    # Calcul du score de qualité
    local total_tests=$((FEATURES_PASSED + FEATURES_FAILED))
    local quality_score=0
    if [ $total_tests -gt 0 ]; then
        quality_score=$((FEATURES_PASSED * 100 / total_tests))
    fi
    
    echo -e "${PURPLE}🎯 SCORE DE QUALITÉ${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ $quality_score -ge 90 ]; then
        echo -e "${GREEN}🏆 Excellent: $quality_score%${NC}"
    elif [ $quality_score -ge 75 ]; then
        echo -e "${YELLOW}👍 Bon: $quality_score%${NC}"
    elif [ $quality_score -ge 50 ]; then
        echo -e "${YELLOW}⚠️  Moyen: $quality_score%${NC}"
    else
        echo -e "${RED}❌ Insuffisant: $quality_score%${NC}"
    fi
    echo ""
    
    # Recommandations
    echo -e "${BLUE}💡 RECOMMANDATIONS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ $FEATURES_FAILED -eq 0 ]; then
        echo "🎉 Toutes les fonctionnalités critiques sont opérationnelles!"
        echo "✅ ArchFusion OS est prêt pour la compilation et les tests avancés"
    else
        echo "🔧 $FEATURES_FAILED fonctionnalité(s) critique(s) nécessite(nt) une attention"
        echo "📋 Consultez les détails ci-dessus pour les corrections nécessaires"
    fi
    
    if [ $FEATURES_WARNINGS -gt 0 ]; then
        echo "⚠️  $FEATURES_WARNINGS avertissement(s) détecté(s) - fonctionnalités optionnelles"
        echo "💡 Ces éléments peuvent améliorer l'expérience utilisateur"
    fi
    
    echo ""
    echo "🚀 Prochaines étapes recommandées:"
    echo "   1. Corriger les fonctionnalités échouées (si applicable)"
    echo "   2. Considérer l'ajout des fonctionnalités optionnelles"
    echo "   3. Lancer la compilation de test avec ./build-iso.sh"
    echo "   4. Effectuer des tests en machine virtuelle"
    
    return $FEATURES_FAILED
}

# Fonction principale
main() {
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                  🧪 VALIDATION DES FONCTIONNALITÉS ARCHFUSION 🧪            ║"
    echo "║                        Tests complets sans installation                      ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    info "Répertoire de test: $PROJECT_ROOT"
    info "Configuration ArchISO: $ARCHISO_DIR"
    echo ""
    
    # Exécution des tests par version
    test_archfusion_v11_features
    echo ""
    test_archfusion_v12_features
    echo ""
    test_archfusion_v20_features
    echo ""
    
    # Tests d'intégration
    test_service_integration
    echo ""
    test_theming_customization
    echo ""
    test_hardware_compatibility
    echo ""
    test_performance_optimization
    echo ""
    test_security_features
    echo ""
    
    # Génération du rapport final
    generate_detailed_report
}

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi