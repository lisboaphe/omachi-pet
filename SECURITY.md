# Security and privacy

Omachi Pet has no networking code, telemetry, remote assets, account system or peer discovery. Native Quickshell/Hyprland IPC is used for local desktop integration. Focus tracking reads application class only; MPRIS reads playback status, and a Wayland idle notification pauses rewards after five minutes without input. It never reads titles, browser history, document contents or keystrokes. Disable App reactions in the room to stop this sampling. Window geometry is sampled only while roaming.

The sole command launched by the running plugin is `mkdir -p` with an argument array for the local state directory. There are no shell-evaluated strings, privilege escalation, install hooks or downloads. Saves use atomic replacement and reject unsupported/corrupt state without overwriting it. PNG paths in metadata are constrained to the local pack.

Like other Omarchy shell plugins, the code runs with the desktop user's privileges inside Quickshell. This is an inspectable design, not a claim of sandbox isolation or a completed security audit. Report reproducible defects to the project maintainer with version and a minimal reproduction; omit private files and window contents.

The user-run installer copies local plugin files, backs up a previous plugin outside the discovery path and calls the Omarchy lifecycle commands. It does not change pet saves or install dependencies.
