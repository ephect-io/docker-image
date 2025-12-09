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
            echo "  ROCKER                Local ROCKER URL (default: localhost:5100)"
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

# Check if images exist and get their digests
echo "🔍 Checking if images exist and extracting platform-specific digests..."

# Get AMD64 digest
AMD64_DIGEST=$(docker manifest inspect "$FULL_TAG_AMD64" -v 2>/dev/null | \
    jq -r '.[] | select(.Descriptor.platform.architecture == "amd64") | .Descriptor.digest' | head -n 1)

if [ -z "$AMD64_DIGEST" ]; then
    echo "❌ AMD64 image not found or failed to extract digest: $FULL_TAG_AMD64"
    exit 1
fi

# Get ARM64 digest
ARM64_DIGEST=$(docker manifest inspect "$FULL_TAG_ARM64" -v 2>/dev/null | \
    jq -r '.[] | select(.Descriptor.platform.architecture == "arm64") | .Descriptor.digest' | head -n 1)

if [ -z "$ARM64_DIGEST" ]; then
    echo "❌ ARM64 image not found or failed to extract digest: $FULL_TAG_ARM64"
    exit 1
fi

# Construct digest references
AMD64_REF="${ROCKER}/dev-php@${AMD64_DIGEST}"
ARM64_REF="${ROCKER}/dev-php@${ARM64_DIGEST}"

echo "✅ Platform-specific images found:"
echo "  AMD64: ${AMD64_REF}"
echo "  ARM64: ${ARM64_REF}"
echo ""

# Remove existing manifest if it exists
echo "🧹 Removing existing manifest if present..."
docker manifest rm "$FULL_TAG_MULTI" 2>/dev/null || true

# Create manifest
echo "📦 Creating manifest..."
if ! docker manifest create "$FULL_TAG_MULTI" \
    "$AMD64_REF" \
    "$ARM64_REF"; then
    echo "❌ Failed to create manifest"
    exit 1
fi

# Annotate architectures
echo "🏷️  Annotating architectures..."
docker manifest annotate "$FULL_TAG_MULTI" "$AMD64_REF" --os linux --arch amd64
docker manifest annotate "$FULL_TAG_MULTI" "$ARM64_REF" --os linux --arch arm64 --variant v8

# Push manifest
echo "📤 Pushing manifest..."
if ! docker manifest push "$FULL_TAG_MULTI"; then
    echo "❌ Failed to push manifest"
    exit 1
fi

echo ""
echo "✅ Multi-arch manifest created and pushed: $FULL_TAG_MULTI"