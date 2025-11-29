#!/bin/bash

# Script pour mettre à jour la description Docker Hub avec le contenu du README.md
# Usage: ./update-dockerhub-description.sh <namespace/repository> <package>
# Exemple: ./update-dockerhub-description.sh ephectio/dev-php apache

REPO=${1}
PACKAGE=${2:-apache}
README_FILE="./php/${PACKAGE}/README.md"
DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME:-}
DOCKERHUB_PASSWORD=${DOCKERHUB_PASSWORD:-}

# Essayer de récupérer les credentials depuis docker config si non fournis
if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_PASSWORD" ]; then
    if command -v jq &> /dev/null && [ -f ~/.docker/config.json ]; then
        echo "🔍 Tentative de récupération des credentials depuis docker config..."
        
        # Vérifier si un credential helper est utilisé
        CREDS_STORE=$(cat ~/.docker/config.json | jq -r '.credsStore // empty')
        
        if [ -n "$CREDS_STORE" ]; then
            echo "ℹ️  Credential helper détecté: $CREDS_STORE"
            # Essayer d'utiliser docker-credential-helper
            if command -v docker-credential-$CREDS_STORE &> /dev/null; then
                CREDS=$(echo "https://index.docker.io/v1/" | docker-credential-$CREDS_STORE get 2>/dev/null)
                if [ $? -eq 0 ] && [ -n "$CREDS" ]; then
                    DOCKERHUB_USERNAME=$(echo "$CREDS" | jq -r '.Username // empty')
                    DOCKERHUB_PASSWORD=$(echo "$CREDS" | jq -r '.Secret // empty')
                    if [ -n "$DOCKERHUB_USERNAME" ] && [ -n "$DOCKERHUB_PASSWORD" ]; then
                        echo "✅ Credentials récupérés depuis le credential helper"
                    fi
                fi
            fi
        else
            # Essayer le format classique avec auth en base64
            AUTH=$(cat ~/.docker/config.json | jq -r '.auths["https://index.docker.io/v1/"].auth // empty')
            if [ -n "$AUTH" ]; then
                DOCKERHUB_USERNAME=$(echo "$AUTH" | base64 -d | cut -d':' -f1)
                DOCKERHUB_PASSWORD=$(echo "$AUTH" | base64 -d | cut -d':' -f2)
                echo "✅ Credentials récupérés depuis docker config"
            fi
        fi
    fi
fi

if [ -z "$REPO" ]; then
    echo "❌ Erreur: Vous devez spécifier le repository (namespace/repo)"
    echo "Usage: $0 <namespace/repository> [package]"
    exit 1
fi

if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_PASSWORD" ]; then
    echo "❌ Erreur: Impossible de récupérer les credentials automatiquement"
    echo ""
    echo "Veuillez définir les variables d'environnement:"
    echo "  export DOCKERHUB_USERNAME=your-username"
    echo "  export DOCKERHUB_PASSWORD=your-password-or-token"
    echo ""
    echo "Note: Utilisez un Personal Access Token depuis https://hub.docker.com/settings/security"
    exit 1
fi

if [ ! -f "$README_FILE" ]; then
    echo "❌ Erreur: Le fichier README.md n'existe pas: $README_FILE"
    exit 1
fi

echo "==========================================="
echo "Mise à jour de la description Docker Hub"
echo "Repository: $REPO"
echo "README: $README_FILE"
echo "==========================================="

# Lire le contenu du README
README_CONTENT=$(cat "$README_FILE")

# S'authentifier sur Docker Hub
echo "🔐 Authentification sur Docker Hub..."
TOKEN=$(curl -s -H "Content-Type: application/json" \
    -X POST \
    -d "{\"username\": \"$DOCKERHUB_USERNAME\", \"password\": \"$DOCKERHUB_PASSWORD\"}" \
    https://hub.docker.com/v2/users/login/ | jq -r .token)

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    echo "❌ Erreur d'authentification"
    exit 1
fi

echo "✅ Authentification réussie"

# Mettre à jour la description
echo "📝 Mise à jour de la description..."

# Échapper le JSON
README_JSON=$(jq -Rs . <<< "$README_CONTENT")

RESPONSE=$(curl -s -X PATCH \
    -H "Authorization: JWT $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"full_description\": $README_JSON}" \
    "https://hub.docker.com/v2/repositories/$REPO/")

if echo "$RESPONSE" | jq -e '.full_description' > /dev/null 2>&1; then
    echo "✅ Description mise à jour avec succès!"
else
    echo "❌ Erreur lors de la mise à jour:"
    echo "$RESPONSE" | jq .
    exit 1
fi

echo "==========================================="
echo "✅ Processus terminé"
echo "==========================================="
