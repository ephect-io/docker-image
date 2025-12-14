# Permissions Sudo - GitLab Runner

## 🚨 Problème

Le GitLab Runner a besoin de permissions `sudo` pour :
1. **Nettoyage des conteneurs Podman System** (créés par Cockpit)
2. **Déploiement en production** vers `/var/www/html`

## 🔍 Diagnostic

### Utilisateur du Runner

```bash
$ ps aux | grep gitlab-runner
root 29219 ... /usr/bin/gitlab-runner ... --user gitlab-runner
```

Le runner tourne avec l'utilisateur **`gitlab-runner`** (uid=383)

### Permissions Actuelles

```bash
$ sudo -l -U gitlab-runner
gitlab-runner peut utiliser les commandes suivantes sur OhMyFX :
    (ALL) NOPASSWD: /usr/bin/mkdir
    (ALL) NOPASSWD: /usr/bin/chown
    (ALL) NOPASSWD: /usr/bin/chmod
```

### Permissions Manquantes ❌

Le CI/CD utilise dans les templates :
- ❌ `sudo podman stop/rm` (cleanup conteneurs system)
- ❌ `sudo rm -rf /var/www/html/*` (deploy production)
- ❌ `sudo mv ~/tmp/* /var/www/html/*` (deploy production)

## ✅ Solution

### Installation Automatique

```bash
cd /home/dpjb/Sites/Ephect/SDK/php/cpascher
sudo gitlab/scripts/install-sudo-permissions.sh
```

Le script :
1. Vérifie la syntaxe avec `visudo -c`
2. Sauvegarde l'ancien fichier
3. Installe `/etc/sudoers.d/gitlab-runner`
4. Affiche les nouvelles permissions

### Installation Manuelle

Si vous préférez installer manuellement :

```bash
sudo visudo -f /etc/sudoers.d/gitlab-runner
```

Ajouter ces lignes :

```sudoers
# GitLab Runner - Permissions CI/CD

# Permissions de base
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/mkdir
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/chown
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/chmod

# Permissions pour conteneurs Podman
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/podman

# Permissions pour déploiement
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/rm
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/mv
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/cp
```

### Vérification

```bash
sudo -l -U gitlab-runner
```

Doit afficher toutes les permissions ci-dessus.

## 🔒 Sécurité

### Option Plus Restrictive

Si vous voulez limiter les permissions, éditez `/etc/sudoers.d/gitlab-runner` :

```sudoers
# Podman - uniquement les commandes nécessaires
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/podman stop *
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/podman rm *
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/podman ps *

# Déploiement - uniquement /var/www/html
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/rm -rf /var/www/html/*
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/mv /home/dpjb/tmp/* /var/www/html/*
gitlab-runner ALL=(ALL) NOPASSWD: /usr/bin/mkdir -p /var/www/html/*
```

### Risques

Les permissions larges (`/usr/bin/podman` sans restriction) permettent à `gitlab-runner` d'exécuter **n'importe quelle commande podman**.

**Recommandation** : 
- Utilisez l'option restrictive en production
- Utilisez l'option large en développement (plus simple)

## 🧪 Test

Après installation, testez depuis le runner :

```bash
# En tant que gitlab-runner
sudo -u gitlab-runner sudo podman ps -a
sudo -u gitlab-runner sudo rm -rf /tmp/test
sudo -u gitlab-runner sudo mv /tmp/a /tmp/b
```

Aucune demande de mot de passe ne doit apparaître.

## 📊 Impact sur le CI/CD

### Avant Installation

```
$ sudo podman stop cpascher-prod
sudo: a password is required
ERROR: Job failed
```

### Après Installation

```
$ sudo podman stop cpascher-prod
cpascher-prod
✅ Success
```

## 🔄 Rollback

Pour revenir en arrière :

```bash
# Restaurer l'ancien fichier
sudo cp /etc/sudoers.d/gitlab-runner.backup.* /etc/sudoers.d/gitlab-runner

# OU supprimer complètement
sudo rm /etc/sudoers.d/gitlab-runner
```

## 📝 Fichiers

- **Script** : `gitlab/scripts/install-sudo-permissions.sh`
- **Template** : `gitlab/sudoers-gitlab-runner`
- **Cible** : `/etc/sudoers.d/gitlab-runner`

## ⚠️ Note Importante

Ces permissions sont **nécessaires uniquement si** :
1. Vous utilisez Cockpit (qui crée des conteneurs system)
2. Vous déployez vers `/var/www/html` (nécessite root)

Si vous n'utilisez **que Podman user** (pas Cockpit), vous pouvez retirer les lignes `sudo podman` du template.
