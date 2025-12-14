# GitLab CI/CD - Index

## 📚 Documentation

| Fichier | Description |
|---------|-------------|
| **README.md** | Guide rapide de réutilisation (COMMENCER ICI) |
| **ORGANIZATION.md** | Guide complet d'organisation et migration |
| **DOCKER-PODMAN.md** | Explication Docker vs Podman (IMPORTANT) |
| **SUDO-PERMISSIONS.md** | Configuration permissions sudo pour GitLab Runner |
| **ALTERNATIVE-NO-SUDO.md** | Alternative sans sudo (rootless complet) |
| **INDEX.md** | Ce fichier - Table des matières |

## 🔧 Configuration

| Fichier | Description |
|---------|-------------|
| **.gitlab-ci.yml** | Configuration CI/CD principale |

## 📦 Templates

| Fichier | Description |
|---------|-------------|
| **templates/build.yml** | Template de build réutilisable |
| **templates/deploy.yml** | Template de déploiement réutilisable |

## 🚀 Scripts

| Fichier | Description |
|---------|-------------|
| **scripts/cleanup.sh** | Nettoyage multi-niveau des conteneurs (Docker/Podman/Cockpit) |
| **scripts/deploy.sh** | Déploiement avec workaround pour Podman |

## 🎯 Quickstart

### Pour ce projet
```bash
# Le CI/CD est déjà configuré
git push
```

### Pour un nouveau projet
```bash
# 1. Copier le répertoire
cp -r gitlab/ /chemin/vers/nouveau-projet/

# 2. Modifier PROJECT_NAME dans gitlab/.gitlab-ci.yml
nano gitlab/.gitlab-ci.yml  # Changer PROJECT_NAME="votre-projet"

# 3. Configurer GitLab
# Settings > CI/CD > CI/CD configuration file = gitlab/.gitlab-ci.yml
```

## 📖 Plus d'infos

- **Variables** : Voir README.md section "Réutilisation"
- **Organisation** : Voir ORGANIZATION.md
- **Scripts** : Commentés dans chaque fichier .sh
- **Templates** : Commentés dans chaque fichier .yml
