#!/bin/bash

# Build script for Lenderly Dialer
# Usage: ./build.sh [dev|prod] [android|ios|web]

ENVIRONMENT=${1:-dev}
PLATFORM=${2:-android}

echo "Building Lenderly Dialer for $ENVIRONMENT environment on $PLATFORM platform..."

# Copy the appropriate environment file
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "Using production configuration..."
    # You could add additional production-specific setup here
elif [ "$ENVIRONMENT" = "dev" ]; then
    echo "Using development configuration..."
    # You could add additional development-specific setup here
else
    echo "Invalid environment: $ENVIRONMENT. Use 'dev' or 'prod'"
    exit 1
fi

# Build based on platform
case $PLATFORM in
    android)
        echo "Building for Android..."
        flutter build apk --dart-define=ENVIRONMENT=$ENVIRONMENT
        ;;
    ios)
        echo "Building for iOS..."
        flutter build ios --dart-define=ENVIRONMENT=$ENVIRONMENT
        ;;
    web)
        echo "Building for Web..."
        flutter build web --dart-define=ENVIRONMENT=$ENVIRONMENT
        ;;
    *)
        echo "Invalid platform: $PLATFORM. Use 'android', 'ios', or 'web'"
        exit 1
        ;;
esac

echo "Build completed!"
