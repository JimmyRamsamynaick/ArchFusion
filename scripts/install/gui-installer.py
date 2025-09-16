#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
ArchFusion OS - Interface Graphique d'Installation
Auteur: Jimmy Ramsamynaick
Version: 1.0.0
Description: Interface graphique moderne pour l'installation d'ArchFusion OS
"""

import sys
import os
import subprocess
import threading
import json
import time
from pathlib import Path
from typing import Dict, List, Optional, Tuple

try:
    from PyQt5.QtWidgets import (
        QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
        QLabel, QLineEdit, QPushButton, QComboBox, QCheckBox, QProgressBar,
        QTextEdit, QStackedWidget, QFrame, QScrollArea, QGridLayout,
        QButtonGroup, QRadioButton, QSpacerItem, QSizePolicy, QMessageBox,
        QFileDialog, QTabWidget, QGroupBox, QSlider, QSpinBox
    )
    from PyQt5.QtCore import Qt, QThread, pyqtSignal, QTimer, QPropertyAnimation, QEasingCurve
    from PyQt5.QtGui import QFont, QPixmap, QPalette, QColor, QIcon, QPainter, QLinearGradient
except ImportError:
    print("PyQt5 non installé. Installation en cours...")
    subprocess.run([sys.executable, "-m", "pip", "install", "PyQt5"], check=True)
    from PyQt5.QtWidgets import *
    from PyQt5.QtCore import *
    from PyQt5.QtGui import *

class ArchFusionStyle:
    """Thème et styles pour l'interface ArchFusion"""
    
    # Couleurs du thème ArchFusion
    PRIMARY = "#007AFF"      # Bleu iOS
    SECONDARY = "#5856D6"    # Violet iOS
    SUCCESS = "#34C759"      # Vert iOS
    WARNING = "#FF9500"      # Orange iOS
    DANGER = "#FF3B30"       # Rouge iOS
    DARK = "#1C1C1E"         # Gris foncé iOS
    LIGHT = "#F2F2F7"        # Gris clair iOS
    WHITE = "#FFFFFF"
    ACCENT = "#FF6B35"       # Orange ArchFusion
    
    @staticmethod
    def get_main_style():
        return f"""
        QMainWindow {{
            background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                stop:0 {ArchFusionStyle.LIGHT}, stop:1 {ArchFusionStyle.WHITE});
            color: {ArchFusionStyle.DARK};
            font-family: 'SF Pro Display', 'Segoe UI', Arial, sans-serif;
        }}
        
        QWidget {{
            background-color: transparent;
            color: {ArchFusionStyle.DARK};
        }}
        
        QLabel {{
            color: {ArchFusionStyle.DARK};
            font-weight: 500;
        }}
        
        .title {{
            font-size: 28px;
            font-weight: 700;
            color: {ArchFusionStyle.PRIMARY};
            margin: 20px 0;
        }}
        
        .subtitle {{
            font-size: 18px;
            font-weight: 600;
            color: {ArchFusionStyle.SECONDARY};
            margin: 10px 0;
        }}
        
        .description {{
            font-size: 14px;
            color: {ArchFusionStyle.DARK};
            line-height: 1.4;
        }}
        
        QPushButton {{
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                stop:0 {ArchFusionStyle.PRIMARY}, stop:1 {ArchFusionStyle.SECONDARY});
            color: white;
            border: none;
            border-radius: 12px;
            padding: 12px 24px;
            font-size: 16px;
            font-weight: 600;
            min-width: 120px;
        }}
        
        QPushButton:hover {{
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                stop:0 {ArchFusionStyle.SECONDARY}, stop:1 {ArchFusionStyle.PRIMARY});
            transform: translateY(-2px);
        }}
        
        QPushButton:pressed {{
            background: {ArchFusionStyle.DARK};
        }}
        
        QPushButton:disabled {{
            background: #CCCCCC;
            color: #666666;
        }}
        
        .danger-button {{
            background: {ArchFusionStyle.DANGER};
        }}
        
        .success-button {{
            background: {ArchFusionStyle.SUCCESS};
        }}
        
        QLineEdit {{
            background: {ArchFusionStyle.WHITE};
            border: 2px solid #E5E5EA;
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 16px;
            color: {ArchFusionStyle.DARK};
        }}
        
        QLineEdit:focus {{
            border-color: {ArchFusionStyle.PRIMARY};
            background: {ArchFusionStyle.WHITE};
        }}
        
        QComboBox {{
            background: {ArchFusionStyle.WHITE};
            border: 2px solid #E5E5EA;
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 16px;
            color: {ArchFusionStyle.DARK};
            min-width: 200px;
        }}
        
        QComboBox:focus {{
            border-color: {ArchFusionStyle.PRIMARY};
        }}
        
        QComboBox::drop-down {{
            border: none;
            width: 30px;
        }}
        
        QComboBox::down-arrow {{
            image: url(data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIiIGhlaWdodD0iOCIgdmlld0JveD0iMCAwIDEyIDgiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik0xIDFMNiA2TDExIDEiIHN0cm9rZT0iIzAwN0FGRiIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4KPC9zdmc+);
        }}
        
        QCheckBox {{
            font-size: 16px;
            color: {ArchFusionStyle.DARK};
            spacing: 10px;
        }}
        
        QCheckBox::indicator {{
            width: 20px;
            height: 20px;
            border-radius: 6px;
            border: 2px solid #E5E5EA;
            background: {ArchFusionStyle.WHITE};
        }}
        
        QCheckBox::indicator:checked {{
            background: {ArchFusionStyle.PRIMARY};
            border-color: {ArchFusionStyle.PRIMARY};
            image: url(data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIiIGhlaWdodD0iOSIgdmlld0JveD0iMCAwIDEyIDkiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik0xIDQuNUw0LjUgOEwxMSAxIiBzdHJva2U9IndoaXRlIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8L3N2Zz4=);
        }}
        
        QProgressBar {{
            background: #E5E5EA;
            border: none;
            border-radius: 8px;
            height: 16px;
            text-align: center;
        }}
        
        QProgressBar::chunk {{
            background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
                stop:0 {ArchFusionStyle.PRIMARY}, stop:1 {ArchFusionStyle.SUCCESS});
            border-radius: 8px;
        }}
        
        QTextEdit {{
            background: {ArchFusionStyle.DARK};
            color: #00FF00;
            border: none;
            border-radius: 10px;
            padding: 16px;
            font-family: 'SF Mono', 'Consolas', monospace;
            font-size: 14px;
        }}
        
        QFrame {{
            background: {ArchFusionStyle.WHITE};
            border-radius: 16px;
            border: 1px solid #E5E5EA;
        }}
        
        .card {{
            background: {ArchFusionStyle.WHITE};
            border-radius: 16px;
            border: 1px solid #E5E5EA;
            padding: 20px;
            margin: 10px;
        }}
        """

