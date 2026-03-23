#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${SCRIPT_DIR}/_common.sh"

ENV_FILE=""
MODE="launch"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    --mode)
      MODE="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: validate-config.sh --env-file PATH [options]

Options:
  --mode MODE   One of: create, launch, mount. Default: launch
EOF
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

[[ -n "${ENV_FILE}" ]] || die "--env-file is required"
load_env_file "${ENV_FILE}"

require_var() {
  local var_name="$1"
  if [[ -z "${!var_name:-}" ]]; then
    die "Missing required variable: ${var_name}"
  fi
}

case "${MODE}" in
  create)
    require_var AWS_REGION
    require_var AVAILABILITY_ZONE
    require_var VOLUME_SIZE_GB
    require_var VOLUME_NAME
    ;;
  launch)
    require_var AWS_REGION
    require_var AMI_ID
    require_var KEY_NAME
    require_var SECURITY_GROUP_ID
    require_var INSTANCE_TYPE
    require_var ROOT_SIZE_GB
    ;;
  mount)
    require_var MOUNT_POINT
    ;;
  *)
    die "Unsupported mode '${MODE}'. Expected one of: create, launch, mount"
    ;;
esac

echo "Configuration looks usable"
echo "  Env file          : ${ENV_FILE}"
echo "  Mode              : ${MODE}"
echo "  AWS_PROFILE       : ${AWS_PROFILE:-<unset>}"
echo "  AWS_REGION        : ${AWS_REGION:-<unset>}"
echo "  AVAILABILITY_ZONE : ${AVAILABILITY_ZONE:-<unset>}"
echo "  AMI_ID            : ${AMI_ID:-<unset>}"
echo "  KEY_NAME          : ${KEY_NAME:-<unset>}"
echo "  SECURITY_GROUP_ID : ${SECURITY_GROUP_ID:-<unset>}"
echo "  INSTANCE_TYPE     : ${INSTANCE_TYPE:-<unset>}"
echo "  ROOT_SIZE_GB      : ${ROOT_SIZE_GB:-<unset>}"
echo "  VOLUME_SIZE_GB    : ${VOLUME_SIZE_GB:-<unset>}"
echo "  VOLUME_NAME       : ${VOLUME_NAME:-<unset>}"
echo "  MOUNT_POINT       : ${MOUNT_POINT:-<unset>}"
echo "  WORKSPACE_DIRS    : ${WORKSPACE_DIRS:-<unset>}"
