#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${SCRIPT_DIR}/_common.sh"

VOLUME_ID=""
FS_TYPE="ext4"
ASSUME_YES=0
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --volume-id)
      VOLUME_ID="$2"
      shift 2
      ;;
    --fs-type)
      FS_TYPE="$2"
      shift 2
      ;;
    --yes)
      ASSUME_YES=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage: format-volume.sh --volume-id vol-... [options]

Options:
  --fs-type TYPE   Default: ext4
  --yes            Skip the confirmation prompt
  --force          Allow formatting even if a filesystem is already detected
EOF
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

require_root
require_cmd lsblk
require_cmd readlink

[[ -n "${VOLUME_ID}" ]] || die "--volume-id is required"

REAL_DEVICE=$(resolve_volume_device "${VOLUME_ID}")
EXISTING_FSTYPE=$(lsblk -no FSTYPE "${REAL_DEVICE}" | head -n 1 | tr -d '[:space:]')

if [[ -n "${EXISTING_FSTYPE}" && "${FORCE}" -ne 1 ]]; then
  die "Device ${REAL_DEVICE} already has filesystem '${EXISTING_FSTYPE}'. Re-run with --force only if you are absolutely sure."
fi

require_cmd "mkfs.${FS_TYPE}"

echo "Dangerous operation"
echo "  Volume ID    : ${VOLUME_ID}"
echo "  Block device : ${REAL_DEVICE}"
echo "  Filesystem   : ${FS_TYPE}"
echo "  Existing FS  : ${EXISTING_FSTYPE:-<none>}"
echo
echo "All existing data on this device will be lost."

if [[ "${ASSUME_YES}" -ne 1 ]]; then
  read -r -p "Type FORMAT to continue: " CONFIRM
  [[ "${CONFIRM}" == "FORMAT" ]] || die "Aborted"
fi

info "Formatting ${REAL_DEVICE} as ${FS_TYPE}"
"mkfs.${FS_TYPE}" "${REAL_DEVICE}"

echo
echo "Volume formatted successfully"
echo "  Volume ID    : ${VOLUME_ID}"
echo "  Block device : ${REAL_DEVICE}"
echo "  Filesystem   : ${FS_TYPE}"