class InstallationWorker(QThread):
    """Worker thread pour l'installation"""
    
    progress_updated = pyqtSignal(int, str)
    log_updated = pyqtSignal(str)
    installation_finished = pyqtSignal(bool, str)
    
    def __init__(self, config: Dict):
        super().__init__()
        self.config = config
        self.process = None
        
    def run(self):
        """Exécute l'installation"""
        try:
            # Préparer la commande d'installation
            script_path = Path(__file__).parent / "install.sh"
            cmd = [
                "sudo", str(script_path),
                "--auto",
                "--disk", self.config["disk"],
                "--username", self.config["username"],
                "--hostname", self.config["hostname"],
                "--timezone", self.config["timezone"]
            ]
            
            if self.config.get("encrypt", False):
                cmd.append("--encrypt")
                
            if self.config.get("swap_size"):
                cmd.extend(["--swap-size", self.config["swap_size"]])
            
            # Lancer l'installation
            self.process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                universal_newlines=True,
                bufsize=1
            )
            
            # Suivre la progression
            progress = 0
            for line in iter(self.process.stdout.readline, ''):
                if line:
                    self.log_updated.emit(line.strip())
                    
                    # Analyser la progression
                    if "Partitionnement" in line:
                        progress = 10
                    elif "Formatage" in line:
                        progress = 20
                    elif "Montage" in line:
                        progress = 30
                    elif "Installation du système de base" in line:
                        progress = 50
                    elif "Configuration du système" in line:
                        progress = 70
                    elif "Installation de l'environnement de bureau" in line:
                        progress = 85
                    elif "Finalisation" in line:
                        progress = 95
                    elif "Installation terminée" in line:
                        progress = 100
                    
                    self.progress_updated.emit(progress, line.strip())
            
            # Attendre la fin du processus
            self.process.wait()
            
            if self.process.returncode == 0:
                self.installation_finished.emit(True, "Installation réussie!")
            else:
                self.installation_finished.emit(False, "Erreur lors de l'installation")
                
        except Exception as e:
            self.installation_finished.emit(False, f"Erreur: {str(e)}")
    
    def stop(self):
        """Arrête l'installation"""
        if self.process:
            self.process.terminate()

