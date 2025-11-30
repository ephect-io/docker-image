#!/bin/bash

# Docker Hub documentation generation script
# Usage: ./log.sh [package1,package2,...] [version1,version2,...]
# Example: ./log.sh apache,fpm 8.4.15,8.5.0

# Save current directory and return at the end
SCRIPT_DIR=$(pwd)
trap 'cd "$SCRIPT_DIR"' EXIT

cd php

# Parameters with default values
PACKAGES_ARG=${1:-apache}
VERSIONS_ARG=${2:-8.5.0}
ARCH=$(uname -m)
ROCKER=${ROCKER:-localhost:5000}
REPO="${ROCKER}/dev-php"
PUBLISH_REPO="ephect/dev-php"

# Convert arguments to arrays
IFS=',' read -ra PACKAGES <<< "$PACKAGES_ARG"
IFS=',' read -ra VERSIONS <<< "$VERSIONS_ARG"

# Global summary file (for Docker Hub)
SUMMARY_FILE="./DOCKER_HUB_README.md"

echo "========================================="
echo "Generating Docker Hub summary for:"
echo "Packages: ${PACKAGES[*]}"
echo "Versions: ${VERSIONS[*]}"
echo "========================================="

# Initialize summary file
cat > "${SUMMARY_FILE}" << 'EOF'
# 🐳 PHP Development Images

Optimized PHP Docker images for development with Apache/FPM/ZTS, including Xdebug, Composer, NVM and Node.js LTS.

EOF

