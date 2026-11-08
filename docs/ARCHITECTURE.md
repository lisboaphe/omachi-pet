# Architecture (v1.x)

`Service.qml` mounts a single authoritative `PetController`, plus the native room and roaming windows. The bar looks up only its own service through the Omarchy facade.

- `DesktopActivity.qml`: native Hyprland application class, MPRIS playback, Wayland IdleMonitor with a 300-second timeout. No window titles, keyboard logging or document reads.
- `game/Activities.js`: pure category detection, definitions, independent training overrides, fatigue multipliers and one 30-second reward. The default table matches the approved activity/attribute design. Gaming defaults to Adventure 0.6 + Power 0.4; other growth-bearing activities total 1 before fatigue.
- `game/PetState.js`: needs, bounded offline care, Egg → Slime lifecycle, essential actions and explicit schema 5 → 7 migration. Legacy Calm is retained separately.
- `game/Director.js`: lifecycle/event/sleep/activity/emotion animation selection. The overlay applies it at safe surfaces; midair/climbing physics finishes before activity poses or recall.
- `PetController.qml`: progression interval accounting, atomic state writes, user mapping methods, event durations, rotating spells, automatic sleep, and two-phase portal travel. Travel changes surface between portal_out and portal_in.
- `game/Movement.js` / `game/World.js`: existing deterministic feet-coordinate physics, platform validity, active workspace, overlap and fullscreen filtering.
- `ui/PetRoom.qml` / `ui/ActivityTab.qml`: three primary care actions, Home/Activities tabs, attribute balance and editable mappings/application rules.
- `ui/AnimatedPet.qml` / `assets/Pack.js`: local metadata-driven sprite loading, frame timing and explicit fallbacks. The compact bar magnifies the stage sprite, without a name label.

Save path: `$XDG_STATE_HOME/omachi-pet/pet-v7.json`, falling back to `~/.local/state/omachi-pet/pet-v7.json`. It is written atomically every 15 seconds and after rewards/settings/care. A missing v7 save falls back to the v5 file; an invalid v7 file blocks startup without silently falling back or overwriting either file. Malformed/future files are preserved.

Roaming uses monitor-local logical coordinates, not physical pixels. Reachable window sides must be within 36 logical pixels of the floor, with 90 pixels of top headroom. Covered window tops are conservatively omitted. A moving/disappearing support causes a fall. Activity poses pause only on stable states, retaining support checks; they cannot suspend a pet in midair.

No network module is imported or shipped. Future visitors should use a separate validated read-only snapshot adapter. They must never write the local pet or execute remote commands.

API references: [MPRIS players](https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.Mpris/Mpris/) and [atomic FileView saves](https://quickshell.org/docs/v0.2.1/types/Quickshell.Io/FileView/). Installed Quickshell type definitions were used for the local IdleMonitor interface.

## Attribute progression and v0.8 behavior

`game/Progression.js` derives level and within-level XP from each saved growth number. Threshold for level L is `5*(L-1)^2 + 20*(L-1)`; no new level counter can drift from XP. `GrowthTab` and `AttributeCard` render independent progress. Activities contains configuration, Home contains care.

Schema 7 is retained with optional sanitized tiredness/sleep-duration fields; absent fields get defaults. Minimum sleep is checked separately from animation completion. The renderer's loop clock does not reset when the activity detector refreshes without a category change. Gaming chooses a spell during a bounded window, then idle until the next cast.

Movement state stays independent of animation names: hard fall/land and edge jump select clips without replacing collision logic. A physical movement watchdog excludes paused and idle poses. Recovery uses portal travel on the overlay, resets position between phases and enforces a cooldown. It does not grant recall affection.

## v0.9 onboarding
`nameConfirmed` is an additive schema-7 field. Older saves prompt once without resetting care/growth. Controller ticks and training wait while naming is pending; unnamed saved Eggs do not age offline. `NameSetup.qml` uses the same background and pack renderer, and `PetState.setName` centralizes validation. Movement collision half-width remains 24px, while screen margins reserve 56px for the full overlay.

## Mana incubation and Egg presentation

`PetState.advance` separates real elapsed time from accelerated incubation. Only named, online, idle Eggs with a controller-approved hover boost can accelerate. Boost applies until age 240 of 300 seconds, with any remainder of that tick advancing normally. Lifecycle reveal timing uses real elapsed time. Optional sanitized schema-7 `manaCharged` defaults false and persists when the boost reaches the threshold.

`PetController.eggBoostActive` gates hover by panel visibility, naming, stage, phase and age. `EggHatching.qml` clears hover on exit, hiding, disabling or destruction. `PetState.eggAnimation` prioritizes crack/hatch over charged shaking and hover mana. `PetRoom` swaps the Egg view for Slime Home/Growth/Activities after hatching; only the shell background layer has 0.60 opacity.
