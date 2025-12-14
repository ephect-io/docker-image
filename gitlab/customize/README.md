# GitLab CI/CD - Documentation

Ce répertoire contient toute la configuration CI/CD du projet.

## 📁 Structure

```
gitlab/
├── .gitlab-ci.yml           # Configuration principale
├── README.md                # Documentation
├── ORGANIZATION.md          # Guide d'organisation
├── templates/               # Templates réutilisables
│   ├── build.yml           # Template de build
│   └── deploy.yml          # Template de déploiement
└── scripts/                 # Scripts CI/CD
    ├── cleanup.sh          # Nettoyage multi-niveau des conteneurs
    └── deploy.sh           # Script de déploiement avec workaround Podman
```

## 🚀 Réutilisation pour un Nouveau Projet

### 1. Copier le Répertoire

```bash
cp -r gitlab/ /chemin/vers/nouveau-projet/
cd /chemin/vers/nouveau-projet/gitlab
```

### 2. Modifier les Variables

Éditer `gitlab/.gitlab-ci.yml` et changer uniquement ces lignes :

```yaml
variables:
  PROJECT_NAME: "mon-nouveau-projet"    # ← Nom de votre projet
  REGISTRY_URL: "localhost:5100"        # ← Votre registry
  DEV_PORT: "8888"                      # ← Port dev
  PROD_PORT: "8888"                     # ← Port prod
```

**C'est tout !** Les autres variables sont dérivées automatiquement :
- `CONTAINER_NAME_PROD` → `${PROJECT_NAME}-prod`
- `CONTAINER_NAME_DEV` → `${PROJECT_NAME}-dev`
- `IMAGE_NAME` → `${PROJECT_NAME}`

### 3. Configurer GitLab

**Option A** : Settings > CI/CD > CI/CD configuration file = `gitlab/.gitlab-ci.yml`

**Option B** : Créer `.gitlab-ci.yml` à la racine :
```yaml
include:
  - local: 'gitlab/.gitlab-ci.yml'
```

## 🔧 Prérequis

- Fichier `compose.yaml` avec profils `dev` et `prod`
- Registry Docker accessible
- GitLab Runner avec tags `shell` et `local`

## 📚 Documentation Complète

Voir `ORGANIZATION.md` pour plus de détails sur l'organisation et la migration.
- Conteneurs : `mon-app-dev` et `mon-app-prod`
- Images : `mon-app:dev` et `mon-app:prod`
- Registry : `registry.example.com/mon-app:dev` et `registry.example.com/mon-app:prod`
- Déploiement : `/var/www/html/mon-app`
