#!/usr/bin/env bash
set -Eeuo pipefail

PANEL_DIR="${PANEL_DIR:-/var/www/pterodactyl}"
THEME_ID="rb-style"
THEME_DIR="$PANEL_DIR/public/themes/$THEME_ID"
WRAPPER="$PANEL_DIR/resources/views/templates/wrapper.blade.php"
CSS_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/theme.css"
MARKER="RB_STYLE_THEME_LINK"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash install.sh"
  exit 1
fi
if [[ ! -d "$PANEL_DIR" || ! -f "$PANEL_DIR/artisan" ]]; then
  echo "Panel not found at $PANEL_DIR. Set PANEL_DIR=/your/panel/path and retry."
  exit 1
fi
if [[ ! -f "$WRAPPER" ]]; then
  echo "Expected legacy Panel 1.x wrapper not found: $WRAPPER"
  echo "This installer supports the legacy 1.x Blade layout only. No files changed."
  exit 1
fi
if [[ ! -f "$CSS_SOURCE" ]]; then
  echo "theme.css is missing next to install.sh. No files changed."
  exit 1
fi

cd "$PANEL_DIR"
if ! grep -q '"version"' package.json 2>/dev/null; then
  echo "Could not identify the panel package version. Continuing only after confirming this is Panel 1.x."
fi
if grep -q 'p:theme:apply' artisan 2>/dev/null; then
  echo "This looks like a newer theme-enabled panel. Use its official theme system instead."
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$PANEL_DIR/.rb-style-backups/$STAMP"
mkdir -p "$BACKUP_DIR" "$THEME_DIR"
cp -a "$WRAPPER" "$BACKUP_DIR/wrapper.blade.php"
if [[ -f "$THEME_DIR/theme.css" ]]; then
  cp -a "$THEME_DIR/theme.css" "$BACKUP_DIR/theme.css"
fi

install -m 0644 "$CSS_SOURCE" "$THEME_DIR/theme.css"

if ! grep -q "$MARKER" "$WRAPPER"; then
  python3 - "$WRAPPER" "$MARKER" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
marker = sys.argv[2]
text = path.read_text()
link = "    {{-- " + marker + " --}}\n    <link rel=\"stylesheet\" href=\"{{ asset('themes/rb-style/theme.css') }}?v=1.0.0\">\n" 
if "</head>" not in text:
    print("Could not find </head> in wrapper; refusing to patch.")
    sys.exit(2)
text = text.replace("</head>", link + "</head>", 1)
path.write_text(text)
PY
fi

chown -R www-data:www-data "$THEME_DIR" 2>/dev/null || true
php artisan view:clear
echo
echo "RB Style installed."
echo "CSS: $THEME_DIR/theme.css"
echo "Backup: $BACKUP_DIR"
echo "Refresh your browser and clear its cache if needed."
