#!/usr/bin/env sh

set -e

REPO="StanleyMasinde/LAN-remote"
VERSION="${1:-latest}"
INSTALL_DIR="${LAN_REMOTE_INSTALL:-/usr/local/bin}"
BINARY_NAME="lan_remote"

detect_platform() {
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    case "$os" in
        linux*) os="linux" ;;
        darwin*) os="macos" ;;
        mingw*|msys*|cygwin*) os="windows" ;;
        *) echo "Error: Unsupported OS: $os" >&2; exit 1 ;;
    esac

    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64) arch="x86_64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) echo "Error: Unsupported architecture: $arch" >&2; exit 1 ;;
    esac

    echo "${os}-${arch}"
}

get_release_data() {
    version="$1"

    if [ "$version" = "latest" ]; then
        api_url="https://api.github.com/repos/$REPO/releases/latest"
    else
        api_url="https://api.github.com/repos/$REPO/releases/tags/$version"
    fi

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$api_url" || {
            echo "Error: Could not fetch release data" >&2
            exit 1
        }
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$api_url" || {
            echo "Error: Could not fetch release data" >&2
            exit 1
        }
    else
        echo "Error: Neither curl nor wget found" >&2
        exit 1
    fi
}

parse_version() {
    json="$1"
    echo "$json" | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
}

parse_asset() {
    json="$1"
    filename="$2"

    asset_block=$(echo "$json" | sed -n "/\"name\"[[:space:]]*:[[:space:]]*\"${filename}\"/,/\"browser_download_url\"/p")

    url=$(echo "$asset_block" | grep '"browser_download_url"' | head -1 | sed 's/.*"browser_download_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    digest=$(echo "$asset_block" | grep '"digest"' | head -1 | sed 's/.*"sha256:\([^"]*\)".*/\1/')

    if [ -n "$url" ]; then
        echo "${url}|${digest}"
    fi
}

verify_checksum() {
    file="$1"
    expected_sha="$2"

    if [ -z "$expected_sha" ] || [ "$expected_sha" = "null" ]; then
        echo "Warning: No checksum available for this release asset"
        echo "Skipping verification"
        return 0
    fi

    echo "Verifying checksum..."

    if command -v sha256sum >/dev/null 2>&1; then
        actual_sha=$(sha256sum "$file" | awk '{print $1}')
    elif command -v shasum >/dev/null 2>&1; then
        actual_sha=$(shasum -a 256 "$file" | awk '{print $1}')
    else
        echo "Warning: Neither sha256sum nor shasum found"
        echo "Cannot verify checksum"
        return 0
    fi

    if [ "$actual_sha" = "$expected_sha" ]; then
        echo "Checksum verified: $expected_sha"
        return 0
    fi

    echo "Checksum verification failed" >&2
    echo "Expected: $expected_sha" >&2
    echo "Got:      $actual_sha" >&2
    return 1
}

