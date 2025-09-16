#!/bin/bash

# Test rapide ArchFusion OS - Validation essentielle
# Version simplifiée pour tests immédiats

set -e

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHISO_DIR="$SCRIPT_DIR/archiso"
PASSED=0
FAILED=0

# Fonctions
success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASSED++))
}

fail() {
    echo -e "${RED}❌ $1${NC}"
    ((FAILED++))
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Tests essentiels
echo -e "${BLUE}🧪 TESTS RAPIDES ARCHFUSION OS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

info "Vérification de la structure de base..."

# Test 1: Fichiers de configuration ISO
if [ -f "$ARCHISO_DIR/profiledef.sh" ]; then
    success "Configuration ISO (profiledef.sh)"
else
    fail "Configuration ISO manquante"
fi

if [ -f "$ARCHISO_DIR/packages.x86_64" ]; then
    success "Liste des paquets (packages.x86_64)"
else
    fail "Liste des paquets manquante"
fi

if [ -f "$ARCHISO_DIR/pacman.conf" ]; then
    success "Configuration Pacman (pacman.conf)"
else
    fail "Configuration Pacman manquante"
fi

# Test 2: Scripts ArchFusion
if [ -f "$ARCHISO_DIR/airootfs/usr/local/bin/archfusion-setup.sh" ] && [ -x "$ARCHISO_DIR/airootfs/usr/local/bin/archfusion-setup.sh" ]; then
    success "Script de configuration ArchFusion"
else
    fail "Script de configuration ArchFusion manquant ou non exécutable"
fi

if [ -f "$ARCHISO_DIR/airootfs/usr/local/bin/welcome.sh" ] && [ -x "$ARCHISO_DIR/airootfs/usr/local/bin/welcome.sh" ]; then
    success "Script de bienvenue"
else
    fail "Script de bienvenue manquant ou non exécutable"
fi

if [ -f "$ARCHISO_DIR/airootfs/usr/local/bin/archfusion-help" ] && [ -x "$ARCHISO_DIR/airootfs/usr/local/bin/archfusion-help" ]; then
    success "Script d'aide ArchFusion"
else
    fail "Script d'aide manquant ou non exécutable"
fi

# Test 3: Configuration KDE
if [ -f "$ARCHISO_DIR/airootfs/etc/skel/.config/kdeglobals" ]; then
    success "Configuration KDE globale"
else
    fail "Configuration KDE globale manquante"
fi

if [ -f "$ARCHISO_DIR/airootfs/etc/skel/.config/kwinrc" ]; then
    success "Configuration KWin"
else
    fail "Configuration KWin manquante"
fi

if [ -f "$ARCHISO_DIR/airootfs/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc" ]; then
    success "Configuration Plasma Desktop"
else
    fail "Configuration Plasma Desktop manquante"
fi

# Test 4: Configuration système
if [ -f "$ARCHISO_DIR/airootfs/etc/skel/.zshrc" ]; then
    success "Configuration Zsh personnalisée"
else
    fail "Configuration Zsh manquante"
fi

if [ -f "$ARCHISO_DIR/airootfs/etc/NetworkManager/NetworkManager.conf" ]; then
    success "Configuration NetworkManager"
else
    fail "Configuration NetworkManager manquante"
fi

if [ -f "$ARCHISO_DIR/airootfs/etc/modprobe.d/archfusion.conf" ]; then
    success "Optimisations système (modprobe)"
else
    fail "Optimisations système manquantes"
fi

# Test 5: Services systemd
if [ -f "$ARCHISO_DIR/airootfs/etc/systemd/system/archfusion-setup.service" ]; then
    success "Service ArchFusion Setup"
else
    fail "Service ArchFusion Setup manquant"
fi

# Test 6: Sécurité
if [ -f "$ARCHISO_DIR/airootfs/etc/ufw/ufw.conf" ]; then
    success "Configuration pare-feu UFW"
else
    fail "Configuration UFW manquante"
fi

if [ -f "$ARCHISO_DIR/airootfs/etc/sddm.conf" ]; then
    success "Configuration gestionnaire de connexion SDDM"
else
    fail "Configuration SDDM manquante"
fi

# Test 7: Script de compilation
if [ -f "$SCRIPT_DIR/build-iso.sh" ] && [ -x "$SCRIPT_DIR/build-iso.sh" ]; then
    success "Script de compilation ISO"
else
    fail "Script de compilation manquant ou non exécutable"
fi

# Test 8: Contenu des fichiers critiques
info "Vérification du contenu des fichiers critiques..."

if [ -f "$ARCHISO_DIR/profiledef.sh" ] && grep -q "iso_name=\"archfusion\"" "$ARCHISO_DIR/profiledef.sh"; then
    success "Nom ISO configuré correctement"
else
    fail "Nom ISO incorrect dans profiledef.sh"
fi

if [ -f "$ARCHISO_DIR/packages.x86_64" ] && grep -q "plasma-meta" "$ARCHISO_DIR/packages.x86_64"; then
    success "Environnement KDE Plasma inclus"
else
    fail "KDE Plasma manquant dans les paquets"
fi

if [ -f "$ARCHISO_DIR/airootfs/etc/skel/.config/kdeglobals" ] && grep -q "ColorScheme=BreezeDark" "$ARCHISO_DIR/airootfs/etc/skel/.config/kdeglobals"; then
    success "Thème sombre KDE configuré"
else
    fail "Thème KDE non configuré"
fi

# Résultats
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📊 RÉSULTATS DES TESTS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "✅ Tests réussis: ${GREEN}$PASSED${NC}"
echo -e "❌ Tests échoués: ${RED}$FAILED${NC}"
echo -e "📊 Total: $((PASSED + FAILED))"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 TOUS LES TESTS SONT PASSÉS!${NC}"
    echo -e "${GREEN}✅ ArchFusion OS est correctement configuré${NC}"
    echo -e "${YELLOW}🚀 Vous pouvez maintenant compiler l'ISO avec: ./build-iso.sh${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}⚠️  $FAILED test(s) ont échoué${NC}"
    echo -e "${YELLOW}🔧 Veuillez corriger les erreurs avant de continuer${NC}"
    exit 1
fi