GUM_VERSION="0.14.5"
ARCH=$(dpkg --print-architecture) # For Ubuntu/Debian: often "amd64"
GUM_DEB_URL="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_${ARCH}.deb"

if command -v gum &>/dev/null; then
	return 0
fi

if ! command -v wget &>/dev/null; then
    echo "Installing wget..."
    $SUDO apt-get install -y wget
fi

echo "Installing gum..."
wget -qO /tmp/gum.deb "$GUM_DEB_URL"
$SUDO apt-get install -y /tmp/gum.deb
rm /tmp/gum.deb

if ! command -v gum &>/dev/null; then
	echo "Error: gum installation failed." >&2
	exit 1
fi

gum spin --spinner dot --title "Updating system packages..." -- $SUDO apt-get update -y
