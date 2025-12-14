# Alternative SANS Sudo

Si vous voulez **éviter les problèmes de permissions sudo**, voici une alternative.

## 🎯 Stratégie : Tout en Mode USER

### Principe

Ne **jamais utiliser** Cockpit pour créer des conteneurs CI/CD.
Utiliser **uniquement** `docker compose` (podman user).

### Avantages

✅ Pas besoin de permissions sudo  
✅ Pas de conflits user/system  
✅ Plus simple à débugger  
✅ Conforme aux bonnes pratiques rootless  

### Changements Nécessaires

#### 1. Retirer `sudo podman` du Template

**Fichier** : `gitlab/templates/deploy.yml`

```yaml
.cleanup_template:
  script:
    - echo "=== Nettoyage du conteneur existant (USER uniquement) ==="
    - podman stop ${CONTAINER_NAME} 2>/dev/null || true
    - podman rm ${CONTAINER_NAME} 2>/dev/null || true
    - echo "→ Nettoyage conteneurs fantômes..."
    - for id in $(podman ps -a --filter "name=${CONTAINER_NAME}" -q 2>/dev/null); do 
        podman stop $id 2>/dev/null || true; 
        podman rm $id 2>/dev/null || true; 
      done
    - sleep 2
    - echo "✅ Nettoyage terminé"
```

**Suppression** : Tout ce qui contient `sudo podman`

#### 2. Changer le Déploiement Production

**Option A : Déployer dans le home**

```yaml
deploy:production:
  script:
    - echo "🚀 Déploiement en production..."
    - docker compose --profile prod restart
    - echo "=== Copie des fichiers ==="
    - mkdir -p ~/www/${PROJECT_NAME}
    - docker cp ${CONTAINER_NAME_PROD}:/Sites/${PROJECT_NAME}/. ~/www/${PROJECT_NAME}/
    - echo "✅ Déployé dans ~/www/${PROJECT_NAME}"
  environment:
    name: production
    url: http://localhost:${PROD_PORT}
```

**Option B : Utiliser un volume monté**

Modifier `compose.yaml` :

```yaml
services:
  cpascher-prod:
    profiles: ["prod"]
    volumes:
      - /var/www/html/cpascher:/Sites/cpascher:rw
```

Puis donner les droits :

```bash
sudo chown -R dpjb:dpjb /var/www/html/cpascher
sudo chmod -R 755 /var/www/html/cpascher
```

Le CI/CD n'a plus besoin de copier, c'est automatique !

#### 3. Configuration Cockpit

**Important** : Dans Cockpit, **ne jamais créer manuellement** de conteneurs pour le projet.

Si vous voulez monitorer :
- Allez dans **User containers** (pas System)
- Les conteneurs créés par `docker compose` y apparaissent

## 📊 Comparaison

| Aspect | Avec Sudo | Sans Sudo (Alternative) |
|--------|-----------|------------------------|
| **Sécurité** | ⚠️ Nécessite sudoers | ✅ Rootless complet |
| **Complexité** | ⚠️ Config sudo nécessaire | ✅ Simple |
| **Maintenance** | ⚠️ Permissions à gérer | ✅ Aucune config |
| **Déploiement /var/www/html** | ✅ Direct | ⚠️ Indirect (volume ou ~/www) |
| **Cockpit** | ⚠️ Conflits possibles | ✅ Pas de conflit |

## ✅ Recommandation

### Développement / Staging
→ **Alternative SANS sudo** (plus simple)

### Production
→ **Avec sudo** si besoin de `/var/www/html`  
→ **Volume monté** si possible (meilleure option)

## 🔧 Migration Vers l'Alternative

### Étape 1 : Nettoyer les Conteneurs System

```bash
sudo podman ps -a
sudo podman stop $(sudo podman ps -aq)
sudo podman rm $(sudo podman ps -aq)
```

### Étape 2 : Modifier les Templates

Éditer `gitlab/templates/deploy.yml` et retirer toutes les lignes `sudo`.

### Étape 3 : Tester

```bash
docker compose --profile prod up -d
# Doit créer en mode USER
podman ps -a  # Doit afficher le conteneur
sudo podman ps -a  # Ne doit RIEN afficher
```

### Étape 4 : Configurer le Volume (optionnel)

Si vous voulez déployer dans `/var/www/html` :

```bash
sudo mkdir -p /var/www/html/cpascher
sudo chown dpjb:dpjb /var/www/html/cpascher
```

Ajouter au `compose.yaml` :

```yaml
volumes:
  - /var/www/html/cpascher:/Sites/cpascher:rw
```

## 🎯 Conclusion

**Si possible** : Utilisez l'alternative SANS sudo.  
**Si nécessaire** : Installez les permissions sudo avec le script fourni.

Le choix dépend de vos contraintes de déploiement.