class WelcomePage(QWidget):
    """Page d'accueil"""
    
    def __init__(self):
        super().__init__()
        self.init_ui()
    
    def init_ui(self):
        layout = QVBoxLayout()
        layout.setAlignment(Qt.AlignCenter)
        layout.setSpacing(30)
        
        # Logo et titre
        title = QLabel("Bienvenue dans ArchFusion OS")
        title.setObjectName("title")
        title.setAlignment(Qt.AlignCenter)
        
        subtitle = QLabel("La distribution Linux révolutionnaire")
        subtitle.setObjectName("subtitle")
        subtitle.setAlignment(Qt.AlignCenter)
        
        # Description
        description = QLabel("""
        ArchFusion combine la puissance d'Arch Linux avec l'élégance de macOS
        et la familiarité de Windows. Cette installation vous guidera à travers
        le processus de configuration de votre nouveau système.
        
        Fonctionnalités principales:
        • Interface utilisateur moderne et intuitive
        • Environnement de bureau KDE Plasma personnalisé
        • Logiciels préinstallés et optimisés
        • Thèmes inspirés de macOS et Windows
        • Performance et stabilité d'Arch Linux
        """)
        description.setObjectName("description")
        description.setAlignment(Qt.AlignCenter)
        description.setWordWrap(True)
        description.setMaximumWidth(600)
        
        # Avertissement
        warning = QFrame()
        warning.setObjectName("card")
        warning_layout = QVBoxLayout(warning)
        
        warning_title = QLabel("⚠️ Avertissement Important")
        warning_title.setStyleSheet(f"color: {ArchFusionStyle.WARNING}; font-weight: bold; font-size: 16px;")
        
        warning_text = QLabel("""
        Cette installation effacera complètement le disque sélectionné.
        Assurez-vous d'avoir sauvegardé toutes vos données importantes
        avant de continuer.
        """)
        warning_text.setWordWrap(True)
        warning_text.setStyleSheet(f"color: {ArchFusionStyle.DANGER};")
        
        warning_layout.addWidget(warning_title)
        warning_layout.addWidget(warning_text)
        
        layout.addWidget(title)
        layout.addWidget(subtitle)
        layout.addWidget(description)
        layout.addWidget(warning)
        
        self.setLayout(layout)

