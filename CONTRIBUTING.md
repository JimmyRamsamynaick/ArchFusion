# 🤝 Guide de Contribution - ArchFusion OS

Merci de votre intérêt pour contribuer à ArchFusion OS ! Ce guide vous aidera à participer efficacement au projet.

## 📋 Table des Matières

- [Code de Conduite](#code-de-conduite)
- [Comment Contribuer](#comment-contribuer)
- [Types de Contributions](#types-de-contributions)
- [Processus de Développement](#processus-de-développement)
- [Standards de Code](#standards-de-code)
- [Tests](#tests)
- [Documentation](#documentation)

## 🤝 Code de Conduite

En participant à ce projet, vous acceptez de respecter notre [Code de Conduite](CODE_OF_CONDUCT.md). Nous nous engageons à maintenir un environnement accueillant et inclusif pour tous.

## 🚀 Comment Contribuer

### 1. Fork et Clone
```bash
# Fork le projet sur GitHub
# Puis clonez votre fork
git clone https://github.com/VOTRE-USERNAME/ArchFusion.git
cd ArchFusion
```

### 2. Créer une Branche
```bash
# Créez une branche pour votre fonctionnalité
git checkout -b feature/ma-nouvelle-fonctionnalite
```

### 3. Développer
- Implémentez vos changements
- Suivez les [standards de code](#standards-de-code)
- Ajoutez des tests si nécessaire
- Mettez à jour la documentation

### 4. Tester
```bash
# Lancez les tests
./scripts/test.sh

# Testez sur une VM si possible
./scripts/test-vm.sh
```

### 5. Commit et Push
```bash
# Commitez avec un message descriptif
git commit -m "feat: ajouter support pour nouveau hardware"
git push origin feature/ma-nouvelle-fonctionnalite
```

### 6. Pull Request
- Ouvrez une Pull Request sur GitHub
- Décrivez clairement vos changements
- Liez les issues concernées
- Attendez la review

## 🎯 Types de Contributions

### 🐛 Corrections de Bugs
- Recherchez d'abord dans les [issues existantes](https://github.com/JimmyRamsamynaick/ArchFusion/issues)
- Créez une issue si le bug n'existe pas
- Référencez l'issue dans votre PR

### ✨ Nouvelles Fonctionnalités
- Discutez d'abord dans les [Discussions](https://github.com/JimmyRamsamynaick/ArchFusion/discussions)
- Créez une issue détaillée
- Implémentez avec tests et documentation

### 📚 Documentation
- Améliorez la clarté
- Ajoutez des exemples
- Corrigez les erreurs
- Traduisez en d'autres langues

### 🎨 Design et UX
- Proposez des améliorations d'interface
- Créez des mockups
- Testez l'ergonomie

## 🔄 Processus de Développement

### Workflow Git
Nous utilisons [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/) :

- `main` : Version stable de production
- `develop` : Branche de développement
- `feature/*` : Nouvelles fonctionnalités
- `hotfix/*` : Corrections urgentes
- `release/*` : Préparation des releases

### Convention de Commit
Nous suivons [Conventional Commits](https://www.conventionalcommits.org/) :

```
type(scope): description

[body optionnel]

[footer optionnel]
```

**Types** :
- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `docs` : Documentation
- `style` : Formatage, style
- `refactor` : Refactoring
- `test` : Tests
- `chore` : Maintenance

**Exemples** :
```
feat(kde): ajouter thème sombre personnalisé
fix(install): corriger erreur de partition UEFI
docs(readme): mettre à jour guide d'installation
```

## 📏 Standards de Code

### Shell Scripts
```bash
#!/bin/bash
# Utilisez bash strict mode
set -euo pipefail

# Fonctions en snake_case
function install_packages() {
    local packages=("$@")
    # ...
}

# Variables en UPPER_CASE pour les constantes
readonly ARCH_FUSION_VERSION="1.0.0"
```

### Python
```python
# Suivez PEP 8
# Utilisez type hints
def configure_system(config_path: str) -> bool:
    """Configure le système avec le fichier donné."""
    pass
```

### Configuration Files
- Utilisez YAML pour les configs complexes
- JSON pour les données structurées
- INI pour les configs simples

## 🧪 Tests

### Tests Unitaires
```bash
# Lancez tous les tests
./scripts/test.sh

# Tests spécifiques
./scripts/test.sh --module=installer
```

### Tests d'Intégration
```bash
# Test sur VM
./scripts/test-vm.sh

# Test ISO
./scripts/test-iso.sh
```

### Tests Manuels
- Testez sur différents hardware
- Vérifiez l'expérience utilisateur
- Documentez les résultats

## 📖 Documentation

### Structure
```
docs/
├── installation.md      # Guide d'installation
├── customization.md     # Personnalisation
├── development.md       # Guide développeur
├── api/                # Documentation API
└── translations/       # Traductions
```

### Style
- Utilisez Markdown
- Ajoutez des captures d'écran
- Incluez des exemples de code
- Maintenez à jour

## 🏷️ Labels et Issues

### Labels Principaux
- `bug` : Problème à corriger
- `enhancement` : Amélioration
- `documentation` : Documentation
- `good first issue` : Bon pour débuter
- `help wanted` : Aide recherchée
- `priority-high` : Priorité élevée

### Templates d'Issues
Utilisez les templates fournis :
- Bug Report
- Feature Request
- Documentation Improvement

## 🎉 Reconnaissance

### Hall of Fame
Les contributeurs sont listés dans :
- [CONTRIBUTORS.md](CONTRIBUTORS.md)
- Section remerciements du README
- Release notes

### Récompenses
- Badge "Contributor" sur le profil
- Mention dans les annonces
- Accès early aux nouvelles versions

## 📞 Besoin d'Aide ?

### Canaux de Communication
- **GitHub Issues** : Bugs et fonctionnalités
- **GitHub Discussions** : Questions générales
- **Discord** : Chat en temps réel
- **Email** : jimmyramsamynaick@gmail.com

### Mentorship
Nouveau contributeur ? Nous offrons :
- Mentorat pour les débutants
- Pair programming sessions
- Code reviews détaillées

## 📋 Checklist PR

Avant de soumettre votre PR, vérifiez :

- [ ] Code testé localement
- [ ] Tests passent
- [ ] Documentation mise à jour
- [ ] Commit messages suivent la convention
- [ ] Pas de conflits avec main
- [ ] Description PR complète
- [ ] Issues liées référencées

## 🙏 Merci !

Chaque contribution, petite ou grande, fait la différence. Merci de faire d'ArchFusion OS un projet meilleur !

---

**Questions ?** N'hésitez pas à ouvrir une [Discussion](https://github.com/JimmyRamsamynaick/ArchFusion/discussions) ou nous contacter directement.