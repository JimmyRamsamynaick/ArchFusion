#!/bin/bash

# ArchFusion OS - Script de Bienvenue
# Affiche l'interface de bienvenue au démarrage du système live

# Couleurs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

# Fonction pour afficher le menu principal
show_welcome_menu() {
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
    ║              🚀 Bienvenue dans ArchFusion OS!             ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${WHITE}🔥 Distribution Linux Révolutionnaire - Version 1.0.0${NC}"
    echo -e "${PURPLE}Par Jimmy Ramsamynaick - jimmyramsamynaick@gmail.com${NC}"
    echo ""
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                        OPTIONS DISPONIBLES${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${CYAN}🚀 INSTALLATION${NC}"
    echo -e "  ${WHITE}1)${NC} Installer ArchFusion (Interface Graphique)"
    echo -e "  ${WHITE}2)${NC} Installer ArchFusion (Ligne de Commande)"
    echo -e "  ${WHITE}3)${NC} Partitionnement Manuel (GParted)"
    echo ""
    
    echo -e "${CYAN}🔧 OUTILS SYSTÈME${NC}"
    echo -e "  ${WHITE}4)${NC} Tester la Mémoire (Memtest86+)"
    echo -e "  ${WHITE}5)${NC} Vérifier le Disque Dur"
    echo -e "  ${WHITE}6)${NC} Informations Système"
    echo -e "  ${WHITE}7)${NC} Test de Connectivité Réseau"
    echo ""
    
    echo -e "${CYAN}💻 ENVIRONNEMENT LIVE${NC}"
    echo -e "  ${WHITE}8)${NC} Ouvrir le Terminal"
    echo -e "  ${WHITE}9)${NC} Gestionnaire de Fichiers"
    echo -e "  ${WHITE}10)${NC} Navigateur Web (Firefox)"
    echo -e "  ${WHITE}11)${NC} Éditeur de Texte (Kate)"
    echo ""
    
    echo -e "${CYAN}ℹ️  AIDE & DOCUMENTATION${NC}"
    echo -e "  ${WHITE}12)${NC} Guide d'Installation"
    echo -e "  ${WHITE}13)${NC} FAQ - Questions Fréquentes"
    echo -e "  ${WHITE}14)${NC} À Propos d'ArchFusion"
    echo ""
    
    echo -e "${CYAN}⚙️  CONFIGURATION${NC}"
    echo -e "  ${WHITE}15)${NC} Configuration Clavier"
    echo -e "  ${WHITE}16)${NC} Configuration Réseau"
    echo -e "  ${WHITE}17)${NC} Paramètres d'Affichage"
    echo ""
    
    echo -e "${RED}  ${WHITE}0)${NC} Quitter"
    echo ""
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Utilisateur Live: ${GREEN}archfusion${NC} | Mot de passe: ${GREEN}archfusion${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Fonction pour l'installation graphique
install_gui() {
    echo -e "${GREEN}🚀 Lancement de l'installateur graphique...${NC}"
    echo ""
    
    # Vérifier si l'installateur existe
    if [[ -f "/usr/local/bin/archfusion-installer-gui" ]]; then
        sudo python3 /usr/local/bin/archfusion-installer-gui
    elif [[ -f "/usr/share/archfusion/scripts/install/gui-installer.py" ]]; then
        sudo python3 /usr/share/archfusion/scripts/install/gui-installer.py
    else
        echo -e "${RED}❌ Installateur graphique non trouvé${NC}"
        echo "Utilisation de l'installateur en ligne de commande..."
        install_cli
    fi
}

# Fonction pour l'installation CLI
install_cli() {
    echo -e "${GREEN}🚀 Lancement de l'installateur en ligne de commande...${NC}"
    echo ""
    
    if [[ -f "/usr/local/bin/archfusion-installer" ]]; then
        sudo /usr/local/bin/archfusion-installer
    elif [[ -f "/usr/share/archfusion/scripts/install/install.sh" ]]; then
        sudo /usr/share/archfusion/scripts/install/install.sh
    else
        echo -e "${RED}❌ Installateur non trouvé${NC}"
        echo "Veuillez utiliser l'installation manuelle avec pacstrap"
    fi
}

# Fonction pour GParted
launch_gparted() {
    echo -e "${GREEN}🔧 Lancement de GParted...${NC}"
    if command -v gparted &> /dev/null; then
        sudo gparted &
    else
        echo -e "${RED}❌ GParted non installé${NC}"
        echo "Installation en cours..."
        sudo pacman -S --noconfirm gparted
        sudo gparted &
    fi
}

# Fonction pour Memtest
launch_memtest() {
    echo -e "${GREEN}🧪 Test de mémoire...${NC}"
    echo "Redémarrage requis pour Memtest86+"
    echo "Sélectionnez 'Memtest86+' dans le menu de démarrage"
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour vérifier le disque
check_disk() {
    echo -e "${GREEN}💾 Vérification des disques...${NC}"
    echo ""
    
    echo -e "${CYAN}Disques disponibles:${NC}"
    lsblk -f
    echo ""
    
    echo -e "${CYAN}Espace disque:${NC}"
    df -h
    echo ""
    
    echo -e "${CYAN}Informations SMART (si disponible):${NC}"
    for disk in /dev/sd[a-z]; do
        if [[ -e "$disk" ]]; then
            echo "=== $disk ==="
            sudo smartctl -H "$disk" 2>/dev/null || echo "SMART non disponible"
        fi
    done
    
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour les informations système
system_info() {
    echo -e "${GREEN}💻 Informations Système${NC}"
    echo ""
    
    # Neofetch si disponible
    if command -v neofetch &> /dev/null; then
        neofetch
    else
        echo -e "${CYAN}Système:${NC} $(uname -a)"
        echo -e "${CYAN}CPU:${NC} $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
        echo -e "${CYAN}Mémoire:${NC} $(free -h | grep Mem | awk '{print $2}')"
        echo -e "${CYAN}Stockage:${NC}"
        df -h | grep -E '^/dev'
    fi
    
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour tester le réseau
test_network() {
    echo -e "${GREEN}🌐 Test de Connectivité Réseau${NC}"
    echo ""
    
    echo -e "${CYAN}Interfaces réseau:${NC}"
    ip addr show
    echo ""
    
    echo -e "${CYAN}Test de connectivité:${NC}"
    if ping -c 3 8.8.8.8 &> /dev/null; then
        echo -e "${GREEN}✓ Connexion Internet OK${NC}"
    else
        echo -e "${RED}✗ Pas de connexion Internet${NC}"
    fi
    
    if ping -c 3 archlinux.org &> /dev/null; then
        echo -e "${GREEN}✓ Résolution DNS OK${NC}"
    else
        echo -e "${RED}✗ Problème de résolution DNS${NC}"
    fi
    
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour ouvrir le terminal
open_terminal() {
    echo -e "${GREEN}💻 Ouverture du terminal...${NC}"
    if command -v kitty &> /dev/null; then
        kitty &
    elif command -v konsole &> /dev/null; then
        konsole &
    elif command -v gnome-terminal &> /dev/null; then
        gnome-terminal &
    else
        echo "Terminal déjà ouvert dans cette fenêtre"
    fi
}

# Fonction pour le gestionnaire de fichiers
open_file_manager() {
    echo -e "${GREEN}📁 Ouverture du gestionnaire de fichiers...${NC}"
    if command -v dolphin &> /dev/null; then
        dolphin &
    elif command -v nautilus &> /dev/null; then
        nautilus &
    elif command -v thunar &> /dev/null; then
        thunar &
    else
        echo -e "${RED}❌ Gestionnaire de fichiers non trouvé${NC}"
    fi
}

# Fonction pour Firefox
open_firefox() {
    echo -e "${GREEN}🌐 Ouverture de Firefox...${NC}"
    if command -v firefox &> /dev/null; then
        firefox &
    else
        echo -e "${RED}❌ Firefox non installé${NC}"
        echo "Installation en cours..."
        sudo pacman -S --noconfirm firefox
        firefox &
    fi
}

# Fonction pour Kate
open_kate() {
    echo -e "${GREEN}📝 Ouverture de Kate...${NC}"
    if command -v kate &> /dev/null; then
        kate &
    elif command -v gedit &> /dev/null; then
        gedit &
    elif command -v nano &> /dev/null; then
        nano
    else
        echo -e "${RED}❌ Éditeur graphique non trouvé${NC}"
    fi
}

# Fonction pour le guide d'installation
show_install_guide() {
    clear
    echo -e "${GREEN}📖 Guide d'Installation ArchFusion${NC}"
    echo ""
    
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                    GUIDE D'INSTALLATION                   ║
╚═══════════════════════════════════════════════════════════╝

🚀 MÉTHODE RECOMMANDÉE - Interface Graphique:
   1. Sélectionnez l'option 1 dans le menu principal
   2. Suivez l'assistant d'installation étape par étape
   3. Configurez votre utilisateur et vos préférences
   4. L'installation se fait automatiquement

💻 MÉTHODE AVANCÉE - Ligne de Commande:
   1. Sélectionnez l'option 2 dans le menu principal
   2. Répondez aux questions de configuration
   3. Le script gère le partitionnement et l'installation

🔧 INSTALLATION MANUELLE:
   1. Partitionnez votre disque avec GParted (option 3)
   2. Montez les partitions manuellement
   3. Utilisez pacstrap pour installer le système de base
   4. Configurez le bootloader et les services

📋 PRÉREQUIS:
   • Au moins 20GB d'espace libre
   • Connexion Internet (recommandée)
   • Sauvegarde de vos données importantes
   • Support UEFI ou BIOS Legacy

⚠️  IMPORTANT:
   • L'installation effacera le disque sélectionné
   • Assurez-vous d'avoir sauvegardé vos données
   • Testez d'abord en machine virtuelle si possible

🆘 AIDE:
   • Documentation: /usr/share/doc/archfusion/
   • Support: jimmyramsamynaick@gmail.com
   • Wiki: https://github.com/JimmyRamsamynaick/ArchFusion-OS

EOF
    
    echo ""
    read -p "Appuyez sur Entrée pour revenir au menu..."
}

# Fonction pour la FAQ
show_faq() {
    clear
    echo -e "${GREEN}❓ FAQ - Questions Fréquentes${NC}"
    echo ""
    
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                          FAQ                              ║
╚═══════════════════════════════════════════════════════════╝

Q: Qu'est-ce qu'ArchFusion OS?
R: Une distribution Linux basée sur Arch Linux avec un environnement
   KDE Plasma personnalisé et des outils d'installation simplifiés.

Q: Configuration minimale requise?
R: • CPU: x86_64 (64-bit)
   • RAM: 2GB minimum, 4GB recommandé
   • Stockage: 20GB minimum
   • GPU: Compatible avec Mesa/Intel/AMD/NVIDIA

Q: Comment installer des logiciels?
R: Utilisez pacman (gestionnaire de paquets d'Arch Linux):
   • sudo pacman -S nom_du_paquet
   • Ou utilisez l'interface graphique Discover

Q: Mot de passe oublié?
R: En mode live, utilisez: sudo passwd nom_utilisateur
   Après installation, bootez en mode recovery

Q: Problème de démarrage?
R: • Vérifiez le mode UEFI/Legacy dans le BIOS
   • Désactivez le Secure Boot si nécessaire
   • Utilisez nomodeset au démarrage si problème graphique

Q: Comment mettre à jour le système?
R: sudo pacman -Syu (mise à jour complète)
   sudo pacman -Sy (mise à jour des dépôts)

Q: Support matériel?
R: ArchFusion inclut les drivers pour la plupart du matériel moderne.
   Pour du matériel spécifique, consultez le wiki Arch Linux.

Q: Où trouver de l'aide?
R: • Documentation locale: /usr/share/doc/archfusion/
   • Wiki Arch Linux: https://wiki.archlinux.org/
   • Support: jimmyramsamynaick@gmail.com

EOF
    
    echo ""
    read -p "Appuyez sur Entrée pour revenir au menu..."
}

# Fonction À propos
show_about() {
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
    ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${WHITE}🔥 ArchFusion OS - Distribution Linux Révolutionnaire${NC}"
    echo -e "${PURPLE}Version 1.0.0 - Codename: Fusion${NC}"
    echo ""
    
    echo -e "${CYAN}📋 INFORMATIONS:${NC}"
    echo -e "  Basé sur: Arch Linux"
    echo -e "  Environnement: KDE Plasma 5"
    echo -e "  Noyau: Linux $(uname -r)"
    echo -e "  Architecture: x86_64"
    echo ""
    
    echo -e "${CYAN}👨‍💻 DÉVELOPPEUR:${NC}"
    echo -e "  Nom: Jimmy Ramsamynaick"
    echo -e "  Email: jimmyramsamynaick@gmail.com"
    echo -e "  GitHub: https://github.com/JimmyRamsamynaick"
    echo ""
    
    echo -e "${CYAN}🎯 OBJECTIFS:${NC}"
    echo -e "  • Interface moderne inspirée de macOS et Windows"
    echo -e "  • Installation simplifiée pour tous les utilisateurs"
    echo -e "  • Performance et stabilité d'Arch Linux"
    echo -e "  • Outils de développement intégrés"
    echo -e "  • Support matériel étendu"
    echo ""
    
    echo -e "${CYAN}📦 LOGICIELS INCLUS:${NC}"
    echo -e "  • Firefox - Navigateur web"
    echo -e "  • Kitty - Terminal moderne"
    echo -e "  • Kate - Éditeur de texte avancé"
    echo -e "  • Dolphin - Gestionnaire de fichiers"
    echo -e "  • VLC - Lecteur multimédia"
    echo -e "  • LibreOffice - Suite bureautique"
    echo -e "  • GIMP - Éditeur d'images"
    echo -e "  • Et bien plus..."
    echo ""
    
    echo -e "${CYAN}🔗 LIENS UTILES:${NC}"
    echo -e "  • Projet: https://github.com/JimmyRamsamynaick/ArchFusion-OS"
    echo -e "  • Documentation: /usr/share/doc/archfusion/"
    echo -e "  • Support: jimmyramsamynaick@gmail.com"
    echo ""
    
    echo -e "${YELLOW}© 2024 Jimmy Ramsamynaick - Licence GPL v3${NC}"
    echo ""
    
    read -p "Appuyez sur Entrée pour revenir au menu..."
}

# Configuration clavier
configure_keyboard() {
    echo -e "${GREEN}⌨️  Configuration du Clavier${NC}"
    echo ""
    
    echo "Dispositions disponibles:"
    echo "1) Français (AZERTY)"
    echo "2) Anglais (QWERTY US)"
    echo "3) Anglais (QWERTY UK)"
    echo "4) Allemand (QWERTZ)"
    echo "5) Espagnol"
    echo ""
    
    read -p "Choisissez votre disposition (1-5): " kb_choice
    
    case $kb_choice in
        1) loadkeys fr ;;
        2) loadkeys us ;;
        3) loadkeys uk ;;
        4) loadkeys de ;;
        5) loadkeys es ;;
        *) echo "Choix invalide" ;;
    esac
    
    echo "Configuration appliquée"
    read -p "Appuyez sur Entrée pour continuer..."
}

# Configuration réseau
configure_network() {
    echo -e "${GREEN}🌐 Configuration Réseau${NC}"
    echo ""
    
    echo "1) Configuration automatique (DHCP)"
    echo "2) Configuration manuelle"
    echo "3) Configuration WiFi"
    echo "4) Afficher l'état du réseau"
    echo ""
    
    read -p "Choisissez une option (1-4): " net_choice
    
    case $net_choice in
        1)
            echo "Activation du DHCP..."
            sudo systemctl start dhcpcd
            sudo systemctl enable dhcpcd
            ;;
        2)
            echo "Configuration manuelle non implémentée dans cette version"
            echo "Utilisez 'ip' et 'route' manuellement"
            ;;
        3)
            echo "Configuration WiFi..."
            if command -v nmtui &> /dev/null; then
                sudo nmtui
            else
                echo "NetworkManager non disponible"
            fi
            ;;
        4)
            echo "État du réseau:"
            ip addr show
            echo ""
            echo "Routes:"
            ip route show
            ;;
        *)
            echo "Choix invalide"
            ;;
    esac
    
    read -p "Appuyez sur Entrée pour continuer..."
}

