# Progress notes

Working notes for continuing development (last updated 2026-11-08). Start a new session by reading this file.

## How we work on this repo

- Single branch: `main`. No feature branches, no PRs.
- Commit author: `lisboaphe <333786554+lisboaphe@users.noreply.github.com>`. Do not add AI co-author or "generated with" lines anywhere.
- Test, fix and reinstall freely; this is a personal project with no third-party delivery.
- After changes: run the checks below, then `bash install.sh </dev/null` to reinstall locally (keeps the pet save and backs up the old plugin).

## Checks

```bash
node tests/model.test.cjs                 # 42 model tests
python3 -m unittest discover -s tests -v  # assets + installer
python3 tests/smoke.py                    # 8 real Quickshell scenarios (needs quickshell)
python3 tests/mana.py                     # Egg hover / hatching in real QML
omarchy plugin validate .
```

`tests/transparency.py` needs Pillow (not installed on the laptop). `OMACHI_PREVIEW_DIR=/some/dir python3 tests/smoke.py` writes panel screenshots (home, attributes, activities, bar, naming, low-mood) for visual review.

## Done

### Fixes from the code review
- **Affection farm**: a pet at 95%+ fullness refuses food (`PetState.FULL_THRESHOLD`).
- **App detection**: whole-name class matching in `Activities.classify` (no more `foot` in `football-manager`, `code` in `decoder`). The Steam client is general use; running games (`steam_app_*`, gamescope, Lutris, Heroic, Prism, RetroArch) are gaming. Added Aseprite, Pinta, Typora, Vesktop, Element, LibreWolf, Cursor and others.
- **Offline gap**: only gaps over 5 s (`offlineGap`) count as offline, so GC/load stalls no longer reset training.
- **Performance**: the controller ticks at 1 s while nothing on screen needs it (`fastTick`); `copyPet` is a shallow copy plus nested maps instead of a JSON round trip; the overlay timer drops to 100 ms while posing; Hyprland events are debounced (50 ms) and polling went from 500 ms to 1 s.
- **Shutdown save** is synchronous (`saveFile.blockWrites`).
- **Single source of truth**: cooldowns/thresholds in `PetState.js`, `ACTIVITY_IDS` (tested against `Activities.definitions`), `Activities.intensiveBlocked`, version read from `manifest.json` (`service.version`).
- **Installer**: copies only runtime files (~2 MB instead of ~60 MB), reads version from the manifest, names backups `upgrade-from-vX-…`, keeps the newest 5, and retries when `omarchy-shell` is briefly unresponsive (`rescan`, and `plugin_action` retries "not responding").
- **Packaging**: `tools/package.py` ships only git-tracked files.
- Docs refreshed (README, CHANGELOG "Unreleased", ARCHITECTURE heading).

### Care feedback (roadmap v1.2)
- Bar sprite mirrors mood: sleeping / tired / sad / idle (`service.barAnimation`).
- Amber care dot by the Slime's head when fullness < 25, energy < 20 or happiness < 25 (`service.needsCare`).
- Bar tooltip shows name, status and the three care stats (`service.barTooltip`).
- Escape closes the panel.

### New animations (all generated in Aseprite from supplied frames, scripts in `tools/`)
| Sheet | Script | Notes |
|---|---|---|
| `slime/sad` | `build_mood_sprites.lua` | worried brows, sliding tear, greyer and deflated; from side-view idle |
| `slime/tired` | `build_mood_sprites.lua` | half-closed lids, sweat drop, flatter; from side-view idle |
| `slime/play` | `build_extra_sprites.lua` | 8-frame hop with squash/stretch and a bouncing beach ball; from front-facing idle variant |
| `slime/meditate` | `build_extra_sprites.lua` | 8-frame float, eyes closed, aura ring and orbiting sparkles (used by Relaxing) |

Rebuild commands are in the header of each `.lua` file (`aseprite -b --script-param … --script tools/…`).

## In progress: pixel-art HUD

Goal (from the owner): keep the glassy gradient panel background, add **static pixel-art elements**: modern layout, pixel-art style.

Done so far:
- `tools/build_ui_icons.lua` generates `assets/ui/*.png` (1:1 pixels, display at 2x with `smooth:false`):
  - care stats: `apple` (fullness), `heart` (happiness), `bolt` (energy), `zzz` (sleep)
  - nav: `home`, `growth`, `activities` (gamepad)
  - attributes: `mind` (book), `power` (sword), `creativity` (brush), `charisma` (star), `adventure` (compass)
  - `bubble`: thought bubble (17x16) for showing what the pet needs

Not wired into the UI yet. Planned next steps:
1. `src/ui/PixelIcon.qml`: `Image` with `smooth:false`, `mipmap:false`, size = source size × scale.
2. `src/ui/PixelBar.qml`: segmented "block" bar (about 10–12 segments, 2 px gaps) replacing the thin stat bars in `PetRoom.qml` and the XP bar in `AttributeCard.qml`.
3. `src/ui/PixelFrame.qml`: notched/stepped-corner frame drawn with a `Canvas` (`fillRect` only, 2 px pixel unit), used as the background of `PetButton`, stat cards and `AttributeCard` instead of `radius`.
4. Swap `NavIcon` Canvas line icons for the pixel nav icons (dim inactive ones with opacity).
5. Stat row in Home: icon + value + PixelBar; attribute cards get their icon next to the name.
6. Thought bubble above the pet in the room when `needsCare` (apple if hungry, bolt if tired, heart if sad, zzz while sleeping).
7. Re-render previews with `OMACHI_PREVIEW_DIR`, review, run all checks, reinstall, commit.

## Ideas / roadmap backlog

- v1.2: optional desktop notification when a need runs low (toggle in Activities); dedicated `paint`, `write`, `social` and `exercise` sheets (they still fall back to `read`, `read`, `listen_music` and `cast_earth`).
- v1.3: settings section; save management (manual "back up save now", list/restore backups from `~/.local/state/omachi-pet-backups`).
- Theme colours: follow the Omarchy theme instead of fixed hex values (needs checking how Omarchy exposes theme colours to plugins).
- Readability: the code is written as dense one-liners; consider a `qmlformat` + Prettier pass as its own commit.

## Known issues

- **Mixed art styles**: movement sheets and `slime/idle` are side-facing; activity, eat, sleep, portal and idle-variant sheets are front-facing. Ambient idle variants switch style every 12–20 s in the room. A front-facing room idle (keeping the side-view idle for roaming) would fix it.
- `slime/sleep_loop` has only 2 frames.
- Roaming, climbing, fullscreen hiding and multi-monitor behaviour still need live-desktop verification (see `docs/PUBLISHING.md`).
- The shell logs "Module path … is outside of the config folder" for every plugin; it is harmless shell noise.
