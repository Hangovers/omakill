#!/bin/bash
# Installs the omakill Trigger menu + commands. Idempotent — safe to re-run.
# Usage: ./install.sh [--with-bar]
#   --with-bar also enables the optional skull button in the bar.
set -euo pipefail

# Harden helper lookup: ignore inherited PATH.
export PATH="/usr/local/bin:/usr/bin:/bin"
IFS=$'\n\t'

WITH_BAR=0
if [[ "${1:-}" == "--with-bar" ]]; then
  WITH_BAR=1
elif [[ -n "${1:-}" ]]; then
  echo "Usage: $0 [--with-bar]" >&2
  exit 1
fi

PLUGIN_ID="io.github.hangovers.omakill"

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
BIN_DST="$HOME/.local/bin"
MENU_FILE="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
MARK_BEGIN='// >>> omakill'
MARK_END='// <<< omakill'

missing=()
for cmd in hyprctl jq; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
if (( ${#missing[@]} > 0 )); then
  echo "Missing dependencies: ${missing[*]}" >&2
  echo "Install them first, then re-run." >&2
  exit 1
fi

mkdir -p "$BIN_DST"
for bin in omarchy-kill-window omarchy-kill-process; do
  if [[ -f "$BIN_DST/$bin" ]] && ! cmp -s "$REPO_DIR/bin/$bin" "$BIN_DST/$bin"; then
    [[ -f "$BIN_DST/$bin.bak.omakill" ]] || cp "$BIN_DST/$bin" "$BIN_DST/$bin.bak.omakill"
    echo "Backed up existing $bin to $bin.bak.omakill"
  fi
  cp "$REPO_DIR/bin/$bin" "$BIN_DST/$bin"
  chmod +x "$BIN_DST/$bin"
  echo "Installed $BIN_DST/$bin"
done

mkdir -p "$(dirname "$MENU_FILE")"
if [[ ! -f "$MENU_FILE" ]]; then
  printf '{\n}\n' > "$MENU_FILE"
  echo "Created $MENU_FILE"
fi
cp "$MENU_FILE" "$MENU_FILE.bak.$(date +%s)"

python3 - "$MENU_FILE" "$REPO_DIR/menu/kill.jsonc" "$MARK_BEGIN" "$MARK_END" <<'EOF'
import re, sys
menu_path, snippet_path, mark_begin, mark_end = sys.argv[1:5]
text = open(menu_path).read()
block = open(snippet_path).read().rstrip() + "\n"
# Remove any previously installed block (idempotency). Markers match whole lines.
text = re.sub(r"(?ms)^[ \t]*" + re.escape(mark_begin) + r".*?^[ \t]*" + re.escape(mark_end) + r"[^\n]*\n?",
              "", text)
# Insert before the final closing brace.
idx = text.rfind("}")
assert idx != -1, "menu file has no closing brace"
head = text[:idx].rstrip()
if not head.endswith("{") and not head.endswith(","):
    head += ","
text = head + "\n" + block + text[idx:]
# No trailing comma on the last entry before the closing brace.
text = re.sub(r",(\s*\n\s*\})", r"\1", text)
open(menu_path, "w").write(text)
EOF

# A backup was made above; validate JSON (comments stripped) before finishing.
python3 - "$MENU_FILE" <<'EOF'
import json, re, sys
text = open(sys.argv[1]).read()
text = re.sub(r"//.*", "", text)
json.loads(text)
print("Menu file valid.")
EOF

omarchy menu refresh >/dev/null 2>&1 || true
echo "Done. Press SUPER+SPACE and search 'kill'."

if (( WITH_BAR )); then
  omarchy plugin enable "$PLUGIN_ID" --section right
fi
