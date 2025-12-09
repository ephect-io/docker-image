#!/bin/bash

# Docker Hub documentation generation script
# Example: ./make-manifest.sh --package=apache --version=8.5.0

# Default values
PACKAGE=""
VERSION=""
ALL_ARCH="false"
ROCKER=${ROCKER:-"docker.io/ephect"}


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
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --package=PACKAGE     Package to build (apache, fpm, zts)"
            echo "  --version=VERSION     PHP version (e.g., 8.5.0)"
            echo "  --help, -h            Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  ROCKER                Local ROCKER URL (default: localhost:5000)"
            echo ""
            echo "Examples:"
            echo "  $0 --package=apache --version=8.5.0"
            echo "  $0 --package=fpm --version=8.5.0"
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

# Define tags
FULL_TAG_AMD64="${ROCKER}/dev-php:${PACKAGE}-${VERSION}-x86_64"
FULL_TAG_ARM64="${ROCKER}/dev-php:${PACKAGE}-${VERSION}-arm64"
FULL_TAG_MULTI="${ROCKER}/dev-php:${PACKAGE}-${VERSION}"

echo "🛠️  Creating multi-arch manifest for:"
echo "  AMD64: $FULL_TAG_AMD64"
echo "  ARM64: $FULL_TAG_ARM64"
echo "  → Multi-arch tag: $FULL_TAG_MULTI"
echo ""

# Check if images exist
echo "🔍 Checking if images exist..."
if ! docker manifest inspect "$FULL_TAG_AMD64" > /dev/null 2>&1; then
    echo "❌ AMD64 image not found: $FULL_TAG_AMD64"
    exit 1
fi

if ! docker manifest inspect "$FULL_TAG_ARM64" > /dev/null 2>&1; then
    echo "❌ ARM64 image not found: $FULL_TAG_ARM64"
    exit 1
fi

echo "✅ Both images found"
echo ""

# Remove existing manifest if it exists
echo "🧹 Removing existing manifest if present..."
docker manifest rm "$FULL_TAG_MULTI" 2>/dev/null || true

# Create manifest
echo "📦 Creating manifest..."
if ! docker manifest create "$FULL_TAG_MULTI" \
    "$FULL_TAG_AMD64" \
    "$FULL_TAG_ARM64"; then
    echo "❌ Failed to create manifest"
    exit 1
fi

# Annotate architectures
echo "🏷️  Annotating architectures..."
docker manifest annotate "$FULL_TAG_MULTI" "$FULL_TAG_AMD64" --os linux --arch amd64
docker manifest annotate "$FULL_TAG_MULTI" "$FULL_TAG_ARM64" --os linux --arch arm64 --variant v8

# Push manifest
echo "📤 Pushing manifest..."
if ! docker manifest push "$FULL_TAG_MULTI"; then
    echo "❌ Failed to push manifest"
    exit 1
fi

echo ""
echo "✅ Multi-arch manifest created and pushed: $FULL_TAG_MULTI"