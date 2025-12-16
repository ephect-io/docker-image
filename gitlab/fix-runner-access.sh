#!/bin/bash

# Script pour configurer l'accès Git du runner
# Résout l'erreur 403 lors du clone du repository

set -e

echo "🔧 Configuration de l'accès Git pour GitLab Runner..."

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier si on est root
if [ "$EUID" -ne 0 ]; then
    print_error "Ce script doit être exécuté en tant que root (sudo)"
    exit 1
fi

CONFIG_FILE="/etc/gitlab-runner/config.toml"

if [ ! -f "$CONFIG_FILE" ]; then
    print_error "Fichier de configuration non trouvé: $CONFIG_FILE"
    exit 1
fi

print_info "Sauvegarde de la configuration actuelle..."
cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"

echo ""
echo "════════════════════════════════════════════════════════"
echo "  Configuration de l'accès Git"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Choisissez la méthode d'authentification:"
echo ""
echo "1) CI_JOB_TOKEN (recommandé - utilise le token du job)"
echo "2) Clone strategy (fetch au lieu de clone)"
echo "3) Token personnel (nécessite un token GitLab)"
echo ""
read -p "Votre choix (1-3): " CHOICE

case $CHOICE in
    1)
        print_info "Configuration avec GIT_STRATEGY=fetch et clone_url..."
        
        # Ajouter la configuration pour utiliser le token du job
        sed -i '/\[runners\.docker\]/a\    clone_url = "http://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.ohmyfx.local"' "$CONFIG_FILE"
        
        print_info "✅ Configuration ajoutée"
        ;;
        
    2)
        print_info "Cette option se configure dans le .gitlab-ci.yml"
        print_warn "Ajoutez dans votre .gitlab-ci.yml:"
        echo ""
        echo "variables:"
        echo "  GIT_STRATEGY: fetch"
        echo "  GIT_DEPTH: 0"
        echo ""
        ;;
        
    3)
        read -p "Entrez votre token GitLab: " GITLAB_TOKEN
        
        print_info "Configuration avec token personnel..."
        sed -i '/\[runners\.docker\]/a\    clone_url = "http://gitlab-ci-token:'$GITLAB_TOKEN'@gitlab.ohmyfx.local"' "$CONFIG_FILE"
        
        print_info "✅ Configuration ajoutée"
        ;;
        
    *)
        print_error "Choix invalide"
        exit 1
        ;;
esac

if [ "$CHOICE" != "2" ]; then
    print_info "Redémarrage du service GitLab Runner..."
    systemctl restart gitlab-runner
    
    sleep 2
    
    print_info "Vérification de la configuration..."
    gitlab-runner verify
fi

echo ""
echo "════════════════════════════════════════════════════════"
print_info "Configuration terminée!"
echo "════════════════════════════════════════════════════════"
echo ""

if [ "$CHOICE" == "2" ]; then
    print_warn "N'oubliez pas de modifier votre .gitlab-ci.yml"
fi

echo "Configuration actuelle du runner 'build docker images':"
grep -A 20 'name = "build docker images"' "$CONFIG_FILE" || true
echo ""
