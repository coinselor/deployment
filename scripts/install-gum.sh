# Minimal prerequisites
$SUDO apt-get update -y
$SUDO apt-get install -y wget

GUM_VERSION="0.14.5"
ARCH=$(dpkg --print-architecture) # For Ubuntu/Debian: often "amd64"
GUM_DEB_URL="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_${ARCH}.deb"

if command -v gum &>/dev/null; then
	# Gum already installed, return quietly
	exit 0
fi

echo "Installing gum..."
wget -qO /tmp/gum.deb "$GUM_DEB_URL"
$SUDO apt-get install -y /tmp/gum.deb
rm /tmp/gum.deb

if ! command -v gum &>/dev/null; then
	echo "Error: gum installation failed." >&2
	exit 1
fi
