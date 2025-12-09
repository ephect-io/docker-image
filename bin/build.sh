#!/bin/bash

# Docker multi-architecture build script
# Usage: ./build.sh --package=apache --version=8.5.0 [--full]
# Example: ./build.sh --package=fpm --version=8.5.0 

# Default values
PACKAGE=""
VERSION=""
ALL_ARCH="false"
ROCKER=${ROCKER:-localhost:5000}

# Parse named arguments
for arg in "$@"; do
    case $arg in
        --package=*)
            PACKAGE="${arg#*=}"
            shift
            ;;
        --version=*)
            VERSION="${arg#*=}"
            shift
            ;;
        --full)
            ALL_ARCH="true"
            shift
            ;;
        --prepare)
            PREPARE="true"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --package=PACKAGE     Package to build (apache, fpm, zts)"
            echo "  --version=VERSION     PHP version (e.g., 8.5.0)"
            echo "  --full                Build for all architectures and push"
            echo "  --prepare             Prepare build environment"
            echo "  --help, -h            Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  ROCKER                Local registry URL (default: localhost:5000)"
            echo ""
            echo "Examples:"
            echo "  $0 --package=apache --version=8.5.0"
            echo "  $0 --package=fpm --version=8.5.0 --full"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$PACKAGE" ] || [ -z "$VERSION" ]; then
    echo "❌ Error: Missing required parameters"
    echo ""
    echo "Required parameters:"
    echo "  --package=PACKAGE"
    echo "  --version=VERSION"
    echo ""
    echo "Use --help for more information"
    exit 1
fi

PUSH="--push"

if [ "$ALL_ARCH" == "true" ]; then
    PUSH="--push"
fi

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

ARCH=$(uname -m)
TAG=""

if [ "$USE_LOCAL_REGISTRY" = true ]; then
    TAG="${ROCKER}/dev-php:${PACKAGE}-${VERSION}"
else
    TAG="ephect/dev-php:${PACKAGE}-${VERSION}"
fi

if [ "$ALL_ARCH" == "true" ]; then
    ARCH="linux/amd64,linux/arm64/v8"
else
    TAG="${TAG}-${ARCH}"
fi

if [ "$PREPARE" == "true" ]; then
    echo "🛠️  Preparing build for ${PACKAGE} version ${VERSION} with tag ${TAG}"
    docker buildx create --use --name multiarch-builder || docker buildx use multiarch-builder
    docker buildx inspect --bootstrap
    echo "✅ Build environment prepared."
    exit 0
fi

echo "🚀 Building ${PACKAGE} version ${VERSION} for architecture ${ARCH} with tag ${TAG}"

# Get script directory and navigate to php folder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PHP_DIR="${SCRIPT_DIR}/../php"

set -e
docker buildx build --platform ${ARCH} ${PHP_DIR}/${PACKAGE} --build-arg VERSION=${VERSION} -t ${TAG} ${PUSH}

SUMMARY_FILE="./var/log/build-summary-${PACKAGE}-${VERSION}.md"
# Create or clear summary file
echo "" > "${SUMMARY_FILE}"
# Extract log from container
echo "   📋 Extracting build log for ${PACKAGE} ${VERSION}..."
if docker run --rm ${TAG} cat /tmp/build-log.md >> "${SUMMARY_FILE}" 2>/dev/null; then
    echo "   ✅ Log extracted"
else
    echo "⚠️  Build log not available" >> "${SUMMARY_FILE}"
    echo "   ⚠️  Log not available"
fi

if docker run --rm ${TAG} echo "### NTS build" >> "${SUMMARY_FILE}" && cat /tmp/build-log-stage-nts.md >> "${SUMMARY_FILE}" 2>/dev/null; then
    echo "   ✅ Log extracted"
else
    echo "⚠️  Build log not available" >> "${SUMMARY_FILE}"
    echo "   ⚠️  Log not available"
fi

if docker run --rm ${TAG} echo "### ZTS build" >> "${SUMMARY_FILE}" && cat /tmp/build-log-stage-zts.md >> "${SUMMARY_FILE}" 2>/dev/null; then
    echo "   ✅ Log extracted"
else
    echo "⚠️  Build log not available" >> "${SUMMARY_FILE}"
    echo "   ⚠️  Log not available"
fi

if docker run --rm ${TAG} echo "### Global build" >> "${SUMMARY_FILE}" && cat /tmp/build-log-stage-final.md >> "${SUMMARY_FILE}" 2>/dev/null; then
    echo "   ✅ Log extracted"
else
    echo "⚠️  Build log not available" >> "${SUMMARY_FILE}"
    echo "   ⚠️  Log not available"
fi

echo "" >> "${SUMMARY_FILE}"
    
# Add PHP extensions
cat >> "${SUMMARY_FILE}" << 'EOF'

<details>
<summary>📦 Installed PHP Extensions</summary>

```
EOF
docker run --rm ${TAG} php -m 2>/dev/null >> "${SUMMARY_FILE}" || echo "Not available" >> "${SUMMARY_FILE}"
cat >> "${SUMMARY_FILE}" << 'EOF'
```

</details>

---

EOF

echo "✅ Build completed: ${TAG}"
echo ""

