#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${SCRIPT_DIR}/_common.sh"

ENV_FILE=""
OPT_MOUNT_POINT=""
OPT_OWNER_USER=""
OPT_OWNER_GROUP=""
OPT_WORKSPACE_DIRS=""
VOLUME_ID=""
MOUNT_POINT="${MOUNT_POINT:-/mnt/workspace}"
OWNER_USER="${SUDO_USER:-root}"
OWNER_GROUP="${OWNER_GROUP:-${OWNER_USER}}"
WORKSPACE_DIRS="${WORKSPACE_DIRS:-}"
ASSUME_YES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    --volume-id)
      VOLUME_ID="$2"
      shift 2
      ;;
    --mount-point)
      OPT_MOUNT_POINT="$2"
      shift 2
      ;;
    --owner-user)
      OPT_OWNER_USER="$2"
      shift 2
      ;;
    --owner-group)
      OPT_OWNER_GROUP="$2"
      shift 2
      ;;
    --workspace-dirs)
      OPT_WORKSPACE_DIRS="$2"
      shift 2
      ;;
    --yes)
      ASSUME_YES=1
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage: mount-ebs.sh --volume-id vol-... [options]

Options:
  --env-file PATH
  --mount-point PATH
  --owner-user USER
  --owner-group GROUP
  --workspace-dirs a,b,c
  --yes
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
require_cmd blkid
require_cmd mountpoint

load_env_file "${ENV_FILE:-}"
MOUNT_POINT="${OPT_MOUNT_POINT:-${MOUNT_POINT:-/mnt/workspace}}"
OWNER_USER="${OPT_OWNER_USER:-${OWNER_USER:-${SUDO_USER:-root}}}"
OWNER_GROUP="${OPT_OWNER_GROUP:-${OWNER_GROUP:-${OWNER_USER}}}"
WORKSPACE_DIRS="${OPT_WORKSPACE_DIRS:-${WORKSPACE_DIRS:-}}"
[[ -n "${VOLUME_ID}" ]] || die "--volume-id is required"

REAL_DEVICE=$(resolve_volume_device "${VOLUME_ID}")
FSTYPE=$(lsblk -no FSTYPE "${REAL_DEVICE}" | head -n 1 | tr -d '[:space:]')
UUID=$(blkid -s UUID -o value "${REAL_DEVICE}")

[[ -n "${FSTYPE}" ]] || die "No filesystem detected on ${REAL_DEVICE}. Did you format the volume yet?"
[[ -n "${UUID}" ]] || die "Could not determine UUID for ${REAL_DEVICE}"

echo "Mount plan"
echo "  Volume ID    : ${VOLUME_ID}"
echo "  Block device : ${REAL_DEVICE}"
echo "  Filesystem   : ${FSTYPE}"
echo "  UUID         : ${UUID}"
echo "  Mount point  : ${MOUNT_POINT}"
echo "  Owner        : ${OWNER_USER}:${OWNER_GROUP}"
if [[ -n "${WORKSPACE_DIRS}" ]]; then
  echo "  Workspace    : ${WORKSPACE_DIRS}"
fi

if [[ "${ASSUME_YES}" -ne 1 ]]; then
  read -r -p "Type MOUNT to continue: " CONFIRM
  [[ "${CONFIRM}" == "MOUNT" ]] || die "Aborted"
fi

mkdir -p "${MOUNT_POINT}"

if mountpoint -q "${MOUNT_POINT}"; then
  info "${MOUNT_POINT} is already mounted"
else
  mount "${REAL_DEVICE}" "${MOUNT_POINT}"
fi

if ! grep -q "${UUID}" /etc/fstab; then
  echo "UUID=${UUID} ${MOUNT_POINT} ${FSTYPE} defaults,nofail 0 2" >> /etc/fstab
fi

chown "${OWNER_USER}:${OWNER_GROUP}" "${MOUNT_POINT}"

if [[ -n "${WORKSPACE_DIRS}" ]]; then
  IFS=',' read -r -a dirs <<< "${WORKSPACE_DIRS}"
  for dir_name in "${dirs[@]}"; do
    [[ -n "${dir_name}" ]] || continue
    mkdir -p "${MOUNT_POINT}/${dir_name}"
    chown "${OWNER_USER}:${OWNER_GROUP}" "${MOUNT_POINT}/${dir_name}"
  done
fi

echo
echo "Volume mounted successfully"
echo "  Mount point : ${MOUNT_POINT}"
echo "  Device      : ${REAL_DEVICE}"
echo "  Filesystem  : ${FSTYPE}"
