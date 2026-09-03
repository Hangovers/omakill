# omarchy-kill

Kill submenu for the Omarchy menu (`SUPER+SPACE → kill`), plus the two
commands behind it. English only.

* **Trigger › Kill › By clicking** — `hyprctl kill` xkill-style with a hint toast
* **Trigger › Kill › Window** — pick an open window from the native menu
  (shows class/title + workspace/PID, no raw addresses)
* **Trigger › Kill › Process** — pick a process with **live** CPU/MEM
  (btop-style `/proc` sampling, top-200 by memory, TERM→KILL escalation,
  PID 1/self guards, confirm step)
* **Trigger › Kill › Task manager (btop)** — full live view

Searching `kill` shows only the `Kill` parent; enter it for the four actions.

## Install

```bash
git clone <this-repo-url> omarchy-kill
cd omarchy-kill
./install.sh
```

What it does (idempotent, re-run anytime):

1. Copies `bin/omarchy-kill-window` and `bin/omarchy-kill-process` to
   `~/.local/bin` (existing different files are backed up to
   `*.bak.omarchy-kill` first).
2. Merges the `Trigger › Kill` block into
   `~/.config/omarchy/extensions/omarchy-menu.jsonc` inside clearly marked
   comments — your other entries and comments are left untouched.
3. Runs `omarchy menu refresh`.

Requirements: Omarchy (Quattro menu), `hyprctl`, `jq`. `btop` for the Task
manager row.

## Uninstall

```bash
./uninstall.sh
```

Removes the menu block and the two commands (restoring backups when the
installer made them), then refreshes the menu.

## Why not a shell plugin?

Omarchy shell plugins (`omarchy plugin add …`) are Quickshell QML widgets
for the bar/panels/overlays. This pack integrates with the existing Omarchy
menu instead, so it ships as a tiny installer with no long-running code.

## License

MIT — see [LICENSE](LICENSE).
