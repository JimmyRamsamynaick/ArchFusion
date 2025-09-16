# ArchFusion OS - Makefile
# Automatisation de la génération d'ISO et des tâches de développement
# Auteur: Jimmy Ramsamynaick

# Variables de configuration
DISTRO_NAME := ArchFusion
DISTRO_VERSION := 1.0.0
PROJECT_ROOT := $(shell pwd)
BUILD_DIR := $(PROJECT_ROOT)/build
ISO_DIR := $(PROJECT_ROOT)/iso
SCRIPTS_DIR := $(PROJECT_ROOT)/scripts

# Couleurs pour l'affichage
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[1;37m
NC := \033[0m

# Cibles par défaut
.PHONY: all help clean build-iso test-iso install-deps check-deps setup-dev

# Cible par défaut
all: help

# Affichage de l'aide
help:
	@echo -e "$(CYAN)"
	@echo "╔═══════════════════════════════════════════════════════════╗"
	@echo "║                                                           ║"
	@echo "║     █████╗ ██████╗  ██████╗██╗  ██╗███████╗██╗   ██╗      ║"
	@echo "║    ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝██║   ██║      ║"
	@echo "║    ███████║██████╔╝██║     ███████║█████╗  ██║   ██║      ║"
	@echo "║    ██╔══██║██╔══██╗██║     ██╔══██║██╔══╝  ██║   ██║      ║"
	@echo "║    ██║  ██║██║  ██║╚██████╗██║  ██║██║     ╚██████╔╝      ║"
	@echo "║    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝      ╚═════╝       ║"
	@echo "║                                                           ║"
	@echo "║              🔥 Makefile de Développement                 ║"
	@echo "║                                                           ║"
	@echo "╚═══════════════════════════════════════════════════════════╝"
	@echo -e "$(NC)"
	@echo -e "$(WHITE)ArchFusion OS - Version $(DISTRO_VERSION)$(NC)"
	@echo -e "$(PURPLE)Par Jimmy Ramsamynaick$(NC)"
	@echo ""
	@echo -e "$(YELLOW)COMMANDES DISPONIBLES:$(NC)"
	@echo ""
	@echo -e "$(GREEN)🏗️  GÉNÉRATION D'ISO:$(NC)"
	@echo -e "  $(WHITE)make build-iso$(NC)      - Générer l'ISO ArchFusion"
	@echo -e "  $(WHITE)make build-iso-clean$(NC) - Nettoyer et générer l'ISO"
	@echo -e "  $(WHITE)make test-iso$(NC)       - Tester l'ISO avec QEMU"
	@echo ""
	@echo -e "$(GREEN)🔧 DÉVELOPPEMENT:$(NC)"
	@echo -e "  $(WHITE)make setup-dev$(NC)      - Configurer l'environnement de développement"
	@echo -e "  $(WHITE)make install-deps$(NC)   - Installer les dépendances"
	@echo -e "  $(WHITE)make check-deps$(NC)     - Vérifier les dépendances"
	@echo -e "  $(WHITE)make lint$(NC)           - Vérifier la syntaxe des scripts"
	@echo ""
	@echo -e "$(GREEN)📦 PACKAGING:$(NC)"
	@echo -e "  $(WHITE)make package$(NC)        - Créer un package de distribution"
	@echo -e "  $(WHITE)make release$(NC)        - Préparer une release"
	@echo -e "  $(WHITE)make checksums$(NC)      - Générer les checksums"
	@echo ""
	@echo -e "$(GREEN)🧹 MAINTENANCE:$(NC)"
	@echo -e "  $(WHITE)make clean$(NC)          - Nettoyer les fichiers temporaires"
	@echo -e "  $(WHITE)make clean-all$(NC)      - Nettoyage complet"
	@echo -e "  $(WHITE)make backup$(NC)         - Sauvegarder le projet"
	@echo ""
	@echo -e "$(GREEN)ℹ️  INFORMATIONS:$(NC)"
	@echo -e "  $(WHITE)make info$(NC)           - Informations sur le projet"
	@echo -e "  $(WHITE)make help$(NC)           - Afficher cette aide"
	@echo ""

# Vérification des dépendances
check-deps:
	@echo -e "$(BLUE)🔍 Vérification des dépendances...$(NC)"
	@command -v archiso >/dev/null 2>&1 || { echo -e "$(RED)❌ archiso manquant$(NC)"; exit 1; }
	@command -v mkarchiso >/dev/null 2>&1 || { echo -e "$(RED)❌ mkarchiso manquant$(NC)"; exit 1; }
	@command -v pacman >/dev/null 2>&1 || { echo -e "$(RED)❌ pacman manquant$(NC)"; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo -e "$(RED)❌ git manquant$(NC)"; exit 1; }
	@echo -e "$(GREEN)✓ Toutes les dépendances sont présentes$(NC)"

# Installation des dépendances
install-deps:
	@echo -e "$(BLUE)📦 Installation des dépendances...$(NC)"
	@if command -v pacman >/dev/null 2>&1; then \
		sudo pacman -S --needed --noconfirm archiso git base-devel; \
	elif command -v apt >/dev/null 2>&1; then \
		sudo apt update && sudo apt install -y git build-essential; \
		echo -e "$(YELLOW)⚠️  archiso non disponible sur ce système$(NC)"; \
	else \
		echo -e "$(RED)❌ Gestionnaire de paquets non supporté$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(GREEN)✓ Dépendances installées$(NC)"

# Configuration de l'environnement de développement
setup-dev: install-deps
	@echo -e "$(BLUE)🛠️  Configuration de l'environnement de développement...$(NC)"
	@mkdir -p $(BUILD_DIR) $(ISO_DIR)
	@chmod +x $(SCRIPTS_DIR)/*.sh 2>/dev/null || true
	@chmod +x $(SCRIPTS_DIR)/*/*.sh 2>/dev/null || true
	@chmod +x $(SCRIPTS_DIR)/*/*.py 2>/dev/null || true
	@echo -e "$(GREEN)✓ Environnement de développement configuré$(NC)"

# Génération de l'ISO
build-iso: check-deps
	@echo -e "$(BLUE)🏗️  Génération de l'ISO ArchFusion...$(NC)"
	@if [ "$(shell id -u)" != "0" ]; then \
		echo -e "$(RED)❌ Cette commande doit être exécutée en tant que root$(NC)"; \
		echo -e "$(YELLOW)Utilisez: sudo make build-iso$(NC)"; \
		exit 1; \
	fi
	@$(SCRIPTS_DIR)/build-iso.sh
	@echo -e "$(GREEN)✓ ISO générée avec succès$(NC)"

# Génération de l'ISO avec nettoyage préalable
build-iso-clean: clean build-iso

# Test de l'ISO avec QEMU
test-iso:
	@echo -e "$(BLUE)🧪 Test de l'ISO avec QEMU...$(NC)"
	@if [ ! -f "$(ISO_DIR)/archfusion-$(DISTRO_VERSION)-x86_64.iso" ]; then \
		echo -e "$(RED)❌ ISO non trouvée. Générez d'abord l'ISO avec 'make build-iso'$(NC)"; \
		exit 1; \
	fi
	@if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then \
		echo -e "$(RED)❌ QEMU non installé$(NC)"; \
		echo -e "$(YELLOW)Installation: sudo pacman -S qemu$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(GREEN)🚀 Lancement de QEMU...$(NC)"
	@qemu-system-x86_64 \
		-cdrom "$(ISO_DIR)/archfusion-$(DISTRO_VERSION)-x86_64.iso" \
		-m 2048 \
		-enable-kvm \
		-boot d \
		-vga std \
		-display gtk &
	@echo -e "$(GREEN)✓ QEMU lancé en arrière-plan$(NC)"

# Vérification de la syntaxe des scripts
lint:
	@echo -e "$(BLUE)🔍 Vérification de la syntaxe des scripts...$(NC)"
	@find $(SCRIPTS_DIR) -name "*.sh" -exec bash -n {} \; && \
		echo -e "$(GREEN)✓ Syntaxe des scripts bash OK$(NC)" || \
		echo -e "$(RED)❌ Erreurs de syntaxe détectées$(NC)"
	@find $(SCRIPTS_DIR) -name "*.py" -exec python3 -m py_compile {} \; 2>/dev/null && \
		echo -e "$(GREEN)✓ Syntaxe des scripts Python OK$(NC)" || \
		echo -e "$(YELLOW)⚠️  Vérification Python ignorée (py_compile non disponible)$(NC)"

# Génération des checksums
checksums:
	@echo -e "$(BLUE)🔐 Génération des checksums...$(NC)"
	@if [ -f "$(ISO_DIR)/archfusion-$(DISTRO_VERSION)-x86_64.iso" ]; then \
		cd $(ISO_DIR) && \
		sha256sum archfusion-$(DISTRO_VERSION)-x86_64.iso > archfusion-$(DISTRO_VERSION)-x86_64.iso.sha256 && \
		md5sum archfusion-$(DISTRO_VERSION)-x86_64.iso > archfusion-$(DISTRO_VERSION)-x86_64.iso.md5 && \
		echo -e "$(GREEN)✓ Checksums générés$(NC)"; \
	else \
		echo -e "$(RED)❌ ISO non trouvée$(NC)"; \
		exit 1; \
	fi

# Création d'un package de distribution
package: build-iso checksums
	@echo -e "$(BLUE)📦 Création du package de distribution...$(NC)"
	@mkdir -p $(BUILD_DIR)/package
	@cp -r $(ISO_DIR)/* $(BUILD_DIR)/package/
	@cp README.md $(BUILD_DIR)/package/ 2>/dev/null || true
	@cp LICENSE $(BUILD_DIR)/package/ 2>/dev/null || true
	@cd $(BUILD_DIR) && tar -czf archfusion-$(DISTRO_VERSION)-complete.tar.gz package/
	@echo -e "$(GREEN)✓ Package créé: $(BUILD_DIR)/archfusion-$(DISTRO_VERSION)-complete.tar.gz$(NC)"

# Préparation d'une release
release: package
	@echo -e "$(BLUE)🚀 Préparation de la release $(DISTRO_VERSION)...$(NC)"
	@echo -e "$(YELLOW)Fichiers de release:$(NC)"
	@ls -la $(ISO_DIR)/
	@ls -la $(BUILD_DIR)/archfusion-$(DISTRO_VERSION)-complete.tar.gz
	@echo -e "$(GREEN)✓ Release $(DISTRO_VERSION) prête$(NC)"

# Sauvegarde du projet
backup:
	@echo -e "$(BLUE)💾 Sauvegarde du projet...$(NC)"
	@BACKUP_NAME="archfusion-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz"
	@tar --exclude='$(BUILD_DIR)' --exclude='$(ISO_DIR)' --exclude='.git' \
		-czf "$$BACKUP_NAME" .
	@echo -e "$(GREEN)✓ Sauvegarde créée: $$BACKUP_NAME$(NC)"

# Nettoyage des fichiers temporaires
clean:
	@echo -e "$(BLUE)🧹 Nettoyage des fichiers temporaires...$(NC)"
	@rm -rf $(BUILD_DIR)/work $(BUILD_DIR)/out $(BUILD_DIR)/archiso-profile
	@echo -e "$(GREEN)✓ Fichiers temporaires supprimés$(NC)"

# Nettoyage complet
clean-all:
	@echo -e "$(BLUE)🧹 Nettoyage complet...$(NC)"
	@rm -rf $(BUILD_DIR) $(ISO_DIR)
	@echo -e "$(GREEN)✓ Nettoyage complet effectué$(NC)"

# Informations sur le projet
info:
	@echo -e "$(CYAN)ℹ️  Informations sur le projet$(NC)"
	@echo ""
	@echo -e "$(WHITE)Nom:$(NC) $(DISTRO_NAME)"
	@echo -e "$(WHITE)Version:$(NC) $(DISTRO_VERSION)"
	@echo -e "$(WHITE)Répertoire:$(NC) $(PROJECT_ROOT)"
	@echo -e "$(WHITE)Build:$(NC) $(BUILD_DIR)"
	@echo -e "$(WHITE)ISO:$(NC) $(ISO_DIR)"
	@echo ""
	@echo -e "$(WHITE)Fichiers du projet:$(NC)"
	@find . -maxdepth 2 -type f -name "*.sh" -o -name "*.py" -o -name "*.conf" | sort
	@echo ""
	@if [ -f "$(ISO_DIR)/archfusion-$(DISTRO_VERSION)-x86_64.iso" ]; then \
		echo -e "$(GREEN)✓ ISO disponible:$(NC) $(shell du -h $(ISO_DIR)/archfusion-$(DISTRO_VERSION)-x86_64.iso | cut -f1)"; \
	else \
		echo -e "$(YELLOW)⚠️  ISO non générée$(NC)"; \
	fi

# Cibles qui ne correspondent pas à des fichiers
.PHONY: help check-deps install-deps setup-dev build-iso build-iso-clean test-iso lint checksums package release backup clean clean-all info