cat >> "${SUMMARY_FILE}" << EOF
**Last update:** $(date '+%Y-%m-%d %H:%M:%S')  
**Architecture:** ${ARCH}  
**Registry:** [ephect/dev-php](https://hub.docker.com/r/ephect/dev-php)

---

## 📦 Available Images

| Package | Version | Pull Command | Size | Build Status |
|---------|---------|--------------|------|--------------|
EOF

# Variables to store image details
declare -A IMAGE_DETAILS

# Function to generate image information
process_image() {
    local PACKAGE=$1
    local VERSION=$2
    local TAG="${REPO}:${PACKAGE}-${VERSION}"
    local PULL_CMD="docker pull ${PUBLISH_REPO}:${PACKAGE}-${VERSION}"
    
    echo ""
    echo "📝 Processing: ${PACKAGE} ${VERSION}"
    
    # Pull image from local registry
    echo "   📥 Pulling image..."
    if ! docker pull ${TAG} 2>/dev/null; then
        echo "   ⚠️  Image not available: ${TAG}"
        echo "| **${PACKAGE}** | ${VERSION} | \`${PULL_CMD}\` | - | ❌ Not available |" >> "${SUMMARY_FILE}"
        return 1
    fi
    
    # Get image information
    local IMAGE_SIZE=$(docker images ${TAG} --format "{{.Size}}" 2>/dev/null)
    local IMAGE_ID=$(docker images ${TAG} --format "{{.ID}}" 2>/dev/null)
    
    echo "| **${PACKAGE}** | ${VERSION} | \`${PULL_CMD}\` | ${IMAGE_SIZE} | ✅ Available |" >> "${SUMMARY_FILE}"
    
    # Store details for detailed section
    local KEY="${PACKAGE}-${VERSION}"
    IMAGE_DETAILS[$KEY]="${PACKAGE}|${VERSION}|${TAG}|${IMAGE_SIZE}|${IMAGE_ID}"
    
    echo "   ✅ Processed"
    return 0
}

# Process each package/version combination
for PACKAGE in "${PACKAGES[@]}"; do
    for VERSION in "${VERSIONS[@]}"; do
        process_image "$PACKAGE" "$VERSION"
    done
done

# Add informative sections
cat >> "${SUMMARY_FILE}" << 'EOF'

---

## 🚀 Quick Start

### Apache (mod_php)

```bash
# Pull image
docker pull ephect/dev-php:apache-8.5.0

# Start a container
docker run -d -p 8080:80 -v $(pwd):/var/www/html ephect/dev-php:apache-8.5.0

# Access container
docker exec -it <container_id> bash
```

### FPM (FastCGI Process Manager)

```bash
# Pull image
docker pull ephect/dev-php:fpm-8.5.0

# Start with nginx
docker run -d -p 9000:9000 -v $(pwd):/var/www/html ephect/dev-php:fpm-8.5.0
```

### ZTS (Zend Thread Safety)

```bash
# Pull image
docker pull ephect/dev-php:zts-8.5.0

# Start a container
docker run -it --rm ephect/dev-php:zts-8.5.0 bash
```

---

## ✨ Features

### 🔧 Pre-installed Tools

- **PHP** - Specified version (8.4.x, 8.5.x, etc.)
- **Composer** - PHP dependency manager
- **Xdebug** - PHP debugger and profiler
- **NVM** - Node Version Manager
- **Node.js LTS** - Latest LTS version
- **npm** - Node.js package manager
- **Git** - Version control
- **Vim** - Text editor

### 📦 Included PHP Extensions

- Core extensions (json, mbstring, xml, etc.)
- **Xdebug** - Debugging and code coverage
- **Zip** - Compression/decompression
- **PDO** - Database support
- **OPcache** - Opcode cache

### 👤 User Configuration

- User: `salamandra` (UID: 1000)
- Sudo access without password
- Member of `www-data` group

---

## 🔍 Image Details

EOF

# Add details for each image
for PACKAGE in "${PACKAGES[@]}"; do
    cat >> "${SUMMARY_FILE}" << EOF

### ${PACKAGE^^}

EOF
    
    for VERSION in "${VERSIONS[@]}"; do
        KEY="${PACKAGE}-${VERSION}"
        if [[ -v IMAGE_DETAILS[$KEY] ]]; then
            IFS='|' read -ra DETAILS <<< "${IMAGE_DETAILS[$KEY]}"
            PKG="${DETAILS[0]}"
            VER="${DETAILS[1]}"
            TAG="${DETAILS[2]}"
            SIZE="${DETAILS[3]}"
            ID="${DETAILS[4]}"
            
            cat >> "${SUMMARY_FILE}" << PKGEOF

#### PHP ${VER} - ${PKG}

**Tag:** \`${PUBLISH_REPO}:${PKG}-${VER}\`  
**Size:** ${SIZE}  
**Image ID:** ${ID}

**Build Log:**

PKGEOF
            
            # Extract log from container
            echo "   📋 Extracting build log for ${PKG} ${VER}..."
            if docker run --rm ${TAG} cat /tmp/build-log.md >> "${SUMMARY_FILE}" 2>/dev/null; then
                echo "   ✅ Log extracted"
            else
                echo "⚠️  Build log not available" >> "${SUMMARY_FILE}"
                echo "   ⚠️  Log not available"
            fi
            
            echo "" >> "${SUMMARY_FILE}"
            
            # Add PHP extensions
            cat >> "${SUMMARY_FILE}" << 'PKGEOF'

<details>
<summary>📦 Installed PHP Extensions</summary>

```
PKGEOF
            docker run --rm ${TAG} php -m 2>/dev/null >> "${SUMMARY_FILE}" || echo "Not available" >> "${SUMMARY_FILE}"
            cat >> "${SUMMARY_FILE}" << 'PKGEOF'
```

</details>

---

PKGEOF
        fi
    done
done

# Add footer section
cat >> "${SUMMARY_FILE}" << 'EOF'

## 🔗 Useful Links

- [PHP Official Images](https://hub.docker.com/_/php)
- [Composer](https://getcomposer.org/)
- [Xdebug Documentation](https://xdebug.org/docs/)
- [NVM](https://github.com/nvm-sh/nvm)
- [Node.js](https://nodejs.org/)

## 📝 Notes

These images are designed for **development** as Xdebug is enabled by default.

EOF

echo ""
echo "========================================="
echo "✅ Process completed"
echo "📊 Docker Hub summary: ${SUMMARY_FILE}"
echo "========================================="

cat ../registry/more_info.md >> ${SUMMARY_FILE}
cat ../devcontainer/more_info.md >> ${SUMMARY_FILE}
cp "${SUMMARY_FILE}" ../README.md
