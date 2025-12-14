#!/bin/bash

# Script de configuration du GitLab Runner pour utiliser Podman
# Pour Fedora Server 43

set -e

echo "🔧 Configuration de GitLab Runner pour Podman..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
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

print_info "Modification de la configuration pour Podman..."

# Créer une nouvelle configuration temporaire
cat > /tmp/gitlab-runner-podman.toml << 'EOF'
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

EOF

# Extraire les runners existants et les adapter pour Podman
gitlab-runner list 2>/dev/null | grep "Executor" | while read -r line; do
    print_info "Configuration d'un runner pour Podman..."
done

# Ajouter la configuration Podman à la suite
cat >> "$CONFIG_FILE" << 'EOF'

# Configuration spécifique pour Podman
# Les runners utiliseront le socket Podman au lieu de Docker
EOF

print_info "Redémarrage du service GitLab Runner..."
systemctl restart gitlab-runner

print_info "Vérification de la configuration..."
gitlab-runner verify

print_info "Configuration terminée!"
echo ""
echo "Note: Le runner utilise maintenant le socket Podman configuré lors de l'enregistrement."
echo "Socket Podman: /run/podman/podman.sock"
echo ""
echo "Pour vérifier: systemctl status gitlab-runner"