class DiskSelectionPage(QWidget):
    """Page de sélection du disque"""
    
    def __init__(self):
        super().__init__()
        self.disks = []
        self.init_ui()
        self.refresh_disks()
    
    def init_ui(self):
        layout = QVBoxLayout()
        
        title = QLabel("Sélection du disque")
        title.setObjectName("title")
        
        description = QLabel("Choisissez le disque sur lequel installer ArchFusion OS")
        description.setObjectName("description")
        
        # Liste des disques
        self.disk_group = QButtonGroup()
        self.disk_layout = QVBoxLayout()
        
        # Bouton de rafraîchissement
        refresh_btn = QPushButton("🔄 Actualiser")
        refresh_btn.clicked.connect(self.refresh_disks)
        
        layout.addWidget(title)
        layout.addWidget(description)
        layout.addLayout(self.disk_layout)
        layout.addWidget(refresh_btn)
        layout.addStretch()
        
        self.setLayout(layout)
    
    def refresh_disks(self):
        """Actualise la liste des disques"""
        # Nettoyer l'ancienne liste
        for i in reversed(range(self.disk_layout.count())):
            self.disk_layout.itemAt(i).widget().setParent(None)
        
        # Obtenir la liste des disques
        try:
            result = subprocess.run(
                ["lsblk", "-d", "-o", "NAME,SIZE,MODEL", "-n"],
                capture_output=True, text=True
            )
            
            self.disks = []
            for line in result.stdout.strip().split('\n'):
                if line and not line.startswith('loop'):
                    parts = line.split()
                    if len(parts) >= 2:
                        name = parts[0]
                        size = parts[1]
                        model = ' '.join(parts[2:]) if len(parts) > 2 else "Inconnu"
                        
                        self.disks.append({
                            'name': name,
                            'size': size,
                            'model': model
                        })
            
            # Créer les boutons radio pour chaque disque
            for i, disk in enumerate(self.disks):
                disk_widget = QFrame()
                disk_widget.setObjectName("card")
                disk_layout = QHBoxLayout(disk_widget)
                
                radio = QRadioButton()
                self.disk_group.addButton(radio, i)
                
                info_layout = QVBoxLayout()
                name_label = QLabel(f"/dev/{disk['name']}")
                name_label.setStyleSheet("font-weight: bold; font-size: 16px;")
                
                details_label = QLabel(f"{disk['size']} - {disk['model']}")
                details_label.setStyleSheet("color: #666;")
                
                info_layout.addWidget(name_label)
                info_layout.addWidget(details_label)
                
                disk_layout.addWidget(radio)
                disk_layout.addLayout(info_layout)
                disk_layout.addStretch()
                
                self.disk_layout.addWidget(disk_widget)
                
        except Exception as e:
            error_label = QLabel(f"Erreur lors de la détection des disques: {str(e)}")
            error_label.setStyleSheet(f"color: {ArchFusionStyle.DANGER};")
            self.disk_layout.addWidget(error_label)
    
    def get_selected_disk(self) -> Optional[str]:
        """Retourne le disque sélectionné"""
        selected_id = self.disk_group.checkedId()
        if selected_id >= 0 and selected_id < len(self.disks):
            return self.disks[selected_id]['name']
        return None

