#!/bin/bash

# Script de bienvenue ArchFusion OS

clear

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║     █████╗ ██████╗  ██████╗██╗  ██╗███████╗██╗   ██╗███████╗██╗ ██████╗ ███╗ ║
║    ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝██║   ██║██╔════╝██║██╔═══██╗████║ ║
║    ███████║██████╔╝██║     ███████║█████╗  ██║   ██║███████╗██║██║   ██║██╔██║ ║
║    ██╔══██║██╔══██╗██║     ██╔══██║██╔══╝  ██║   ██║╚════██║██║██║   ██║██║╚██║ ║
║    ██║  ██║██║  ██║╚██████╗██║  ██║██║     ╚██████╔╝███████║██║╚██████╔╝██║ ╚██║ ║
║    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝ ║
║                                                                              ║
║                        🚀 Bienvenue dans ArchFusion OS! 🚀                   ║
║                                                                              ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │  🎯 Distribution Linux moderne basée sur Arch Linux                    │  ║
║  │  🎨 Interface KDE Plasma avec thèmes macOS/Windows                     │  ║
║  │  🎮 Optimisée pour le gaming et la productivité                        │  ║
║  │  🔧 Outils de développement intégrés                                   │  ║
║  │  🌐 Support complet du matériel moderne                                │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                              ║
║  📋 COMMANDES UTILES:                                                        ║
║  ├─ archfusion-install    : Installer ArchFusion sur le disque dur          ║
║  ├─ archfusion-config     : Outils de configuration                         ║
║  ├─ archfusion-gaming     : Optimisations gaming                            ║
║  ├─ archfusion-themes     : Gestionnaire de thèmes                          ║
║  └─ archfusion-help       : Aide et documentation                           ║
║                                                                              ║
║  🌟 FONCTIONNALITÉS DISPONIBLES:                                             ║
║  ├─ 🎵 Audio: PipeWire avec support haute qualité                           ║
║  ├─ 🎮 Gaming: Steam, Lutris, GameMode préinstallés                         ║
║  ├─ 🎨 Multimédia: GIMP, VLC, OBS Studio                                    ║
║  ├─ 💻 Développement: Git, Python, Node.js, Docker                          ║
║  ├─ 🔒 Sécurité: UFW, ClamAV, Fail2Ban configurés                          ║
║  └─ 🚀 Performance: Optimisations SSD, mémoire et réseau                    ║
║                                                                              ║
║  📚 DOCUMENTATION: /usr/share/doc/archfusion/                                ║
║  🌐 SITE WEB: https://archfusion.org                                         ║
║  💬 SUPPORT: https://github.com/archfusion/support                           ║
║                                                                              ║
║  ⚡ Version Live - Toutes les modifications seront perdues au redémarrage    ║
║     Utilisez 'archfusion-install' pour une installation permanente          ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

EOF

echo ""
echo "🔑 Utilisateur par défaut: archfusion / Mot de passe: archfusion"
echo "🔧 Tapez 'archfusion-help' pour plus d'informations"
echo ""

# Affichage des informations système
echo "📊 INFORMATIONS SYSTÈME:"
echo "├─ Kernel: $(uname -r)"
echo "├─ Architecture: $(uname -m)"
echo "├─ Mémoire: $(free -h | awk '/^Mem:/ {print $2}')"
echo "└─ Processeur: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
echo ""

# Vérification de la connexion réseau
if ping -c 1 google.com &> /dev/null; then
    echo "🌐 Connexion Internet: ✅ Connecté"
else
    echo "🌐 Connexion Internet: ❌ Non connecté"
    echo "   Utilisez l'applet réseau pour vous connecter"
fi

echo ""
echo "🚀 Profitez de votre expérience ArchFusion OS!"
echo ""