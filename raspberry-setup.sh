#!/bin/bash

set -e

APP_DIR="$HOME/jidlovice-electron"
APP_NAME="jidlovice-electron"
AUTOSTART_DIR="$HOME/.config/autostart"
LABWC_AUTOSTART="$HOME/.config/labwc/autostart"
LOG_FILE="$HOME/.config/jidlovice-electron/logs/main.log"
LOGROTATE_CONF="/etc/logrotate.d/jidlovice-electron"

mkdir -p "$APP_DIR"

echo "Downloading latest $APP_NAME arm64 AppImage..."
LATEST_URL=$(curl -sL https://api.github.com/repos/webik150/jidlovice-electron-public/releases/latest \
    | grep browser_download_url \
    | grep arm64.AppImage\" \
    | cut -d '"' -f 4)

curl -L "$LATEST_URL" -o "$APP_DIR/$APP_NAME"
chmod +x "$APP_DIR/$APP_NAME"

# Add to X11 autostart
mkdir -p "$AUTOSTART_DIR"
cat > "$AUTOSTART_DIR/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=$APP_DIR/$APP_NAME
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=$APP_NAME
EOF

# Add to labwc autostart
mkdir -p "$(dirname "$LABWC_AUTOSTART")"
grep -qxF "$APP_DIR/$APP_NAME" "$LABWC_AUTOSTART" 2>/dev/null || echo "sleep 10; sudo $APP_DIR/$APP_NAME &" >> "$LABWC_AUTOSTART"
chmod +x "$LABWC_AUTOSTART"

# Setup logrotate
sudo tee "$LOGROTATE_CONF" > /dev/null <<EOF
$LOG_FILE {
    daily
    missingok
    rotate 7
    compress
    notifempty
    copytruncate
}
EOF

echo "Installation complete."
