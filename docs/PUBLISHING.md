# v1.0 publishing preparation

Source: https://plugins.omarchy.org/publish.html (checked 2026-09-25).
Submission form: https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml

## Repository layout

Publish the contents of this `omachi-pet` folder as the repository root. Do not upload the parent ChatGPT project, old releases, personal state/configuration or local installation backups. `manifest.json`, `README.md` and `LICENSE` must sit at the root. Keep plugin id `community.omachi-pet` to preserve installed identity.

## Pending decisions and acceptance

- Public GitHub repository URL. Default credit is Omachi Pet contributors.
- Artwork reuse permission confirmed by the owner on 2026-09-25; CC BY 4.0 notice included. Code remains MIT.
- On the actual Omarchy desktop: verify fresh install after uninstall, update an existing installation, close/reopen panel, persist/reload a pet, hover Egg until the final minute, complete hatch, Feed/Play/Sleep, activity XP, roam/edge/climb/pull-up/jump/fall/land, recall, fullscreen behavior, and removal without loss of the save. Mixed-scale monitor support remains unverified.
- Review final author/license metadata and README, then create the v1.0.0 tag/release and submit the repository.

## Prepared listing values

Name: Omachi Pet
Category: Desktop
Tags: Games, Quickshell, Hyprland
Repository: pending owner input
Description: A single-player Egg and Slime desktop companion with mana hatching, pet care, activity-driven attributes and roaming.

Maintainer notes: QML plugin for the Omarchy Quickshell shell, with service and bar-widget entrypoints. Requires the native Hyprland, MPRIS and Wayland idle interfaces. Runtime uses a local mkdir command and local atomic saves; no network requests, telemetry or multiplayer. Source includes install/update with backups, native removal instructions and reproducible sprite import tools. Node and Python are test/build dependencies; Pillow is only needed for sprite rebuilds and compositing tests. Installation explicitly enables the plugin and restarts the shell; no unrelated configuration is overwritten.

The marketplace checks the current repository commit and a maintainer approves the listing. Approval is not a security audit. Submit only after the pending permission and repository facts can be answered truthfully.