install_lan_remote() {
    version="$1"
    platform="$2"

    case "$platform" in
        windows-*) ext="zip" ;;
        *) ext="tar.gz" ;;
    esac

    echo "LAN Remote Installer"
    echo ""
    echo "Fetching release information..."

    release_json=$(get_release_data "$version")

    resolved_version=$(parse_version "$release_json")
    if [ -z "$resolved_version" ]; then
        echo "Error: Could not parse version from API response" >&2
        exit 1
    fi

    filename="${BINARY_NAME}-${platform}-${resolved_version}.${ext}"

    echo "Version:  $resolved_version"
    echo "Platform: $platform"
    echo "Asset:    $filename"
    echo ""

    asset_info=$(parse_asset "$release_json" "$filename")

    if [ -z "$asset_info" ]; then
        echo "Error: Could not find asset '$filename' in release" >&2
        echo "" >&2
        echo "Available assets for this release:" >&2
        echo "$release_json" | grep -o '"name"[[:space:]]*:[[:space:]]*"lan_remote-[^"]*"' | sed 's/.*"\(lan_remote-[^"]*\)".*/  - \1/' >&2
        exit 1
    fi

    download_url=$(echo "$asset_info" | cut -d'|' -f1)
    sha256_digest=$(echo "$asset_info" | cut -d'|' -f2)

    if [ -z "$download_url" ]; then
        echo "Error: Could not extract download URL from release data" >&2
        exit 1
    fi

    tmp_dir=$(mktemp -d)

    cleanup() {
        cd / >/dev/null 2>&1 || true
        rm -rf "$tmp_dir"
    }
    trap cleanup EXIT INT TERM

    cd "$tmp_dir"

    echo "Downloading from: $download_url"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --progress-bar -o "$filename" "$download_url" || {
            echo "Error: Download failed" >&2
            exit 1
        }
    elif command -v wget >/dev/null 2>&1; then
        wget -q --show-progress -O "$filename" "$download_url" || {
            echo "Error: Download failed" >&2
            exit 1
        }
    else
        echo "Error: Neither curl nor wget found" >&2
        exit 1
    fi

    echo ""
    verify_checksum "$filename" "$sha256_digest"
    echo ""

    echo "Extracting..."
    case "$ext" in
        tar.gz)
            tar -xzf "$filename" || {
                echo "Error: Extraction failed" >&2
                exit 1
            }
            extracted_binary="$BINARY_NAME"
            ;;
        zip)
            if command -v unzip >/dev/null 2>&1; then
                unzip -q "$filename" || {
                    echo "Error: Extraction failed" >&2
                    exit 1
                }
            else
                echo "Error: unzip not found" >&2
                exit 1
            fi
            extracted_binary="$BINARY_NAME.exe"
            ;;
    esac

    if [ ! -f "$extracted_binary" ]; then
        echo "Error: Binary '$extracted_binary' not found after extraction" >&2
        exit 1
    fi

    chmod +x "$extracted_binary" 2>/dev/null || true

    echo "Installing to $INSTALL_DIR..."
    if mkdir -p "$INSTALL_DIR" 2>/dev/null; then
        install -m 755 "$extracted_binary" "$INSTALL_DIR/$extracted_binary"
    else
        sudo mkdir -p "$INSTALL_DIR"
        sudo install -m 755 "$extracted_binary" "$INSTALL_DIR/$extracted_binary" || {
            echo "Error: Installation failed" >&2
            echo "Set LAN_REMOTE_INSTALL to a writable directory if needed" >&2
            exit 1
        }
    fi

    trap - EXIT INT TERM
    cleanup

    echo ""
    echo "Installed: $INSTALL_DIR/$extracted_binary"
    echo "Run '$extracted_binary --help' to get started"
}

show_help() {
    cat <<EOF
LAN Remote Installer

Usage:
  curl -fsSL https://raw.githubusercontent.com/$REPO/main/install.sh | sh

Or with specific version:
  curl -fsSL https://raw.githubusercontent.com/$REPO/main/install.sh | sh -s v1.0.0

Environment Variables:
  LAN_REMOTE_INSTALL    Installation directory (default: /usr/local/bin)

Examples:
  # Install latest version
  curl -fsSL <installer-url> | sh

  # Install specific version
  curl -fsSL <installer-url> | sh -s v1.2.0

  # Install to custom location
  curl -fsSL <installer-url> | LAN_REMOTE_INSTALL=~/.local/bin sh

Supported Platforms:
  - Linux (x86_64, arm64)
  - macOS (x86_64, arm64)
  - Windows (x86_64, arm64)

Notes:
  - Downloads assets named like: lan_remote-<platform>-<arch>-<tag>.<ext>
  - Checksum verification runs when GitHub API provides a sha256 digest
EOF
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

main() {
    platform=$(detect_platform)

    if [ -z "$VERSION" ] || [ "$VERSION" = "latest" ]; then
        version="latest"
    else
        version="$VERSION"
    fi

    install_lan_remote "$version" "$platform"
}

main
