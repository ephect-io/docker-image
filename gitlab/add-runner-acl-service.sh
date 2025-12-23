#!/bin/bash

# Script de mise en place d'un service d'ACL pour GitLab Runner
# Pour RedHat/CentOS/Fedora avec Podman

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

getfacl /run/user/1000/podman/podman.sock
setfacl -m u:gitlab-runner:rw /run/user/1000/podman/podman.sock && getfacl /run/user/1000/podman/podman.sock

mkdir -p ~/.config/systemd/user/ && cat > ~/.config/systemd/user/podman-socket-acl.service << 'EOF'
[Unit]
Description=Set ACL on Podman socket for GitLab Runner
After=podman.socket
Requires=podman.socket
[Service]
Type=oneshot
ExecStart=/usr/bin/setfacl -m u:gitlab-runner:rw /run/user/1000/podman/podman.sock
RemainAfterExit=yes
[Install]
WantedBy=default.target
EOF

print_info "🔄 Rechargement des unités systemd utilisateur..."

systemctl --user daemon-reload \
    && systemctl --user enable podman-socket-acl.service \
    && systemctl --user start podman-socket-acl.service \
    && systemctl --user status podman-socket-acl.service