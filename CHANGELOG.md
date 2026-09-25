# v1.0.0 — release preparation, 2026-09-25

- Installer offers Left, Middle or Right taskbar placement, preserving the existing position by default on updates. Supports `--section` for noninteractive installs.
- Consolidates the single-player Egg/Slime lifecycle, mana hatching, care, activity growth and desktop roaming from v0.10.0.
- Preserves compatible saves and the install/update detection with asynchronous registry retries.
- Adds public-release preparation notes and native Omarchy removal instructions.
- Artwork is released under CC BY 4.0 with owner permission; code remains MIT. Public repository and live-desktop acceptance remain pending. No marketplace submission has been made.

# v0.10.0 — 2026-09-23

- Installer explicitly detects and reports fresh installation versus update, skips disable/backup for absent plugins, and preserves saves in both cases.

- Installer correction: waits/retries when the asynchronous Omarchy registry temporarily reports an unknown plugin, including rollback recovery. Other errors still fail immediately.

- Hovering over the named Egg in the open panel accelerates incubation 10×, stopping at one minute remaining. Leaving or closing the panel stops acceleration.
- The final minute runs normally and uses the new mana-filled shaking clip if hover charging reached the threshold. Charge state persists in compatible saves.
- Dedicated Egg Hatching screen with landscape, countdown and progress bar; Slime controls appear after the reveal.
- Shell background opacity reduced to 60%; text and sprites remain fully opaque.
- Imported both supplied mana sheets, five-frame walking and ten-frame Happy. Happy plays for petting and after feeding/playing.
- Added model and real QML hover, timing, lifecycle, persistence and compositing checks. Installation preserves saves; reset remains optional.

# v0.9.4 — 2026-09-23

- Reduced the shell background from roughly 90–94% opacity to 74%, allowing the desktop to show through.
- Made secondary cards and bottom navigation partially translucent as well.
- Text, pet sprites, buttons and landscape retain their original clarity; gameplay and save format are unchanged.

# v0.9.3 — 2026-09-23

- Translucent near-black shell, larger corners, subtle border and minimal name/status header.
- Full-width landscape fades into the interface; the pet remains crisp above the fade.
- Compact three-stat strip with an amber low-happiness indicator below 35%.
- Prominent Play action: +5 happiness, -2 energy, +0.3 affection, with a persistent 30-second cooldown. Feed, Sleep and Explore remain smaller controls.
- Floating bottom navigation with drawn icons, an animated selected pill, tab fades and gentle button compression.
- Slower neutral idle animation; activity and movement timings remain unchanged.

# v0.9.2 — 2026-09-23

- Replaced the runtime Egg idle, shake, crack and hatch sheets with the two newly supplied source sheets.
- Preserved the full 40-frame hatch source order across idle/crack/hatch, and synchronized lifecycle timing with the new clips.
- Retained the modern UI, name setup, lake scene, save compatibility and movement fixes.

# v0.9.1 — 2026-09-23

- Modernized the panel with clearer typography, a larger framed lake scene, segmented navigation, compact care cards and a mint primary action.
- Updated growth cards, activity settings and naming controls to match.
- Preserved naming, saves, animation mapping, movement and installer reload behavior.

# v0.9.0 — 2026-09-23

- Naming is the first step. Fresh Eggs wait for a valid name before their hatch timer starts; existing pets confirm their name without losing progress. Rename later in Activities.
- Kept the grassy-lake background, cleaner Home, independent Growth levels/XP and activity-specific animation behavior.
- Increased screen margins to fit the complete 112px overlay, kept inward edge movement, and clamped the rendered sprite to the visible surface.
- The installer restarts the Omarchy shell after enabling the update to release cached QML. The Home footer shows v0.9.0 so the loaded version can be checked.
- Added naming, offline naming-gate, full-sprite boundary and installer restart checks. Reset remains optional and preserves a backup.

# v0.8.2 — 2026-09-23

- Restored the supplied grassy-lake background on Home, behind both Egg and Slime.
- Uses the provided 700×370 image at its original aspect ratio without cropping or stretching, with nearest-neighbor display.
- Retains the v0.8.1 controls, growth bars, activity fixes and movement fixes. Installation preserves saves; the reset helper remains optional.

# v0.8.1 — 2026-09-23

- Fixed window-edge turn loops: zero-time world validation cannot retrigger an edge, and inward motion can leave the boundary.
- Activity poses wait for edge inspection and landings to finish. Recovery can also release a pending recall when physical movement stalls.
- All one-shot activity clips finish and return to idle; reading/music loops continue without detector refresh resets.
- Cleaner Home with a focused pet stage, quieter controls and care bars. Growth retains XP/level cards; activity configuration is collapsible.
- Added regression tests for the reported movement/animation failures and refreshed real UI previews.
- Included `restart-pet-save.sh`: disable, back up both save generations, then enable with a fresh Egg. Reset is separate from installation.

# v0.8.0 — 2026-09-20

- Redesigned Home, Attributes and Activities navigation; kept three essential care buttons.
- Independent attribute levels, XP bars, next-level targets and active-training highlights. Existing growth and saves preserved.
- Imported ten newer source sheets, including five elemental spells, sustained reading/music, slow sleep, idle variants, edge jump, hard landing and vortex travel.
- Added tiredness and minimum sleep duration; slowed the sleep loop and spaced one-shot spell casts.
- Sustained desktop activity poses, inward floor-edge recovery and stalled-movement vortex watchdog.
- Expanded model, asset, installer and real offscreen Quickshell checks; refreshed screenshots and reproducible package.

# Changelog

## 0.7.0 — 2026-09-20

- Home now has Feed, Sleep/Wake and Go explore/Come home. Automatic activity reactions replace manual hobby buttons.
- Activities tab shows current activity, growth targets, fatigue, reward progress, five lifetime attributes, editable mappings and custom app classifications.
- Active-app, media-playback and five-minute idle signals; rewards require 30 continuous eligible seconds.
- New supplied reading, music, eating, sleep/wake, four elemental spells and vortex animations. Activity poses wait for safe surfaces.
- Automatic sleep/wake, fatigue/fullness multipliers, Health and care-only Affection.
- Sprite-only bar icon changes from Egg to Slime with stage. No Omachi text label.
- Automatic v0.5 save migration preserves pet progress and legacy Calm, leaving the old save untouched.
- Safer one-command installer, focused model/UI/migration checks and updated documentation.


## 0.5.0 — 2026-09-19

Fresh Phase A+B single-player implementation from the earlier v0.1/v0.2 concept.

- Persistent versioned state, bounded offline updates, atomic writes and visible save failures.
- Egg incubation and complete shake/crack/hatch transition to Slime.
- Ten original source sheets, reproducible crops, normalized RGBA sheets and pack metadata.
- Care room, manual activities, application-class reactions and growth traits.
- Click-through roaming overlay, window filtering and eight movement states.
- No multiplayer in the active runtime; pure model/controller boundaries for future extension.
- Deterministic model tests, PNG/provenance checks and isolated Quickshell save/render tests.

Earlier release source archives were unavailable; v0.5 does not claim binary/save compatibility. It leaves earlier saves alone. Dedicated activity art and real-desktop smoke testing remain documented limitations.
