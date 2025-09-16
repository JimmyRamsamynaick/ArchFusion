#!/bin/bash

# Script principal de test ArchFusion OS
# Orchestre tous les tests sans installation système

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$SCRIPT_DIR/tests"
DOCKER_DIR="$SCRIPT_DIR/docker"
REPORTS_DIR="$SCRIPT_DIR/test-reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$REPORTS_DIR/archfusion_test_report_$TIMESTAMP.txt"

# Configuration
DOCKER_AVAILABLE=false
VERBOSE=false
QUICK_MODE=false
PERFORMANCE_TEST=false

# Fonctions utilitaires
log() {
    echo -e "${BLUE}[ARCHFUSION-TEST]${NC} $1"
    [ -f "$REPORT_FILE" ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$REPORT_FILE"
}

success() {
    echo -e "${GREEN}[✓ SUCCESS]${NC} $1"
    [ -f "$REPORT_FILE" ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1" >> "$REPORT_FILE"
}

fail() {
    echo -e "${RED}[✗ FAILED]${NC} $1"
    [ -f "$REPORT_FILE" ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] FAILED: $1" >> "$REPORT_FILE"
}

warning() {
    echo -e "${YELLOW}[⚠ WARNING]${NC} $1"
    [ -f "$REPORT_FILE" ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1" >> "$REPORT_FILE"
}

info() {
    echo -e "${CYAN}[ℹ INFO]${NC} $1"
    [ -f "$REPORT_FILE" ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" >> "$REPORT_FILE"
}

# Fonction d'aide
show_help() {
    echo -e "${BOLD}ArchFusion OS - Suite de Tests Complète${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Afficher cette aide"
    echo "  -v, --verbose       Mode verbeux"
    echo "  -q, --quick         Mode rapide (tests essentiels uniquement)"
    echo "  -d, --docker        Utiliser l'environnement Docker"
    echo "  -p, --performance   Inclure les tests de performance"
    echo "  -r, --report-only   Générer uniquement le rapport"
    echo "  --clean            Nettoyer les anciens rapports"
    echo ""
    echo "Exemples:"
    echo "  $0                  # Tests standard"
    echo "  $0 -v -d            # Tests verbeux avec Docker"
    echo "  $0 -q               # Tests rapides"
    echo "  $0 -p               # Tests avec performance"
    echo ""
}

# Vérification des prérequis
check_prerequisites() {
    log "🔍 Vérification des prérequis..."
    
    # Vérifier la structure du projet
    if [ ! -d "$SCRIPT_DIR/archiso" ]; then
        fail "Répertoire archiso manquant"
        return 1
    fi
    
    # Créer le répertoire de rapports
    mkdir -p "$REPORTS_DIR"
    
    # Vérifier Docker si demandé
    if command -v docker >/dev/null 2>&1 && command -v docker-compose >/dev/null 2>&1; then
        DOCKER_AVAILABLE=true
        success "Docker disponible"
    else
        warning "Docker non disponible - tests locaux uniquement"
    fi
    
    # Vérifier les scripts de test
    local test_scripts=("$TESTS_DIR/test-config.sh" "$TESTS_DIR/validate-features.sh")
    for script in "${test_scripts[@]}"; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            success "Script de test disponible: $(basename "$script")"
        else
            fail "Script de test manquant ou non exécutable: $(basename "$script")"
            return 1
        fi
    done
    
    return 0
}

# Initialisation du rapport
init_report() {
    log "📋 Initialisation du rapport de test..."
    
    cat > "$REPORT_FILE" << EOF
╔══════════════════════════════════════════════════════════════════════════════╗
║                        RAPPORT DE TEST ARCHFUSION OS                         ║
║                              $(date '+%Y-%m-%d %H:%M:%S')                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

CONFIGURATION DE TEST:
- Timestamp: $TIMESTAMP
- Mode verbeux: $VERBOSE
- Mode rapide: $QUICK_MODE
- Tests de performance: $PERFORMANCE_TEST
- Docker disponible: $DOCKER_AVAILABLE
- Répertoire de travail: $SCRIPT_DIR

═══════════════════════════════════════════════════════════════════════════════

EOF
    
    success "Rapport initialisé: $REPORT_FILE"
}

# Tests de configuration de base
run_config_tests() {
    log "🧪 Exécution des tests de configuration..."
    
    if [ -f "$TESTS_DIR/test-config.sh" ]; then
        echo "" >> "$REPORT_FILE"
        echo "TESTS DE CONFIGURATION:" >> "$REPORT_FILE"
        echo "═══════════════════════" >> "$REPORT_FILE"
        
        if $VERBOSE; then
            "$TESTS_DIR/test-config.sh" 2>&1 | tee -a "$REPORT_FILE"
        else
            "$TESTS_DIR/test-config.sh" >> "$REPORT_FILE" 2>&1
        fi
        
        local exit_code=${PIPESTATUS[0]}
        if [ $exit_code -eq 0 ]; then
            success "Tests de configuration réussis"
            return 0
        else
            fail "Tests de configuration échoués (code: $exit_code)"
            return 1
        fi
    else
        fail "Script de test de configuration manquant"
        return 1
    fi
}

# Tests de validation des fonctionnalités
run_feature_tests() {
    log "🚀 Exécution des tests de fonctionnalités..."
    
    if [ -f "$TESTS_DIR/validate-features.sh" ]; then
        echo "" >> "$REPORT_FILE"
        echo "TESTS DE FONCTIONNALITÉS:" >> "$REPORT_FILE"
        echo "═══════════════════════════" >> "$REPORT_FILE"
        
        if $VERBOSE; then
            "$TESTS_DIR/validate-features.sh" 2>&1 | tee -a "$REPORT_FILE"
        else
            "$TESTS_DIR/validate-features.sh" >> "$REPORT_FILE" 2>&1
        fi
        
        local exit_code=${PIPESTATUS[0]}
        if [ $exit_code -eq 0 ]; then
            success "Tests de fonctionnalités réussis"
            return 0
        else
            fail "Tests de fonctionnalités échoués (code: $exit_code)"
            return 1
        fi
    else
        fail "Script de test de fonctionnalités manquant"
        return 1
    fi
}

# Tests Docker
run_docker_tests() {
    if [ "$DOCKER_AVAILABLE" = false ]; then
        warning "Tests Docker ignorés - Docker non disponible"
        return 0
    fi
    
    log "🐳 Exécution des tests Docker..."
    
    if [ -f "$DOCKER_DIR/docker-compose.test.yml" ]; then
        echo "" >> "$REPORT_FILE"
        echo "TESTS DOCKER:" >> "$REPORT_FILE"
        echo "═══════════════" >> "$REPORT_FILE"
        
        cd "$DOCKER_DIR"
        
        # Construction de l'image de test
        log "Construction de l'environnement de test Docker..."
        if docker-compose -f docker-compose.test.yml build >> "$REPORT_FILE" 2>&1; then
            success "Image Docker construite"
        else
            fail "Échec de construction de l'image Docker"
            return 1
        fi
        
        # Exécution des tests dans le container
        log "Exécution des tests dans l'environnement Docker..."
        if docker-compose -f docker-compose.test.yml up --abort-on-container-exit >> "$REPORT_FILE" 2>&1; then
            success "Tests Docker réussis"
        else
            fail "Tests Docker échoués"
            return 1
        fi
        
        # Nettoyage
        docker-compose -f docker-compose.test.yml down >> "$REPORT_FILE" 2>&1
        
        cd "$SCRIPT_DIR"
        return 0
    else
        fail "Configuration Docker Compose manquante"
        return 1
    fi
}

# Tests de performance (optionnels)
run_performance_tests() {
    if [ "$PERFORMANCE_TEST" = false ]; then
        info "Tests de performance ignorés"
        return 0
    fi
    
    log "⚡ Exécution des tests de performance..."
    
    echo "" >> "$REPORT_FILE"
    echo "TESTS DE PERFORMANCE:" >> "$REPORT_FILE"
    echo "═══════════════════════" >> "$REPORT_FILE"
    
    # Test de la taille de l'ISO (simulation)
    log "Estimation de la taille de l'ISO..."
    local archiso_size=$(du -sh "$SCRIPT_DIR/archiso" 2>/dev/null | cut -f1 || echo "N/A")
    info "Taille estimée de la configuration: $archiso_size"
    echo "Taille configuration ArchISO: $archiso_size" >> "$REPORT_FILE"
    
    # Test du nombre de paquets
    if [ -f "$SCRIPT_DIR/archiso/packages.x86_64" ]; then
        local package_count=$(wc -l < "$SCRIPT_DIR/archiso/packages.x86_64")
        info "Nombre de paquets: $package_count"
        echo "Nombre de paquets: $package_count" >> "$REPORT_FILE"
        
        if [ $package_count -gt 500 ]; then
            warning "Nombre élevé de paquets - ISO potentiellement volumineuse"
        else
            success "Nombre de paquets raisonnable"
        fi
    fi
    
    # Test de complexité des scripts
    local script_files=$(find "$SCRIPT_DIR/archiso/airootfs" -name "*.sh" -type f 2>/dev/null | wc -l)
    info "Nombre de scripts personnalisés: $script_files"
    echo "Scripts personnalisés: $script_files" >> "$REPORT_FILE"
    
    return 0
}

# Génération du rapport final
generate_final_report() {
    log "📊 Génération du rapport final..."
    
    cat >> "$REPORT_FILE" << EOF

═══════════════════════════════════════════════════════════════════════════════
RÉSUMÉ FINAL:
═══════════════════════════════════════════════════════════════════════════════

Tests exécutés le: $(date '+%Y-%m-%d à %H:%M:%S')
Durée totale: $SECONDS secondes
Rapport sauvegardé: $REPORT_FILE

RECOMMANDATIONS:
- Vérifiez les éléments marqués comme FAILED
- Les WARNING sont optionnels mais recommandés
- Consultez le rapport détaillé pour plus d'informations

PROCHAINES ÉTAPES:
1. Corriger les erreurs critiques (FAILED)
2. Considérer les améliorations (WARNING)
3. Lancer la compilation avec ./build-iso.sh
4. Tester l'ISO en machine virtuelle

═══════════════════════════════════════════════════════════════════════════════
EOF
    
    success "Rapport final généré"
    
    # Affichage du résumé
    echo ""
    echo -e "${BOLD}📋 RÉSUMÉ DES TESTS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "📄 Rapport détaillé: ${CYAN}$REPORT_FILE${NC}"
    echo -e "⏱️  Durée totale: ${YELLOW}$SECONDS secondes${NC}"
    echo -e "🔍 Mode: $([ "$QUICK_MODE" = true ] && echo "Rapide" || echo "Complet")"
    echo -e "🐳 Docker: $([ "$DOCKER_AVAILABLE" = true ] && echo "Disponible" || echo "Non disponible")"
    echo ""
}

# Nettoyage des anciens rapports
clean_old_reports() {
    log "🧹 Nettoyage des anciens rapports..."
    
    if [ -d "$REPORTS_DIR" ]; then
        # Garder seulement les 10 derniers rapports
        find "$REPORTS_DIR" -name "archfusion_test_report_*.txt" -type f | sort | head -n -10 | xargs rm -f 2>/dev/null || true
        success "Anciens rapports nettoyés"
    fi
}

# Fonction principale
main() {
    local config_result=0
    local feature_result=0
    local docker_result=0
    local performance_result=0
    
    # Initialisation
    if ! check_prerequisites; then
        fail "Prérequis non satisfaits"
        exit 1
    fi
    
    init_report
    
    # Exécution des tests selon le mode
    if [ "$QUICK_MODE" = true ]; then
        log "🚀 Mode rapide - Tests essentiels uniquement"
        run_config_tests
        config_result=$?
    else
        log "🔬 Mode complet - Tous les tests"
        
        # Tests de configuration
        run_config_tests
        config_result=$?
        
        # Tests de fonctionnalités
        run_feature_tests
        feature_result=$?
        
        # Tests Docker (si disponible et demandé)
        if [ "$DOCKER_AVAILABLE" = true ] && [ -f "$DOCKER_DIR/docker-compose.test.yml" ]; then
            run_docker_tests
            docker_result=$?
        fi
        
        # Tests de performance (si demandés)
        run_performance_tests
        performance_result=$?
    fi
    
    # Génération du rapport final
    generate_final_report
    
    # Calcul du résultat global
    local total_failures=$((config_result + feature_result + docker_result + performance_result))
    
    if [ $total_failures -eq 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 TOUS LES TESTS SONT PASSÉS AVEC SUCCÈS!${NC}"
        echo -e "${GREEN}✅ ArchFusion OS est prêt pour la compilation${NC}"
        exit 0
    else
        echo ""
        echo -e "${RED}❌ $total_failures test(s) ont échoué${NC}"
        echo -e "${YELLOW}🔧 Consultez le rapport pour les détails: $REPORT_FILE${NC}"
        exit 1
    fi
}

# Traitement des arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quick)
            QUICK_MODE=true
            shift
            ;;
        -d|--docker)
            # Docker sera utilisé s'il est disponible
            shift
            ;;
        -p|--performance)
            PERFORMANCE_TEST=true
            shift
            ;;
        -r|--report-only)
            # Mode rapport uniquement (pour implémentation future)
            shift
            ;;
        --clean)
            clean_old_reports
            exit 0
            ;;
        *)
            echo "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Bannière de démarrage
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    🧪 SUITE DE TESTS ARCHFUSION OS 🧪                       ║"
echo "║                        Tests complets sans installation                      ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Exécution principale
main "$@"