class UserConfigPage(QWidget):
    """Page de configuration utilisateur"""
    
    def __init__(self):
        super().__init__()
        self.init_ui()
    
    def init_ui(self):
        layout = QVBoxLayout()
        
        title = QLabel("Configuration utilisateur")
        title.setObjectName("title")
        
        # Formulaire
        form_layout = QGridLayout()
        
        # Nom d'utilisateur
        form_layout.addWidget(QLabel("Nom d'utilisateur:"), 0, 0)
        self.username_edit = QLineEdit()
        self.username_edit.setPlaceholderText("Votre nom d'utilisateur")
        form_layout.addWidget(self.username_edit, 0, 1)
        
        # Nom d'hôte
        form_layout.addWidget(QLabel("Nom d'hôte:"), 1, 0)
        self.hostname_edit = QLineEdit()
        self.hostname_edit.setText("archfusion")
        self.hostname_edit.setPlaceholderText("Nom de votre ordinateur")
        form_layout.addWidget(self.hostname_edit, 1, 1)
        
        # Fuseau horaire
        form_layout.addWidget(QLabel("Fuseau horaire:"), 2, 0)
        self.timezone_combo = QComboBox()
        self.timezone_combo.addItems([
            "Europe/Paris", "Europe/London", "America/New_York",
            "America/Los_Angeles", "Asia/Tokyo", "Australia/Sydney"
        ])
        form_layout.addWidget(self.timezone_combo, 2, 1)
        
        # Langue
        form_layout.addWidget(QLabel("Langue:"), 3, 0)
        self.locale_combo = QComboBox()
        self.locale_combo.addItems([
            "fr_FR.UTF-8", "en_US.UTF-8", "de_DE.UTF-8",
            "es_ES.UTF-8", "it_IT.UTF-8", "pt_PT.UTF-8"
        ])
        form_layout.addWidget(self.locale_combo, 3, 1)
        
        # Clavier
        form_layout.addWidget(QLabel("Disposition clavier:"), 4, 0)
        self.keymap_combo = QComboBox()
        self.keymap_combo.addItems([
            "fr", "us", "de", "es", "it", "pt", "uk"
        ])
        form_layout.addWidget(self.keymap_combo, 4, 1)
        
        layout.addWidget(title)
        layout.addLayout(form_layout)
        layout.addStretch()
        
        self.setLayout(layout)
    
    def get_config(self) -> Dict:
        """Retourne la configuration utilisateur"""
        return {
            'username': self.username_edit.text(),
            'hostname': self.hostname_edit.text(),
            'timezone': self.timezone_combo.currentText(),
            'locale': self.locale_combo.currentText(),
            'keymap': self.keymap_combo.currentText()
        }

class AdvancedOptionsPage(QWidget):
    """Page des options avancées"""
    
    def __init__(self):
        super().__init__()
        self.init_ui()
    
    def init_ui(self):
        layout = QVBoxLayout()
        
        title = QLabel("Options avancées")
        title.setObjectName("title")
        
        # Chiffrement
        self.encrypt_check = QCheckBox("Activer le chiffrement du disque (LUKS)")
        self.encrypt_check.setToolTip("Chiffre le disque pour une sécurité maximale")
        
        # Swap
        swap_layout = QHBoxLayout()
        swap_layout.addWidget(QLabel("Taille du swap:"))
        self.swap_spin = QSpinBox()
        self.swap_spin.setRange(1, 32)
        self.swap_spin.setValue(4)
        self.swap_spin.setSuffix(" GB")
        swap_layout.addWidget(self.swap_spin)
        swap_layout.addStretch()
        
        # Environnement de bureau
        de_layout = QHBoxLayout()
        de_layout.addWidget(QLabel("Environnement de bureau:"))
        self.de_combo = QComboBox()
        self.de_combo.addItems(["KDE Plasma", "GNOME", "XFCE", "Minimal"])
        de_layout.addWidget(self.de_combo)
        de_layout.addStretch()
        
        # Services additionnels
        services_group = QGroupBox("Services additionnels")
        services_layout = QVBoxLayout()
        
        self.ssh_check = QCheckBox("Activer SSH")
        self.firewall_check = QCheckBox("Activer le pare-feu")
        self.firewall_check.setChecked(True)
        self.bluetooth_check = QCheckBox("Support Bluetooth")
        self.bluetooth_check.setChecked(True)
        
        services_layout.addWidget(self.ssh_check)
        services_layout.addWidget(self.firewall_check)
        services_layout.addWidget(self.bluetooth_check)
        services_group.setLayout(services_layout)
        
        layout.addWidget(title)
        layout.addWidget(self.encrypt_check)
        layout.addLayout(swap_layout)
        layout.addLayout(de_layout)
        layout.addWidget(services_group)
        layout.addStretch()
        
        self.setLayout(layout)
    
    def get_config(self) -> Dict:
        """Retourne la configuration avancée"""
        return {
            'encrypt': self.encrypt_check.isChecked(),
            'swap_size': f"{self.swap_spin.value()}G",
            'desktop_environment': self.de_combo.currentText(),
            'ssh': self.ssh_check.isChecked(),
            'firewall': self.firewall_check.isChecked(),
            'bluetooth': self.bluetooth_check.isChecked()
        }

