#!/bin/bash

# Tests de configuration ArchFusion OS
# Validation des fichiers et configurations sans installation

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ARCHISO_DIR="$PROJECT_ROOT/archiso"
TESTS_PASSED=0
TESTS_FAILED=0

# Fonctions utilitaires
log() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

warning() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $1"
}

# Test de la structure des fichiers
test_file_structure() {
    log "Test de la structure des fichiers..."
    
    local required_files=(
        "$ARCHISO_DIR/profiledef.sh"
        "$ARCHISO_DIR/packages.x86_64"
        "$ARCHISO_DIR/pacman.conf"
        "$ARCHISO_DIR/airootfs/usr/local/bin/archfusion-setup.sh"
        "$ARCHISO_DIR/airootfs/usr/local/bin/welcome.sh"
        "$ARCHISO_DIR/airootfs/usr/local/bin/archfusion-help"
        "$ARCHISO_DIR/airootfs/etc/skel/.zshrc"
        "$ARCHISO_DIR/airootfs/etc/skel/.config/kdeglobals"
        "$ARCHISO_DIR/airootfs/etc/skel/.config/kwinrc"
        "$ARCHISO_DIR/airootfs/etc/sddm.conf"
        "$PROJECT_ROOT/build-iso.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            success "Fichier présent: $(basename "$file")"
        else
            fail "Fichier manquant: $file"
        fi
    done
}

# Test de la syntaxe des scripts
test_script_syntax() {
    log "Test de la syntaxe des scripts..."
    
    local scripts=(
        "$ARCHISO_DIR/airootfs/usr/local/bin/archfusion-setup.sh"
        "$ARCHISO_DIR/airootfs/usr/local/bin/welcome.sh"
        "$PROJECT_ROOT/build-iso.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            if bash -n "$script" 2>/dev/null; then
                success "Syntaxe valide: $(basename "$script")"
            else
                fail "Erreur de syntaxe: $(basename "$script")"
            fi
        fi
    done
}

# Test des permissions
test_permissions() {
    log "Test des permissions des fichiers..."
    
    local executable_files=(
        "$ARCHISO_DIR/airootfs/usr/local/bin/archfusion-setup.sh"
        "$ARCHISO_DIR/airootfs/usr/local/bin/welcome.sh"
        "$ARCHISO_DIR/airootfs/usr/local/bin/archfusion-help"
        "$PROJECT_ROOT/build-iso.sh"
    )
    
    for file in "${executable_files[@]}"; do
        if [ -f "$file" ] && [ -x "$file" ]; then
            success "Permissions correctes: $(basename "$file")"
        else
            fail "Permissions incorrectes: $(basename "$file")"
        fi
    done
}

# Test du contenu des fichiers de configuration
test_config_content() {
    log "Test du contenu des configurations..."
    
    # Test profiledef.sh
    if [ -f "$ARCHISO_DIR/profiledef.sh" ]; then
        if grep -q "iso_name=\"archfusion\"" "$ARCHISO_DIR/profiledef.sh"; then
            success "Configuration ISO correcte"
        else
            fail "Configuration ISO incorrecte"
        fi
    fi
    
    # Test packages.x86_64
    if [ -f "$ARCHISO_DIR/packages.x86_64" ]; then
        local required_packages=("base" "linux" "plasma-meta" "firefox" "git")
        for package in "${required_packages[@]}"; do
            if grep -q "^$package$" "$ARCHISO_DIR/packages.x86_64"; then
                success "Paquet requis présent: $package"
            else
                fail "Paquet requis manquant: $package"
            fi
        done
    fi
    
    # Test configuration KDE
    if [ -f "$ARCHISO_DIR/airootfs/etc/skel/.config/kdeglobals" ]; then
        if grep -q "ColorScheme=BreezeDark" "$ARCHISO_DIR/airootfs/etc/skel/.config/kdeglobals"; then
            success "Thème KDE configuré correctement"
        else
            fail "Configuration thème KDE incorrecte"
        fi
    fi
}

# Test des services systemd
test_systemd_services() {
    log "Test des services systemd..."
    
    local service_file="$ARCHISO_DIR/airootfs/etc/systemd/system/archfusion-setup.service"
    if [ -f "$service_file" ]; then
        if grep -q "ExecStart=/usr/local/bin/archfusion-setup.sh" "$service_file"; then
            success "Service ArchFusion configuré"
        else
            fail "Configuration service ArchFusion incorrecte"
        fi
    else
        fail "Fichier service ArchFusion manquant"
    fi
}

# Test des optimisations système
test_system_optimizations() {
    log "Test des optimisations système..."
    
    # Test modprobe.d
    local modprobe_file="$ARCHISO_DIR/airootfs/etc/modprobe.d/archfusion.conf"
    if [ -f "$modprobe_file" ]; then
        if grep -q "options snd-hda-intel power_save=1" "$modprobe_file"; then
            success "Optimisations audio configurées"
        else
            fail "Optimisations audio manquantes"
        fi
    fi
    
    # Test NetworkManager
    local nm_file="$ARCHISO_DIR/airootfs/etc/NetworkManager/NetworkManager.conf"
    if [ -f "$nm_file" ]; then
        if grep -q "dhcp=internal" "$nm_file"; then
            success "Configuration NetworkManager correcte"
        else
            fail "Configuration NetworkManager incorrecte"
        fi
    fi
}

# Test de la configuration Zsh
test_zsh_config() {
    log "Test de la configuration Zsh..."
    
    local zshrc_file="$ARCHISO_DIR/airootfs/etc/skel/.zshrc"
    if [ -f "$zshrc_file" ]; then
        local required_aliases=("archfusion-update" "archfusion-clean" "archfusion-info")
        for alias_name in "${required_aliases[@]}"; do
            if grep -q "alias $alias_name=" "$zshrc_file"; then
                success "Alias présent: $alias_name"
            else
                fail "Alias manquant: $alias_name"
            fi
        done
    fi
}

# Test de sécurité
test_security_config() {
    log "Test des configurations de sécurité..."
    
    # Test UFW
    local ufw_file="$ARCHISO_DIR/airootfs/etc/ufw/ufw.conf"
    if [ -f "$ufw_file" ]; then
        if grep -q "ENABLED=yes" "$ufw_file"; then
            success "UFW activé par défaut"
        else
            fail "UFW non activé"
        fi
    fi
}

# Test des fonctionnalités gaming
test_gaming_features() {
    log "Test des fonctionnalités gaming..."
    
    if [ -f "$ARCHISO_DIR/packages.x86_64" ]; then
        local gaming_packages=("steam" "lutris" "wine" "gamemode")
        for package in "${gaming_packages[@]}"; do
            if grep -q "^$package$" "$ARCHISO_DIR/packages.x86_64"; then
                success "Paquet gaming présent: $package"
            else
                warning "Paquet gaming optionnel manquant: $package"
            fi
        done
    fi
}

# Test de validation JSON/YAML (si applicable)
test_config_syntax() {
    log "Test de la syntaxe des fichiers de configuration..."
    
    # Vérifier les fichiers .conf pour les erreurs de syntaxe basiques
    find "$ARCHISO_DIR" -name "*.conf" -type f | while read -r conf_file; do
        if [ -s "$conf_file" ]; then
            # Vérifier qu'il n'y a pas de caractères de contrôle étranges
            if file "$conf_file" | grep -q "text"; then
                success "Fichier de configuration valide: $(basename "$conf_file")"
            else
                fail "Fichier de configuration corrompu: $(basename "$conf_file")"
            fi
        fi
    done
}

# Génération du rapport de test
generate_report() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                          📊 RAPPORT DE TESTS 📊                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📈 Tests réussis: $TESTS_PASSED"
    echo "📉 Tests échoués: $TESTS_FAILED"
    echo "📊 Total: $((TESTS_PASSED + TESTS_FAILED))"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 Tous les tests sont passés avec succès!${NC}"
        echo "✅ ArchFusion OS est prêt pour la compilation"
        return 0
    else
        echo -e "${RED}❌ $TESTS_FAILED test(s) ont échoué${NC}"
        echo "🔧 Veuillez corriger les erreurs avant de continuer"
        return 1
    fi
}

# Fonction principale
main() {
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🧪 TESTS ARCHFUSION OS CONFIG 🧪                         ║"
    echo "║                   Validation sans installation système                       ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    test_file_structure
    test_script_syntax
    test_permissions
    test_config_content
    test_systemd_services
    test_system_optimizations
    test_zsh_config
    test_security_config
    test_gaming_features
    test_config_syntax
    
    generate_report
}

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi