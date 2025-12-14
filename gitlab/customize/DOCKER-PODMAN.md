# Docker vs Podman - Explication Système

## 🔍 Découverte Importante

Sur ce système, **`docker` n'existe pas vraiment** - c'est un **wrapper vers `podman`** !

### Vérification

```bash
$ which docker
/usr/bin/docker

$ file /usr/bin/docker
/usr/bin/docker: a /usr/bin/sh script, ASCII text executable

$ cat /usr/bin/docker
#!/usr/bin/sh
exec /usr/bin/podman "$@"
```

**Conséquence** : Tous les appels `docker` sont **redirigés vers `podman user`**

## 🏗️ Architecture Podman

Podman a **2 modes d'exécution** :

### 1. Mode USER (Rootless)
- Commande : `podman` ou `docker`
- Utilisateur : `dpjb`
- Socket : `$XDG_RUNTIME_DIR/podman/podman.sock`
- Visible dans Cockpit : **User containers**
- Utilisé par : `docker compose`, GitLab CI/CD

### 2. Mode SYSTEM (Root)
- Commande : `sudo podman`
- Utilisateur : `root`
- Socket : `/run/podman/podman.sock`
- Visible dans Cockpit : **System containers**
- Utilisé par : Cockpit (interface web)

## 🔄 Équivalences

| Commande | Mode | Description |
|----------|------|-------------|
| `docker ps -a` | USER | = `podman ps -a` |
| `docker compose up` | USER | Crée conteneurs USER |
| `podman ps -a` | USER | Liste conteneurs user |
| `sudo podman ps -a` | SYSTEM | Liste conteneurs root |

## ❌ Pourquoi On Voyait 2 Instances ?

Dans **Cockpit**, on voit :
- **User containers** : Créés par `docker compose` (via podman user)
- **System containers** : Créés par Cockpit ou `sudo podman`

### Problème Précédent

On appelait **en double** :
```yaml
- docker rm -f ${CONTAINER_NAME}      # = podman user
- podman rm -f ${CONTAINER_NAME}      # = podman user (DOUBLON!)
- sudo podman rm -f ${CONTAINER_NAME} # = podman system
```

## ✅ Solution Actuelle

Cleanup simplifié - **4 niveaux** au lieu de 6 :

```yaml
1. podman stop + rm (USER - par nom)
2. podman ps -a + filtre (USER - par ID pour fantômes)
3. sudo podman stop + rm (SYSTEM - par nom)
4. sudo podman ps -a + filtre (SYSTEM - par ID pour fantômes)
```

## 🎯 Recommandation

### Pour Ce Projet (cpascher)

✅ **Utiliser `docker compose`** : Simple, standard, fonctionne via podman user

### Pour Cockpit

⚠️ **Ne PAS créer manuellement** de conteneurs via Cockpit pour CI/CD
- Cockpit crée en mode SYSTEM (root)
- GitLab CI/CD tourne en mode USER
- Conflit de noms garanti !

## 📊 Vérification Rapide

```bash
# Voir les conteneurs USER
podman ps -a

# Voir les conteneurs SYSTEM
sudo podman ps -a

# Tester si un conteneur est USER ou SYSTEM
podman inspect cpascher-prod  # Succès = USER
sudo podman inspect cpascher-prod  # Succès = SYSTEM
```

## 🚀 Dans GitLab CI/CD

Le pipeline utilise maintenant :
- `docker compose` pour build/up/down (→ podman USER)
- Template `.cleanup_template` intelligent (USER + SYSTEM)
- Pas de doublons

## 📝 Notes

- Le fichier `/etc/containers/nodocker` supprime le message d'avertissement
- `docker-compose` (ancien) vs `docker compose` (plugin moderne - utilisé ici)
- Podman émule Docker CLI via `/usr/libexec/docker/cli-plugins/docker-compose`