class SummaryPage(QWidget):
    """Page de résumé"""
    
    def __init__(self):
        super().__init__()
        self.config = {}
        self.init_ui()
    
    def init_ui(self):
        layout = QVBoxLayout()
        
        title = QLabel("Résumé de l'installation")
        title.setObjectName("title")
        
        self.summary_text = QTextEdit()
        self.summary_text.setReadOnly(True)
        self.summary_text.setMaximumHeight(300)
        self.summary_text.setStyleSheet("""
            QTextEdit {
                background: white;
                color: black;
                border: 2px solid #E5E5EA;
                border-radius: 10px;
                padding: 16px;
                font-family: 'SF Pro Display', Arial, sans-serif;
                font-size: 14px;
            }
        """)
        
        layout.addWidget(title)
        layout.addWidget(self.summary_text)
        layout.addStretch()
        
        self.setLayout(layout)
    
    def update_summary(self, config: Dict):
        """Met à jour le résumé avec la configuration"""
        self.config = config
        
        summary = f"""
<h3>Configuration d'installation ArchFusion OS</h3>

<b>Disque cible:</b> /dev/{config.get('disk', 'Non sélectionné')}<br>
<b>Nom d'utilisateur:</b> {config.get('username', 'Non défini')}<br>
<b>Nom d'hôte:</b> {config.get('hostname', 'archfusion')}<br>
<b>Fuseau horaire:</b> {config.get('timezone', 'Europe/Paris')}<br>
<b>Langue:</b> {config.get('locale', 'fr_FR.UTF-8')}<br>
<b>Clavier:</b> {config.get('keymap', 'fr')}<br>

<h4>Options avancées:</h4>
<b>Chiffrement:</b> {'Activé' if config.get('encrypt', False) else 'Désactivé'}<br>
<b>Taille du swap:</b> {config.get('swap_size', '4G')}<br>
<b>Environnement de bureau:</b> {config.get('desktop_environment', 'KDE Plasma')}<br>
<b>SSH:</b> {'Activé' if config.get('ssh', False) else 'Désactivé'}<br>
<b>Pare-feu:</b> {'Activé' if config.get('firewall', True) else 'Désactivé'}<br>
<b>Bluetooth:</b> {'Activé' if config.get('bluetooth', True) else 'Désactivé'}<br>

<p style="color: red; font-weight: bold;">
⚠️ ATTENTION: Toutes les données sur /dev/{config.get('disk', 'X')} seront EFFACÉES!
</p>
        """
        
        self.summary_text.setHtml(summary)

class InstallationPage(QWidget):
    """Page d'installation"""
    
    def __init__(self):
        super().__init__()
        self.worker = None
        self.init_ui()
    
    def init_ui(self):
        layout = QVBoxLayout()
        
        title = QLabel("Installation en cours...")
        title.setObjectName("title")
        
        # Barre de progression
        self.progress_bar = QProgressBar()
        self.progress_bar.setRange(0, 100)
        self.progress_bar.setValue(0)
        
        # Label de statut
        self.status_label = QLabel("Préparation de l'installation...")
        self.status_label.setAlignment(Qt.AlignCenter)
        
        # Console de logs
        self.log_text = QTextEdit()
        self.log_text.setReadOnly(True)
        self.log_text.setMaximumHeight(300)
        
        layout.addWidget(title)
        layout.addWidget(self.progress_bar)
        layout.addWidget(self.status_label)
        layout.addWidget(self.log_text)
        
        self.setLayout(layout)
    
    def start_installation(self, config: Dict):
        """Démarre l'installation"""
        self.worker = InstallationWorker(config)
        self.worker.progress_updated.connect(self.update_progress)
        self.worker.log_updated.connect(self.add_log)
        self.worker.installation_finished.connect(self.installation_finished)
        self.worker.start()
    
    def update_progress(self, value: int, status: str):
        """Met à jour la progression"""
        self.progress_bar.setValue(value)
        self.status_label.setText(status)
    
    def add_log(self, message: str):
        """Ajoute un message au log"""
        self.log_text.append(message)
        # Auto-scroll vers le bas
        scrollbar = self.log_text.verticalScrollBar()
        scrollbar.setValue(scrollbar.maximum())
    
    def installation_finished(self, success: bool, message: str):
        """Installation terminée"""
        if success:
            self.status_label.setText("✅ Installation terminée avec succès!")
            self.progress_bar.setValue(100)
        else:
            self.status_label.setText(f"❌ Erreur: {message}")

