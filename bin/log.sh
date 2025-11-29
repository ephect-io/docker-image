#!/bin/bash

# Script de build avec génération automatique de README.md
# Usage: ./build-and-log.sh <package> <version>

# Sauvegarder le répertoire actuel et y revenir à la fin
SCRIPT_DIR=$(pwd)
trap 'cd "$SCRIPT_DIR"' EXIT

cd php

PACKAGE=${1:-apache}
VERSION=${2:-8.5.0}
ARCH=$(uname -m)
TAG="localhost:5000/dev-php:${PACKAGE}-${VERSION}"
README_FILE="./${PACKAGE}/README.md"
TEMP_CONTAINER="temp-build-log-$$"

echo "========================================="
echo "Logging PHP ${VERSION} - ${PACKAGE}"
echo "========================================="

BUILD_STATUS=0

# Initialiser le README
cat > "${README_FILE}" << EOF
# PHP ${VERSION} - ${PACKAGE}

**Date de build:** $(date '+%Y-%m-%d %H:%M:%S')
**Architecture:** ${ARCH}
**Tag:** \`${TAG}\`

---

## 📋 Rapport de Build

EOF

if [ $BUILD_STATUS -eq 0 ]; then
    echo "✅ Build réussi!"

    # Pull l'image depuis la registry locale
    echo "📥 Récupération de l'image depuis la registry locale..."
    docker pull ${TAG} 2>/dev/null || {
        echo "⚠️  Impossible de récupérer l'image depuis la registry"
    }

    # Extraire le log depuis le conteneur
    echo "📝 Extraction du build log..."
    docker run --rm --name ${TEMP_CONTAINER} ${TAG} cat /tmp/build-log.md >> "${README_FILE}" 2>/dev/null || {
        echo "⚠️  Impossible d'extraire le log depuis le conteneur" >> "${README_FILE}"
    }

    # Ajouter des informations supplémentaires
    cat >> "${README_FILE}" << EOF

---

## 🐳 Informations de l'image

\`\`\`bash
# Taille de l'image
$(docker images ${TAG} --format "{{.Size}}")

# ID de l'image
$(docker images ${TAG} --format "{{.ID}}")
\`\`\`

## 📦 Utilisation

\`\`\`bash
# Lancer un conteneur
docker run -it --rm ${TAG} bash

# Vérifier PHP
docker run --rm ${TAG} php --version

# Vérifier Composer
docker run --rm ${TAG} composer --version

# Vérifier Node.js (en tant que salamandra)
docker run --rm -u salamandra ${TAG} bash -c "source ~/.bashrc && node --version"
\`\`\`

## 🔧 Extensions PHP installées

\`\`\`bash
$(docker run --rm ${TAG} php -m 2>/dev/null || echo "Non disponible")
\`\`\`

EOF

    echo "✅ README.md généré dans ${README_FILE}"

else
    echo "❌ Build échoué!"
    cat >> "${README_FILE}" << EOF
### ❌ Le build a échoué

Le build de l'image a échoué. Vérifiez les logs Docker pour plus de détails.

**Code de sortie:** ${BUILD_STATUS}

Pour déboguer, essayez :
\`\`\`bash
docker build ./${PACKAGE} --build-arg VERSION=${VERSION} --progress=plain
\`\`\`
EOF
    echo "📝 README.md d'erreur généré dans ${README_FILE}"
    exit ${BUILD_STATUS}
fi

echo "========================================="
echo "✅ Processus terminé"
echo "========================================="   