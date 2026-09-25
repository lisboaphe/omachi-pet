#!/usr/bin/env bash
# Run from any directory with: bash /path/to/omachi-pet/install.sh
set -euo pipefail
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
plugin_id=community.omachi-pet
config_root="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy"
destination="$config_root/plugins/$plugin_id"
backup_root="${XDG_DATA_HOME:-$HOME/.local/share}/omachi-pet/plugin-backups"
for executable in omarchy omarchy-shell; do
  command -v "$executable" >/dev/null || { echo "Missing $executable. Run this on your Omarchy desktop."; exit 1; }
done
section=''
while (( $# )); do
  case "$1" in
    --section)
      [[ $# -ge 2 ]] || { echo 'Usage: install.sh [--section left|middle|right]' >&2; exit 1; }
      section="$2"; shift 2 ;;
    -h|--help) echo 'Usage: install.sh [--section left|middle|right]'; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done
[[ "$section" != middle ]] || section=center
case "$section" in ''|left|center|right) ;; *) echo 'Choose left, middle, or right.' >&2; exit 1 ;; esac
if [[ -z "$section" && -t 0 ]]; then
  if [[ -e "$destination" ]]; then
    default_choice='keep current position'
  else
    default_choice='right'
  fi
  printf 'Taskbar position: 1) Left  2) Middle  3) Right [Enter: %s]: ' "$default_choice"
  read -r choice
  case "$choice" in
    1|left) section=left ;;
    2|middle|center) section=center ;;
    3|right) section=right ;;
    '') ;;
    *) echo 'Invalid choice. Run again and choose 1, 2, or 3.' >&2; exit 1 ;;
  esac
fi
if [[ -z "$section" && ! -e "$destination" ]]; then section=right; fi
omarchy plugin validate "$source_dir"
mkdir -p "$config_root/plugins" "$backup_root"
staging=$(mktemp -d "$config_root/.omachi-install.XXXXXX")
# Registry rescans are asynchronous. Retry only the transient unknown-id error.
plugin_action() {
  local action="$1" output attempt
  shift
  for ((attempt=0; attempt<40; attempt++)); do
    if output=$(omarchy plugin "$action" "$plugin_id" "$@" 2>&1); then
      printf '%s\n' "$output"
      return 0
    fi
    if [[ "$output" != *"is not known"* ]]; then
      printf '%s\n' "$output" >&2
      return 1
    fi
    omarchy-shell shell rescanPlugins || return 1
    sleep 0.25
  done
  printf '%s\n' "$output" >&2
  echo 'Plugin discovery did not finish within 10 seconds.' >&2
  return 1
}
backup=''
operation=install
replacement_started=false
cleanup() {
  code=$?
  if [ "$code" -ne 0 ] && [ "$replacement_started" = true ]; then
    if [ -d "$destination" ]; then mv "$destination" "$backup_root/failed-$(date +%Y%m%d-%H%M%S)-$$"; fi
    if [ -n "$backup" ] && [ -d "$backup" ]; then
      mv "$backup" "$destination"
      omarchy-shell shell rescanPlugins || true
      plugin_action enable || true
    fi
    if [ -n "$backup" ]; then
      echo 'Update did not finish. The previous plugin was restored when available.'
    else
      echo 'Installation did not finish. Failed files were saved in the plugin backup folder.'
    fi
  fi
  if [ -d "$staging" ]; then rm -rf -- "$staging"; fi
}
trap cleanup EXIT
cp -a "$source_dir/." "$staging/"
omarchy plugin validate "$staging"
if [ -e "$destination" ]; then
  operation=update
  echo "Existing Omachi Pet found. Updating to v1.0.0 with a backup..."
  omarchy-shell shell rescanPlugins
  plugin_action disable
  backup="$backup_root/v0.8-upgrade-$(date +%Y%m%d-%H%M%S)-$$"
  mv "$destination" "$backup"
else
  echo "Omachi Pet is not installed. Installing v1.0.0..."
fi
replacement_started=true
mv "$staging" "$destination"
omarchy-shell shell rescanPlugins
if [[ -n "$section" ]]; then
  plugin_action enable --section "$section"
else
  plugin_action enable
fi
replacement_started=false
# A process restart releases QML components cached under the same plugin URL.
if ! omarchy restart shell; then
  echo 'Files updated, but shell restart failed. Run: omarchy restart shell' >&2
  exit 1
fi
if [ "$operation" = update ]; then
  echo 'Omachi Pet updated to v1.0.0. Your existing pet save is preserved.'
else
  echo 'Omachi Pet v1.0.0 installed. Any existing pet save is preserved.'
fi
if [ -n "$backup" ]; then printf 'Previous plugin: %s\n' "$backup"; fi
printf 'Click the pet sprite. Check that the panel shows v1.0.0.\n'