class ArchFusionInstaller(QMainWindow):
    """Interface principale de l'installateur ArchFusion"""
    
    def __init__(self):
        super().__init__()
        self.config = {}
        self.init_ui()
        self.setStyleSheet(ArchFusionStyle.get_main_style())
    
    def init_ui(self):
        self.setWindowTitle("ArchFusion OS - Installateur")
        self.setMinimumSize(800, 600)
        self.resize(1000, 700)
        
        # Widget central
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        # Layout principal
        main_layout = QVBoxLayout(central_widget)
        
        # Header
        header = self.create_header()
        main_layout.addWidget(header)
        
        # Pages
        self.stacked_widget = QStackedWidget()
        
        # Créer les pages
        self.welcome_page = WelcomePage()
        self.disk_page = DiskSelectionPage()
        self.user_page = UserConfigPage()
        self.advanced_page = AdvancedOptionsPage()
        self.summary_page = SummaryPage()
        self.install_page = InstallationPage()
        
        # Ajouter les pages
        self.stacked_widget.addWidget(self.welcome_page)
        self.stacked_widget.addWidget(self.disk_page)
        self.stacked_widget.addWidget(self.user_page)
        self.stacked_widget.addWidget(self.advanced_page)
        self.stacked_widget.addWidget(self.summary_page)
        self.stacked_widget.addWidget(self.install_page)
        
        main_layout.addWidget(self.stacked_widget)
        
        # Footer avec boutons de navigation
        footer = self.create_footer()
        main_layout.addWidget(footer)
        
        # Page courante
        self.current_page = 0
        self.update_navigation()
    
    def create_header(self) -> QWidget:
        """Crée l'en-tête"""
        header = QFrame()
        header.setObjectName("card")
        header.setFixedHeight(80)
        
        layout = QHBoxLayout(header)
        
        # Logo et titre
        title = QLabel("ArchFusion OS Installer")
        title.setStyleSheet("font-size: 24px; font-weight: bold; color: #007AFF;")
        
        # Indicateur de progression
        self.page_indicator = QLabel("Étape 1 sur 6")
        self.page_indicator.setStyleSheet("color: #666; font-size: 14px;")
        
        layout.addWidget(title)
        layout.addStretch()
        layout.addWidget(self.page_indicator)
        
        return header
    
    def create_footer(self) -> QWidget:
        """Crée le pied de page avec les boutons"""
        footer = QFrame()
        footer.setFixedHeight(80)
        
        layout = QHBoxLayout(footer)
        
        # Boutons
        self.prev_btn = QPushButton("← Précédent")
        self.next_btn = QPushButton("Suivant →")
        self.install_btn = QPushButton("🚀 Installer")
        
        self.prev_btn.clicked.connect(self.previous_page)
        self.next_btn.clicked.connect(self.next_page)
        self.install_btn.clicked.connect(self.start_installation)
        
        # Style des boutons
        self.install_btn.setObjectName("success-button")
        self.install_btn.hide()
        
        layout.addStretch()
        layout.addWidget(self.prev_btn)
        layout.addWidget(self.next_btn)
        layout.addWidget(self.install_btn)
        
        return footer
    
    def update_navigation(self):
        """Met à jour les boutons de navigation"""
        total_pages = self.stacked_widget.count() - 1  # -1 car la page d'installation n'est pas dans la navigation normale
        
        # Mettre à jour l'indicateur
        self.page_indicator.setText(f"Étape {self.current_page + 1} sur {total_pages}")
        
        # Bouton précédent
        self.prev_btn.setEnabled(self.current_page > 0)
        
        # Bouton suivant / installer
        if self.current_page == total_pages - 1:  # Page de résumé
            self.next_btn.hide()
            self.install_btn.show()
        else:
            self.next_btn.show()
            self.install_btn.hide()
            
        # Validation de la page courante
        self.next_btn.setEnabled(self.validate_current_page())
    
    def validate_current_page(self) -> bool:
        """Valide la page courante"""
        if self.current_page == 1:  # Page de sélection du disque
            return self.disk_page.get_selected_disk() is not None
        elif self.current_page == 2:  # Page utilisateur
            config = self.user_page.get_config()
            return bool(config['username'].strip())
        return True
    
    def previous_page(self):
        """Page précédente"""
        if self.current_page > 0:
            self.current_page -= 1
            self.stacked_widget.setCurrentIndex(self.current_page)
            self.update_navigation()
    
    def next_page(self):
        """Page suivante"""
        if not self.validate_current_page():
            return
        
        # Sauvegarder la configuration de la page courante
        if self.current_page == 1:  # Disque
            self.config['disk'] = self.disk_page.get_selected_disk()
        elif self.current_page == 2:  # Utilisateur
            self.config.update(self.user_page.get_config())
        elif self.current_page == 3:  # Options avancées
            self.config.update(self.advanced_page.get_config())
        
        # Aller à la page suivante
        if self.current_page < self.stacked_widget.count() - 2:  # -2 car on exclut la page d'installation
            self.current_page += 1
            self.stacked_widget.setCurrentIndex(self.current_page)
            
            # Mettre à jour la page de résumé si on y arrive
            if self.current_page == 4:  # Page de résumé
                self.summary_page.update_summary(self.config)
            
            self.update_navigation()
    
    def start_installation(self):
        """Démarre l'installation"""
        # Vérifier que tous les champs requis sont remplis
        if not self.config.get('disk') or not self.config.get('username'):
            QMessageBox.warning(self, "Configuration incomplète", 
                              "Veuillez compléter tous les champs requis.")
            return
        
        # Confirmation finale
        reply = QMessageBox.question(
            self, "Confirmation d'installation",
            f"Êtes-vous sûr de vouloir installer ArchFusion OS sur /dev/{self.config['disk']}?\n\n"
            "⚠️ TOUTES LES DONNÉES SERONT EFFACÉES!",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No
        )
        
        if reply == QMessageBox.Yes:
            # Aller à la page d'installation
            self.stacked_widget.setCurrentIndex(5)  # Page d'installation
            self.page_indicator.setText("Installation en cours...")
            
            # Cacher les boutons de navigation
            self.prev_btn.hide()
            self.next_btn.hide()
            self.install_btn.hide()
            
            # Démarrer l'installation
            self.install_page.start_installation(self.config)

def main():
    """Fonction principale"""
    app = QApplication(sys.argv)
    
    # Configuration de l'application
    app.setApplicationName("ArchFusion OS Installer")
    app.setApplicationVersion("1.0.0")
    app.setOrganizationName("ArchFusion")
    app.setOrganizationDomain("archfusion.org")
    
    # Vérifier les privilèges root
    if os.geteuid() != 0:
        QMessageBox.critical(None, "Privilèges insuffisants",
                           "L'installateur doit être exécuté en tant que root.\n"
                           "Utilisez: sudo python3 gui-installer.py")
        sys.exit(1)
    
    # Créer et afficher la fenêtre principale
    installer = ArchFusionInstaller()
    installer.show()
    
    # Centrer la fenêtre
    screen = app.primaryScreen().geometry()
    size = installer.geometry()
    installer.move(
        (screen.width() - size.width()) // 2,
        (screen.height() - size.height()) // 2
    )
    
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()