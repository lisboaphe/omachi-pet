# v1.0.0 preparation validation — 2026-09-25

Passed in this release directory:
- 38 model tests.
- Four asset/installer checks, including fresh install, update backup, delayed registration and rollback.
- Eight real offscreen Quickshell scenarios.
- Dedicated real QML mana/hover/hatching/persistence scenario.
- QML compositing check for 40% desktop transmission.
- Omarchy manifest validation and archive integrity.

Runtime previews were regenerated for v1.0.0. These isolated checks do not verify the actual desktop compositor. Fresh install/update on the user's live shell and desktop climbing/fullscreen/mixed-monitor behavior still require acceptance before announcing stable v1.0. There is no completed independent security audit or marketplace approval.
