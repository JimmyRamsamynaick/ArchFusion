#!/bin/bash

# Script pour télécharger l'ISO ArchLinux
echo "🔽 Téléchargement de l'ISO ArchLinux..."

# Créer le dossier archlinux s'il n'existe pas
mkdir -p archlinux

# URL de l'ISO ArchLinux (dernière version)
ISO_URL="https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso"
ISO_FILE="archlinux/archlinux-2025.09.01-x86_64.iso"

echo "📥 Téléchargement depuis: $ISO_URL"
echo "📁 Destination: $ISO_FILE"

# Télécharger avec curl
curl -L --progress-bar -o "$ISO_FILE" "$ISO_URL"

if [ $? -eq 0 ]; then
    echo "✅ ISO téléchargé avec succès!"
    echo "📊 Taille du fichier:"
    ls -lh "$ISO_FILE"
else
    echo "❌ Erreur lors du téléchargement"
    exit 1
fi
