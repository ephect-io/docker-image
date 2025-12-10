#!/bin/bash

# Script d'installation et configuration de GitLab Runner
# Pour Fedora Server 43

set -e

echo "🚀 Installation de GitLab Runner..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
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

# Détection de l'OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    print_error "Impossible de détecter l'OS"
    exit 1
fi

print_info "OS détecté: $OS $VERSION"

# Vérification Fedora
if [ "$OS" != "fedora" ]; then
    print_error "Ce script est conçu pour Fedora Server 43"
    exit 1
fi

print_info "Installation pour Fedora Server..."

# Vérifier si GitLab Runner est déjà installé
if command -v gitlab-runner &> /dev/null; then
    print_warn "GitLab Runner est déjà installé"
    gitlab-runner --version
    read -p "Voulez-vous continuer la configuration ? (o/N): " CONTINUE
    if [[ ! "$CONTINUE" =~ ^[oO]$ ]]; then
        print_info "Installation annulée"
        exit 0
    fi
    SKIP_INSTALL=true
else
    SKIP_INSTALL=false
fi

# Ajout du dépôt GitLab Runner
if [ "$SKIP_INSTALL" = false ]; then
    curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | bash
    
    # Installation de GitLab Runner
    dnf install -y gitlab-runner
fi

# Installation de Podman et podman-compose si pas déjà installés
if ! command -v podman &> /dev/null; then
    print_info "Installation de Podman..."
    dnf install -y podman podman-compose podman-docker
else
    print_info "Podman est déjà installé"
fi

# Activer le socket Podman pour GitLab Runner
systemctl enable --now podman.socket
usermod -aG podman gitlab-runner || true

# Vérification de l'installation
if [ "$SKIP_INSTALL" = false ]; then
    if command -v gitlab-runner &> /dev/null; then
        print_info "GitLab Runner installé avec succès!"
        gitlab-runner --version
    else
        print_error "Échec de l'installation de GitLab Runner"
        exit 1
    fi
fi

# Configuration
print_info "Configuration de GitLab Runner..."

# Demander les informations de configuration
echo ""
echo "════════════════════════════════════════════════════════"
echo "  Configuration de GitLab Runner"
echo "════════════════════════════════════════════════════════"
echo ""

read -p "URL de GitLab (ex: https://gitlab.com): " GITLAB_URL
read -p "Token d'enregistrement: " REGISTRATION_TOKEN
read -p "Description du runner (ex: docker-runner): " RUNNER_DESCRIPTION
read -p "Tags (séparés par des virgules, ex: docker,linux): " RUNNER_TAGS

# Enregistrement du runner
print_info "Enregistrement du runner..."

gitlab-runner register \
    --non-interactive \
    --url "$GITLAB_URL" \
    --registration-token "$REGISTRATION_TOKEN" \
    --executor "docker" \
    --docker-image "docker:24-git" \
    --description "$RUNNER_DESCRIPTION" \
    --tag-list "$RUNNER_TAGS" \
    --run-untagged="false" \
    --locked="false" \
    --docker-privileged="true" \
    --docker-volumes "/run/podman/podman.sock:/var/run/docker.sock" \
    --docker-volumes "/cache" \
    --docker-host "unix:///run/podman/podman.sock"

if [ $? -eq 0 ]; then
    print_info "Runner enregistré avec succès!"
else
    print_error "Échec de l'enregistrement du runner"
    exit 1
fi

# Démarrage du service
print_info "Démarrage du service GitLab Runner..."
systemctl start gitlab-runner
systemctl enable gitlab-runner

# Vérification du statut
print_info "Statut du service:"
systemctl status gitlab-runner --no-pager

# Affichage des runners enregistrés
print_info "Runners enregistrés:"
gitlab-runner list

echo ""
echo "════════════════════════════════════════════════════════"
print_info "Installation et configuration terminées!"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Commandes utiles:"
echo "  - Voir les runners: gitlab-runner list"
echo "  - Statut du service: systemctl status gitlab-runner"
echo "  - Logs: journalctl -u gitlab-runner -f"
echo "  - Redémarrer: systemctl restart gitlab-runner"
echo "  - Désinscrire un runner: gitlab-runner unregister --name <nom>"
echo ""
