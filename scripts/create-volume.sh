#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${SCRIPT_DIR}/_common.sh"

ENV_FILE=""
OPT_PROFILE=""
OPT_REGION=""
OPT_AZ=""
OPT_SIZE_GB=""
OPT_VOLUME_TYPE=""
OPT_NAME=""
ENCRYPTED=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    --profile)
      OPT_PROFILE="$2"
      shift 2
      ;;
    --region)
      OPT_REGION="$2"
      shift 2
      ;;
    --availability-zone|--az)
      OPT_AZ="$2"
      shift 2
      ;;
    --size-gb)
      OPT_SIZE_GB="$2"
      shift 2
      ;;
    --type)
      OPT_VOLUME_TYPE="$2"
      shift 2
      ;;
    --name)
      OPT_NAME="$2"
      shift 2
      ;;
    --encrypted)
      ENCRYPTED=1
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage: create-volume.sh [options]

Options:
  --env-file PATH
  --profile NAME
  --region REGION
  --availability-zone AZ
  --size-gb N
  --type TYPE
  --name NAME
  --encrypted
EOF
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

load_env_file "${ENV_FILE}"
require_cmd aws

AWS_PROFILE="${OPT_PROFILE:-${AWS_PROFILE:-}}"
AWS_REGION="${OPT_REGION:-${AWS_REGION:-}}"
AVAILABILITY_ZONE="${OPT_AZ:-${AVAILABILITY_ZONE:-}}"
SIZE_GB="${OPT_SIZE_GB:-${VOLUME_SIZE_GB:-}}"
VOLUME_TYPE="${OPT_VOLUME_TYPE:-${VOLUME_TYPE:-gp3}}"
NAME="${OPT_NAME:-${VOLUME_NAME:-}}"

[[ -n "${AWS_REGION:-}" ]] || die "AWS_REGION is required"
[[ -n "${AVAILABILITY_ZONE:-}" ]] || die "AVAILABILITY_ZONE is required"
[[ -n "${SIZE_GB:-}" ]] || die "Volume size is required"
[[ -n "${NAME:-}" ]] || die "Volume name is required"

AWS_ARGS=()
aws_args_from_env AWS_ARGS

CREATE_ARGS=(
  ec2 create-volume
  --availability-zone "${AVAILABILITY_ZONE}"
  --size "${SIZE_GB}"
  --volume-type "${VOLUME_TYPE}"
  --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=${NAME}}]"
  --query VolumeId
  --output text
)

if [[ "${ENCRYPTED}" -eq 1 ]]; then
  CREATE_ARGS+=(--encrypted)
fi

info "Creating volume '${NAME}' in ${AVAILABILITY_ZONE}"
VOLUME_ID=$(aws "${AWS_ARGS[@]}" "${CREATE_ARGS[@]}")

info "Waiting for volume ${VOLUME_ID} to become available"
aws "${AWS_ARGS[@]}" ec2 wait volume-available --volume-ids "${VOLUME_ID}"

echo
echo "Volume created successfully"
echo "  VolumeId          : ${VOLUME_ID}"
echo "  Name              : ${NAME}"
echo "  AvailabilityZone  : ${AVAILABILITY_ZONE}"
echo "  SizeGiB           : ${SIZE_GB}"
echo "  VolumeType        : ${VOLUME_TYPE}"