# Paramètres d'affichage
configure_display() {
    echo -e "${GREEN}🖥️  Paramètres d'Affichage${NC}"
    echo ""
    
    if command -v xrandr &> /dev/null; then
        echo "Écrans détectés:"
        xrandr --listmonitors
        echo ""
        echo "Résolutions disponibles:"
        xrandr
    else
        echo "xrandr non disponible (mode console)"
        echo "Utilisez les paramètres KDE une fois en mode graphique"
    fi
    
    read -p "Appuyez sur Entrée pour continuer..."
}

# Boucle principale du menu
main_loop() {
    while true; do
        show_welcome_menu
        
        read -p "$(echo -e "${WHITE}Choisissez une option (0-17): ${NC}")" choice
        
        case $choice in
            1) install_gui ;;
            2) install_cli ;;
            3) launch_gparted ;;
            4) launch_memtest ;;
            5) check_disk ;;
            6) system_info ;;
            7) test_network ;;
            8) open_terminal ;;
            9) open_file_manager ;;
            10) open_firefox ;;
            11) open_kate ;;
            12) show_install_guide ;;
            13) show_faq ;;
            14) show_about ;;
            15) configure_keyboard ;;
            16) configure_network ;;
            17) configure_display ;;
            0) 
                echo -e "${GREEN}Au revoir! 👋${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Option invalide. Veuillez choisir entre 0 et 17.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Point d'entrée principal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_loop
fi