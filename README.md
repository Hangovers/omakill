# Omakill

Force-close frozen apps from the Omarchy bar. A skull button with a kill
panel: click-to-kill, window picker, and process picker with live CPU/MEM.

* **By clicking** — `hyprctl kill` xkill-style with a hint toast
* **Window** — pick an open window from the native menu
  (shows class/title + workspace/PID, no raw addresses)
* **Process** — pick a process with **live** CPU/MEM
  (btop-style `/proc` sampling, top-200 by memory, TERM→KILL escalation,
  PID 1/self guards, confirm step)

## Install

```sh
omarchy plugin add https://github.com/hangovers/omakill.git --enable
```

This puts the skull button in the bar (right section). Click it for the
kill panel, Escape closes it.

Requirements: Omarchy Quattro, `hyprctl`, `jq` — all stock. No extra
packages, no background services.

## Trigger menu (optional)

Prefer `SUPER+SPACE → kill` over the bar button? This repo also ships the
same three actions as a `Trigger › Kill` submenu:

```sh
git clone https://github.com/hangovers/omakill.git
cd omakill
./install.sh
```

Idempotent: merges a marked block into
`~/.config/omarchy/extensions/omarchy-menu.jsonc` (your other entries and
comments are untouched) and copies the two helper commands to
`~/.local/bin` (existing files are backed up first). Searching `kill`
shows only the `Kill` parent; enter it for the three actions.

## Remove

```sh
omarchy plugin remove io.github.hangovers.omakill
```

and, if you installed the Trigger menu:

```sh
./uninstall.sh
```

## How it works

The QML panel is a thin launcher: the bundled helpers in `bin/` do the
real work and summon Omarchy's native menus themselves, so there is no
duplicated picker logic. No background services, no config writes —
removing the plugin leaves nothing behind (except the optional Trigger
block, removed by `./uninstall.sh`).

## License

MIT — see [LICENSE](LICENSE).
