# Sprite-pack format v1

The default pack lives in `assets/pets/slime-default/pet.json`. All files are local; remote URLs and path traversal are rejected. To customize this build, replace its pack files and metadata, then run the tests. A pack picker and external-folder imports are not included yet.

Each animation has `file`, `frames`, `rows`, `frameWidth`, `frameHeight`, `anchor`, `durations` in milliseconds, and `loop`. Runtime uses 96×96 RGBA frames and the bottom-center anchor `[48,90]`. `frames` means frames per row. `rows` is normally 1. The v0.10 walking clip faces right and mirrors for leftward movement; it has no directional row map.

Required: `egg/idle`, `egg/shake`, `egg/crack`, `egg/hatch`; `slime/idle`, `slime/roam`, `slime/edge_look`, `slime/climb`, `slime/pull_up`, `slime/jump`, `slime/fall`, `slime/land`.

`fallbacks` maps a missing activity directly to an existing animation. No fallback chains. One-shot animations hold their final frame; loops use their total duration. The current hatch contains 24 frames totaling 3720 ms, including a final 500 ms hold. The state machine advances at the end of the reveal.

Rebuild from the preserved original PNGs:

```bash
python3 -m pip install Pillow  # build environment only, if needed
python3 tools/build_mana_sprites.py
```

The script detects alpha whitespace, keeps detached shell pieces/droplets with their nearest pose by ranking inter-pose gaps, crops poses, uses one scale per animation, then aligns their contact anchors. It records the exact crop rectangles and source hashes. Jump/pull-up vertical travel comes from physics, not blank space in the source sheets. Review `docs/sprite-contact.png` after changing artwork. This importer is tuned to the included sheets; new presentation layouts should be inspected before importing.


v0.7 adds direct sheets for `read`, `listen_music`, `eat`, `sleep_enter`, `wake_up`, `cast_fire`, `cast_water`, `cast_wind`, `cast_earth` and `come_home`. Wind has 11 frames; the other casts and vortex have 12. `sleep_loop`, `portal_out` and `portal_in` derive from explicit index lists. New action sheets use reviewed per-frame x boundaries and preserve vertical source offsets; see `CUTS` in the importer. Close or overlapping particles cannot be perfectly separated by whitespace alone.

Stage icons use the actual `egg/idle` or `slime/idle` sheet, cropped more tightly for legibility in the bar. Every gameplay surface still uses the pack timing and pose metadata. Painting and some emotions remain explicit fallbacks until their source sheets are available.

## v0.8 overrides

The v0.8 builder first reconstructs the base pack, then imports ten newer source sheets. Multi-row reading, music and eating sheets flatten in reading order; printed frame numbers are excluded by explicit vertical limits. Each casting row is a separate 13-frame one-shot, including Arcane. Vortex is 20 frames split into 12 out / 8 in; durations total 1.08 seconds per half. Sleep entry is eight frames at 300 ms; the final two frames provide the temporary 900 ms/frame sleep loop. Dedicated sleep/tired loop files were inaccessible. The grassy-lake background was supplied separately and added in v0.8.2. No source is silently substituted without provenance.

`docs/v8-sprite-contact.png` shows the final overrides; `art/crops.json` records every source crop and hash. Particle effects touching neighboring frames can retain small source-edge artifacts.

## v0.9.2 Egg import
The new 10×4 hatch source uses reviewed row boundaries (0/310/550/790/1024) and a shared frame scale. The shake source has six columns. Transparent export noise below alpha 32 is removed; images are normalized to 96×96 with feet at y=90. Every crop, source hash and original frame index is recorded in `art/crops.json`. Idle uses original indices 0–3, crack 4–15 and hatch 16–39. The shake phase runs two 900ms cycles; crack is 1440ms; hatch is 3720ms.

## v0.10 mana and Slime overrides

The final builder reconstructs the earlier packs, then imports `EGG_Mana.png` (20 frames at 130 ms, looping), `EGG_shaking_mana.png` (10 at 180 ms, looping), `Slime_Action_Roaming.png` (5 at 150 ms, looping), and `Slime_Happy.png` (10 at 160 ms, one-shot). Happy now resolves directly, with its old fallback removed. Mana keys are `egg/mana` and `egg/shake_mana`. See `docs/mana-contact.png` and `docs/new-slime-contact.png` for the final crops.
