#!/bin/bash

# Publish README.md to Docker Hub repository ephect/dev-php
# Usage: ./publish-overview.sh

REPO="ephect/dev-php"
README_FILE="./README.md"
DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME:-}
DOCKERHUB_PASSWORD=${DOCKERHUB_PASSWORD:-}

# Try to get credentials from docker config
if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_PASSWORD" ]; then
    if command -v jq &> /dev/null && [ -f ~/.docker/config.json ]; then
        CREDS_STORE=$(cat ~/.docker/config.json | jq -r '.credsStore // empty')
        
        if [ -n "$CREDS_STORE" ] && command -v docker-credential-$CREDS_STORE &> /dev/null; then
            CREDS=$(echo "https://index.docker.io/v1/" | docker-credential-$CREDS_STORE get 2>/dev/null)
            if [ $? -eq 0 ]; then
                DOCKERHUB_USERNAME=$(echo "$CREDS" | jq -r '.Username // empty')
                DOCKERHUB_PASSWORD=$(echo "$CREDS" | jq -r '.Secret // empty')
            fi
        fi
    fi
fi

if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_PASSWORD" ]; then
    echo "❌ Error: Unable to retrieve Docker Hub credentials"
    echo ""
    echo "Please set environment variables:"
    echo "  export DOCKERHUB_USERNAME=your-username"
    echo "  export DOCKERHUB_PASSWORD=your-token"
    exit 1
fi

if [ ! -f "$README_FILE" ]; then
    echo "❌ Error: README file not found: $README_FILE"
    exit 1
fi

echo "==========================================="
echo "Publishing to Docker Hub: $REPO"
echo "==========================================="

# Authenticate
TOKEN=$(curl -s -H "Content-Type: application/json" \
    -X POST \
    -d "{\"username\": \"$DOCKERHUB_USERNAME\", \"password\": \"$DOCKERHUB_PASSWORD\"}" \
    https://hub.docker.com/v2/users/login/ | jq -r .token)

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    echo "❌ Authentication failed"
    exit 1
fi

# Update description
README_JSON=$(jq -Rs . < "$README_FILE")

RESPONSE=$(curl -s -X PATCH \
    -H "Authorization: JWT $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"full_description\": $README_JSON}" \
    "https://hub.docker.com/v2/repositories/$REPO/")

if echo "$RESPONSE" | jq -e '.full_description' > /dev/null 2>&1; then
    echo "✅ Successfully published to Docker Hub!"
else
    echo "❌ Update failed:"
    echo "$RESPONSE" | jq .
    exit 1
fi

echo "==========================================="
