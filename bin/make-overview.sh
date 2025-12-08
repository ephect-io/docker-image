#!/bin/bash

# Docker Hub documentation generation script
# Usage: ./make-overview.sh --packages=apache,fpm --versions=8.4.15,8.5.0
# Example: ./make-overview.sh --packages=apache --versions=8.5.0

# Save current directory and return at the end
SCRIPT_DIR=$(pwd)
trap 'cd "$SCRIPT_DIR"' EXIT

cd php

# Parameters with default values
PACKAGES_ARG="apache"
VERSIONS_ARG="8.5.0"

# Parse named arguments
for arg in "$@"; do
    case $arg in
        --packages=*)
            PACKAGES_ARG="${arg#*=}"
            shift
            ;;
        --versions=*)
            VERSIONS_ARG="${arg#*=}"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --packages=PACKAGES    Comma-separated list of packages (default: apache)"
            echo "                         Available: apache, fpm, zts"
            echo "  --versions=VERSIONS    Comma-separated list of versions (default: 8.5.0)"
            echo "  --help, -h            Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --packages=apache,fpm --versions=8.4.15,8.5.0"
            echo "  $0 --packages=fpm --versions=8.5.0"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

ARCH=$(uname -m)
ROCKER=${ROCKER:-localhost:5000}
REPO="${ROCKER}/dev-php"
REMOTE_REPO="ephect/dev-php"
PUBLISH_REPO="ephect/dev-php"

# Convert arguments to arrays
IFS=',' read -ra PACKAGES <<< "$PACKAGES_ARG"
IFS=',' read -ra VERSIONS <<< "$VERSIONS_ARG"

# Global summary file (for Docker Hub)
OVERVIEW_FILE="../var/tmp/docker-hub-overview.md"
SUMMARY_FILE="../var/log/build-summary"

echo "========================================="
echo "Generating Docker Hub summary for:"
echo "Packages: ${PACKAGES[*]}"
echo "Versions: ${VERSIONS[*]}"
echo "========================================="

# Check if local registry is available
echo ""
echo "🔍 Checking local registry availability..."
if curl -s http://${ROCKER}/v2/_catalog > /dev/null 2>&1; then
    echo "✅ Local registry available at ${ROCKER}"
    USE_LOCAL_REGISTRY=true
else
    echo "⚠️  Local registry not available at ${ROCKER}"
    echo "   Using remote registry only: ${REMOTE_REPO}"
    USE_LOCAL_REGISTRY=false
fi
echo ""

# Initialize summary file
cat > "${OVERVIEW_FILE}" << 'EOF'
# 🐳 PHP Development Images

Optimized PHP Docker images for development with Apache/FPM/ZTS, including Xdebug, Composer, NVM and Node.js LTS.

EOF

cat >> "${OVERVIEW_FILE}" << EOF
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
    local REMOTE_TAG="${REMOTE_REPO}:${PACKAGE}-${VERSION}"
    local PULL_CMD="docker pull ${PUBLISH_REPO}:${PACKAGE}-${VERSION}"
    
    echo ""
    echo "📝 Processing: ${PACKAGE} ${VERSION}"
    
    # Determine which registry to pull from
    local PULL_TAG=${REMOTE_TAG}
    if [[ "${USE_LOCAL_REGISTRY}" == "true" ]]; then
        echo "   🔍 Checking local registry..."
        if docker manifest inspect ${TAG} > /dev/null 2>&1; then
            echo "   ✅ Using local registry"
            PULL_TAG=${TAG}
        else
            echo "   ℹ️ Not in local registry, using remote"
        fi
    fi
    
    # Check if image exists without pulling
    echo "   🔍 Checking if image exists..."
    if ! docker manifest inspect ${REMOTE_TAG} > /dev/null 2>&1; then
        echo "   ⚠️  Image not available: ${REMOTE_TAG}"
        echo "| **${PACKAGE}** | ${VERSION} | \`${PULL_CMD}\` | - | ❌ Not yet available |" >> "${OVERVIEW_FILE}"
        return 1
    fi
    
    # Pull image
    echo "   📥 Pulling image from ${PULL_TAG}..."
    if ! docker pull ${PULL_TAG} 2>/dev/null; then
        echo "   ⚠️  Failed to pull image: ${PULL_TAG}"
        echo "| **${PACKAGE}** | ${VERSION} | \`${PULL_CMD}\` | - | ❌ Pull failed |" >> "${OVERVIEW_FILE}"
        return 1
    fi
    
    # Tag as local if pulled from remote
    if [[ "${PULL_TAG}" == "${REMOTE_TAG}" ]]; then
        docker tag ${REMOTE_TAG} ${TAG} 2>/dev/null
    fi
    
    # Get image information
    local IMAGE_SIZE=$(docker images ${TAG} --format "{{.Size}}" 2>/dev/null)
    local IMAGE_ID=$(docker images ${TAG} --format "{{.ID}}" 2>/dev/null)
    
    echo "| **${PACKAGE}** | ${VERSION} | \`${PULL_CMD}\` | ${IMAGE_SIZE} | ✅ Available |" >> "${OVERVIEW_FILE}"
    
    # Store details for detailed section
    local KEY="${PACKAGE}-${VERSION}"
    IMAGE_DETAILS[$KEY]="${PACKAGE}|${VERSION}|${TAG}|${IMAGE_SIZE}|${IMAGE_ID}"
    
    echo "   ✅ Processed"
    return 0
}

