#!/usr/bin/env bash
set -Eeuo pipefail
PANEL_DIR="${PANEL_DIR:-/var/www/pterodactyl}"
WRAPPER="$PANEL_DIR/resources/views/templates/wrapper.blade.php"
THEME_DIR="$PANEL_DIR/public/themes/rb-style"
MARKER="RB_STYLE_THEME_LINK"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash uninstall.sh"
  exit 1
fi
if [[ ! -f "$WRAPPER" ]]; then
  echo "Panel wrapper not found: $WRAPPER"
  exit 1
fi

python3 - "$WRAPPER" "$MARKER" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
marker = sys.argv[2]
lines = p.read_text().splitlines(keepends=True)
out = []
skip_next = False
for line in lines:
    if marker in line:
        skip_next = True
        continue
    if skip_next and "themes/rb-style/theme.css" in line:
        skip_next = False
        continue
    if skip_next:
        skip_next = False
    out.append(line)
p.write_text("".join(out))
PY

rm -rf "$THEME_DIR"
php artisan view:clear
echo "RB Style CSS link and installed CSS removed."
echo "A timestamped wrapper backup remains in $PANEL_DIR/.rb-style-backups/."
echo "If the theme link remains, restore the latest wrapper backup manually."
