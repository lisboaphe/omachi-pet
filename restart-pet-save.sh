#!/usr/bin/env bash
set -euo pipefail
plugin_id=community.omachi-pet
pet_state_root="${XDG_STATE_HOME:-$HOME/.local/state}"
pet_save_dir="$pet_state_root/omachi-pet"
command -v omarchy >/dev/null || { echo 'Run this on your Omarchy desktop.' >&2; exit 1; }
mkdir -p "$pet_state_root/omachi-pet-backups"
pet_backup_dir=$(mktemp -d "$pet_state_root/omachi-pet-backups/before-restart-$(date +%Y%m%d-%H%M%S)-XXXXXX")
omarchy plugin disable "$plugin_id"
trap 'omarchy plugin enable "$plugin_id" || true' EXIT
# Allow the unloaded controller to finish its final atomic save.
sleep 2
if [ -d "$pet_save_dir" ]; then
  mv -- "$pet_save_dir" "$pet_backup_dir/omachi-pet"
fi
omarchy plugin enable "$plugin_id"
trap - EXIT
printf '\nYour pet will start again as an Egg.\nPrevious saves: %s\n' "$pet_backup_dir"
