#!/usr/bin/env bash

set -euo pipefail

die() {
  echo "[ERROR] $*" >&2
  exit 1
}

info() {
  echo "[INFO] $*"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

load_env_file() {
  local env_file="${1:-}"
  if [[ -z "${env_file}" ]]; then
    return 0
  fi
  [[ -f "${env_file}" ]] || die "Env file not found: ${env_file}"
  # shellcheck disable=SC1090
  source "${env_file}"
}

aws_args_from_env() {
  local -n out_ref="$1"
  out_ref=()
  if [[ -n "${AWS_REGION:-}" ]]; then
    out_ref+=(--region "${AWS_REGION}")
  fi
  if [[ -n "${AWS_PROFILE:-}" ]]; then
    out_ref+=(--profile "${AWS_PROFILE}")
  fi
}

resolve_volume_device() {
  local volume_id="$1"
  local volume_id_nodash="${volume_id//-/}"
  local matches=""
  local by_id_link=""

  [[ -d /dev/disk/by-id ]] || die "/dev/disk/by-id does not exist on this system"

  matches=$(find /dev/disk/by-id -maxdepth 1 -type l \
    | sed 's#.*/##' \
    | grep "nvme-Amazon_Elastic_Block_Store_${volume_id_nodash}" || true)

  [[ -n "${matches}" ]] || die "No attached device found for volume ${volume_id}"

  by_id_link=$(echo "${matches}" | grep -v '_[0-9]\+$' | head -n 1 || true)
  if [[ -z "${by_id_link}" ]]; then
    by_id_link=$(echo "${matches}" | head -n 1)
  fi

  readlink -f "/dev/disk/by-id/${by_id_link}"
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    die "Please run this script with sudo or as root"
  fi
}
