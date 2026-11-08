# Artwork provenance

Twenty PNG sheets were supplied in the “Create Omarchy Plugin” conversation for this project: ten existing Egg/Slime lifecycle/movement sources and ten new activity/action sources. Original bytes and names are retained in `source/`. Exact source hashes, crop boxes, normalization scales and derivative frame indices are in `crops.json`.

New sources: Slime_magic_Earth/Fire/Water/Wind.png, Slime_comingHome_Vortex.png, Slime_eating.png, Slime_Music.png, Slime_Reading.png, Slime_sleeping.png and Slime_walkingup.png (the last is the user's filename for waking up). Wind has 11 poses; the other elemental casts and vortex have 12. Reading/music/sleep/wake have 6; eating has 8.

Sleep_loop uses sleep frames 4–6. Portal_out uses vortex frames 1–6 and portal_in uses 7–12. Egg idle/shake remain derivatives of the intact cracking-sheet frame. Runtime sheets use transparent 96×96 canvases and nearest-neighbor scaling. New action poses preserve their source vertical offset relative to the shared baseline so the vortex ball does not drop to the floor.

Six extra ambient/emotion uploads were mentioned but not downloadable via the available conversation attachment interface. No substitute source images are invented: pet.json records the existing-pose fallbacks. New magic sheets contain some touching/overlapping particles; the reviewed column boundaries are explicit in the build tool.

The MIT license covers implementation and documentation. The owner authorized CC BY 4.0 for public artwork reuse on 2026-09-25. See `../ARTWORK-LICENSE.md` for attribution and AI-assisted provenance.

## v0.8
Ten newer source sheets from the referenced chat are retained here and imported by `tools/build_v8_sprites.py`. See `docs/SPRITE_PACK.md` and `art/crops.json` for row ordering, excluded labels, derived sleep/portal frames and missing-art limitations.

## Home background (v0.8.2)
`assets/backgrounds/home_grassy_lake.png` is an unchanged copy of the user-supplied `Background_Grassy_Field_Lake_Bigger.png` (700×370). The Home image preserves the complete composition and aspect ratio. The larger 1725×912 alternative is not required in the runtime package.

## v0.9.2 Egg replacement
`EGG_shaking.png` and `EGG_hatching.png` are copied unchanged from the user's New Sprites/EGG folder. The runtime uses these in place of the older Egg clips; older source files remain only for reproducible base-pack history. The new importer records all crop boxes and source frame indices and creates `docs/egg-contact.png`.

## v0.10 mana, walking and Happy

Four additional original sheets were copied unchanged from the user's New Sprites folders: `EGG_Mana.png`, `EGG_shaking_mana.png`, `Slime_Action_Roaming.png`, and `Slime_Happy.png`. `tools/build_mana_sprites.py` performs the final overrides, records hashes/crops/scales in `crops.json`, and generates mana and Slime contact sheets. Runtime frames retain a common 96×96 canvas and [48,90] anchor. The original mana backgrounds/alpha are handled by the documented crop and alpha threshold; original source bytes remain intact.

## Derived mood sheets

`slime/sad.png` and `slime/tired.png` are generated from the supplied idle sheet by `tools/build_mood_sprites.lua` (Aseprite): worried brows, a sliding tear and a greyer, deflated body for Sad; half-closed lids, a sweat drop and a flatter body for Tired. They reuse the original palette, outline and breathing motion, and no new source art was added.
