#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting Flutter environment setup..."

# 0. Define Flutter version and installation directory
FLUTTER_VERSION="3.22.2" # Specify a recent stable version
FLUTTER_SDK_BASE_DIR="$HOME/sdks"
FLUTTER_SDK_DIR="$FLUTTER_SDK_BASE_DIR/flutter"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_DOWNLOAD_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"

# Shell configuration file
# Common choices: ~/.bashrc, ~/.zshrc, ~/.profile
# Defaulting to .bashrc
SHELL_CONFIG_FILE="$HOME/.bashrc"

echo "Flutter version to install: $FLUTTER_VERSION"
echo "Installation directory: $FLUTTER_SDK_DIR"
echo "Shell configuration file: $SHELL_CONFIG_FILE"

# 1. Install prerequisite system packages (for Debian/Ubuntu)
#    Adjust for other distributions (e.g., use dnf/yum for Fedora/CentOS)
echo "Updating package lists..."
sudo apt-get update -y

echo "Installing prerequisites: git, curl, unzip, xz-utils, libglu1-mesa..."
# libglu1-mesa is often needed for desktop support, though not strictly for web/mobile CLI
# curl for downloading, unzip if using zip archives (though Flutter uses tar.xz), xz-utils for .tar.xz
sudo apt-get install -y git curl unzip xz-utils libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev

# 2. Create installation directory if it doesn't exist
echo "Creating installation directory: $FLUTTER_SDK_BASE_DIR"
mkdir -p "$FLUTTER_SDK_BASE_DIR"
cd "$FLUTTER_SDK_BASE_DIR"

# 3. Download Flutter SDK
if [ -d "$FLUTTER_SDK_DIR" ]; then
    echo "Flutter SDK directory already exists at $FLUTTER_SDK_DIR. Skipping download and extraction."
else
    echo "Downloading Flutter SDK: $FLUTTER_DOWNLOAD_URL..."
    curl -O "$FLUTTER_DOWNLOAD_URL"

    # 4. Extract Flutter SDK
    echo "Extracting Flutter SDK..."
    tar xf "$FLUTTER_ARCHIVE"
    # The extracted folder is named "flutter" by default.
    # If it were different, you'd rename it here: mv flutter-extracted-folder "$FLUTTER_SDK_DIR"
    # Since it's already "flutter", this effectively moves it if FLUTTER_SDK_DIR was just $FLUTTER_SDK_BASE_DIR/flutter

    # 5. Clean up downloaded archive
    echo "Cleaning up downloaded archive..."
    rm "$FLUTTER_ARCHIVE"
fi

# 6. Add Flutter to PATH in the shell configuration file
echo "Adding Flutter to PATH in $SHELL_CONFIG_FILE..."
# Check if Flutter path is already in the config file to avoid duplicates
if grep -q "$FLUTTER_SDK_DIR/bin" "$SHELL_CONFIG_FILE"; then
    echo "Flutter PATH already exists in $SHELL_CONFIG_FILE."
else
    echo "export PATH=\"\$PATH:$FLUTTER_SDK_DIR/bin\"" >> "$SHELL_CONFIG_FILE"
    echo "Flutter PATH added. Please source your shell config or open a new terminal."
fi

# 7. (Attempt to) Add Flutter to PATH for the current session
#    This allows subsequent commands in this script (or the agent's session) to use flutter
echo "Adding Flutter to PATH for the current session..."
export PATH="$PATH:$FLUTTER_SDK_DIR/bin"

# 8. Run flutter doctor to verify and download additional tools
echo "Running flutter doctor..."
# Disable analytics and crash reporting for automated script
flutter --disable-analytics
flutter config --no-analytics

# Pre-download Dart SDK to avoid issues during first flutter doctor run
echo "Precaching Dart SDK..."
flutter precache

echo "Running flutter doctor to check setup..."
flutter doctor

# 9. Enable web support
echo "Enabling Flutter web support..."
flutter config --enable-web

echo "Flutter setup script finished."
echo "---------------------------------------------------------------------"
echo "IMPORTANT:"
echo "If the script modified $SHELL_CONFIG_FILE, you might need to run:"
echo "  source $SHELL_CONFIG_FILE"
echo "or open a new terminal for the PATH changes to take effect permanently."
echo "Run 'flutter doctor' again in a new terminal to confirm."
echo "---------------------------------------------------------------------"