# Track which packages have available versions
declare -A PACKAGE_HAS_VERSIONS

# Process each package/version combination
for PACKAGE in "${PACKAGES[@]}"; do
    PACKAGE_HAS_VERSIONS["${PACKAGE}"]=0
    for VERSION in "${VERSIONS[@]}"; do
        process_image "${PACKAGE}" "${VERSION}"
        # Check if this version was successfully processed
        KEY="${PACKAGE}-${VERSION}"
        if [[ -n "${IMAGE_DETAILS[$KEY]}" ]]; then
            PACKAGE_HAS_VERSIONS["${PACKAGE}"]=1
        fi
    done
done

# Add informative sections
cat >> "${OVERVIEW_FILE}" << 'EOF'

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
    cat >> "${OVERVIEW_FILE}" << EOF

### ${PACKAGE^^}

EOF
    
    # Check if this package has any available versions
    if [[ "${PACKAGE_HAS_VERSIONS[$PACKAGE]}" -eq 0 ]]; then
        cat >> "${OVERVIEW_FILE}" << EOF
No ${PACKAGE} images are currently available.

EOF
        continue
    fi
    
    for VERSION in "${VERSIONS[@]}"; do
        KEY="${PACKAGE}-${VERSION}"
        if [[ -v IMAGE_DETAILS[$KEY] ]]; then
            IFS='|' read -ra DETAILS <<< "${IMAGE_DETAILS[$KEY]}"
            PKG="${DETAILS[0]}"
            VER="${DETAILS[1]}"
            TAG="${DETAILS[2]}"
            SIZE="${DETAILS[3]}"
            ID="${DETAILS[4]}"
            
            cat >> "${OVERVIEW_FILE}" << PKGEOF

#### PHP ${VER} - ${PKG}

**Tag:** \`${PUBLISH_REPO}:${PKG}-${VER}\`  
**Size:** ${SIZE}  
**Image ID:** ${ID}

**Build Log:**

PKGEOF
            IMAGE_SUMMARY_FILE="${SUMMARY_FILE}-${PKG}-${VER}.md"


            # Extract log from container
            echo "   📋 Extracting build log for ${PKG} ${VER}..."
            if [ -f "${IMAGE_SUMMARY_FILE}" ]; then
                cat "${IMAGE_SUMMARY_FILE}" >> "${OVERVIEW_FILE}"
                echo "   ✅ Log extracted"
            else
                echo "⚠️  Build log not available" >> "${OVERVIEW_FILE}"
                echo "   ⚠️  Log not available"
            fi
            
       
        fi
    done
done

# Add footer section
cat >> "${OVERVIEW_FILE}" << 'EOF'

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
echo "📊 Docker Hub summary: ${OVERVIEW_FILE}"
echo "========================================="

cat ../registry/more_info.md >> ${OVERVIEW_FILE}
cat ../devcontainer/more_info.md >> ${OVERVIEW_FILE}
cp "${OVERVIEW_FILE}" ../README.md
