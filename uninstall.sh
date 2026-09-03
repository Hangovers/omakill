#!/bin/bash
# Removes everything install.sh added. Restores pre-install backups if present.
set -euo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
BIN_DST="$HOME/.local/bin"
MENU_FILE="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
MARK_BEGIN='// >>> omakill'
MARK_END='// <<< omakill'

for bin in omarchy-kill-window omarchy-kill-process; do
  if [[ -f "$BIN_DST/$bin" ]]; then
    if cmp -s "$REPO_DIR/bin/$bin" "$BIN_DST/$bin" 2>/dev/null; then
      rm -f "$BIN_DST/$bin"
      echo "Removed $BIN_DST/$bin"
    else
      echo "Kept $BIN_DST/$bin (differs from this repo — not ours to delete)"
    fi
  fi
  if [[ -f "$BIN_DST/$bin.bak.omakill" ]]; then
    mv "$BIN_DST/$bin.bak.omakill" "$BIN_DST/$bin"
    echo "Restored $bin from backup"
  fi
done

if [[ -f "$MENU_FILE" ]] && grep -q "$MARK_BEGIN" "$MENU_FILE"; then
  cp "$MENU_FILE" "$MENU_FILE.bak.$(date +%s)"
  python3 - "$MENU_FILE" "$MARK_BEGIN" "$MARK_END" <<'EOF'
import re, sys
menu_path, mark_begin, mark_end = sys.argv[1:4]
text = open(menu_path).read()
text = re.sub(r"(?ms)^[ \t]*" + re.escape(mark_begin) + r".*?^[ \t]*" + re.escape(mark_end) + r"[^\n]*\n?",
              "", text)
text = re.sub(r",(\s*\n\s*\})", r"\1", text)
open(menu_path, "w").write(text)
EOF
  echo "Removed Kill menu entries from $MENU_FILE"
else
  echo "No Kill menu block found — nothing to remove"
fi

omarchy menu refresh >/dev/null 2>&1 || true
echo "Done."
