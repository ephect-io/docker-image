#!/bin/bash

# Script pour ajuster la configuration du runner "build docker images"
# Désactive le mode privileged qui n'est pas nécessaire avec le socket Podman

set -e

echo "🔧 Ajustement de la configuration du runner..."

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

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

print_info "Modification de privileged = true en privileged = false..."
sed -i 's/privileged = true/privileged = false/g' "$CONFIG_FILE"

print_info "Configuration mise à jour:"
echo ""
grep -A 15 'name = "build docker images"' "$CONFIG_FILE"
echo ""

print_info "Redémarrage du service GitLab Runner..."
systemctl restart gitlab-runner

sleep 2

print_info "Vérification de la configuration..."
gitlab-runner verify

print_info "✅ Configuration terminée!"
echo ""
echo "Le runner 'build docker images' utilise maintenant:"
echo "  - privileged = false"
echo "  - Socket Podman: /run/podman/podman.sock"
echo "  - Pas de Docker-in-Docker (DinD)"
echo ""
