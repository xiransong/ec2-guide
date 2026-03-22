#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${SCRIPT_DIR}/_common.sh"

ENV_FILE=""
OPT_PROFILE=""
OPT_REGION=""
OPT_AZ=""
OPT_AMI_ID=""
OPT_INSTANCE_TYPE=""
OPT_KEY_NAME=""
OPT_SECURITY_GROUP_ID=""
OPT_SUBNET_ID=""
OPT_ROOT_SIZE_GB=""
OPT_INSTANCE_NAME=""
OPT_VOLUME_ID=""
OPT_DEVICE_NAME=""
DEVICE_NAME="/dev/sdf"

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
    --ami-id)
      OPT_AMI_ID="$2"
      shift 2
      ;;
    --instance-type)
      OPT_INSTANCE_TYPE="$2"
      shift 2
      ;;
    --key-name)
      OPT_KEY_NAME="$2"
      shift 2
      ;;
    --security-group-id)
      OPT_SECURITY_GROUP_ID="$2"
      shift 2
      ;;
    --subnet-id)
      OPT_SUBNET_ID="$2"
      shift 2
      ;;
    --root-size-gb)
      OPT_ROOT_SIZE_GB="$2"
      shift 2
      ;;
    --instance-name)
      OPT_INSTANCE_NAME="$2"
      shift 2
      ;;
    --volume-id)
      OPT_VOLUME_ID="$2"
      shift 2
      ;;
    --device-name)
      OPT_DEVICE_NAME="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: launch-and-attach.sh --volume-id vol-... [options]

Options:
  --env-file PATH
  --profile NAME
  --region REGION
  --availability-zone AZ
  --ami-id AMI
  --instance-type TYPE
  --key-name NAME
  --security-group-id SG
  --subnet-id SUBNET
  --root-size-gb N
  --instance-name NAME
  --device-name NAME   Default: /dev/sdf
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
AMI_ID="${OPT_AMI_ID:-${AMI_ID:-}}"
INSTANCE_TYPE="${OPT_INSTANCE_TYPE:-${INSTANCE_TYPE:-}}"
KEY_NAME="${OPT_KEY_NAME:-${KEY_NAME:-}}"
SECURITY_GROUP_ID="${OPT_SECURITY_GROUP_ID:-${SECURITY_GROUP_ID:-}}"
SUBNET_ID="${OPT_SUBNET_ID:-${SUBNET_ID:-}}"
ROOT_SIZE_GB="${OPT_ROOT_SIZE_GB:-${ROOT_SIZE_GB:-50}}"
INSTANCE_NAME="${OPT_INSTANCE_NAME:-${INSTANCE_NAME:-work-instance}}"
VOLUME_ID="${OPT_VOLUME_ID:-${VOLUME_ID:-}}"
DEVICE_NAME="${OPT_DEVICE_NAME:-${DEVICE_NAME:-/dev/sdf}}"

[[ -n "${VOLUME_ID}" ]] || die "--volume-id is required"
[[ -n "${AWS_REGION:-}" ]] || die "AWS_REGION is required"
[[ -n "${AMI_ID:-}" ]] || die "AMI_ID is required"
[[ -n "${INSTANCE_TYPE:-}" ]] || die "INSTANCE_TYPE is required"
[[ -n "${KEY_NAME:-}" ]] || die "KEY_NAME is required"
[[ -n "${SECURITY_GROUP_ID:-}" ]] || die "SECURITY_GROUP_ID is required"

AWS_ARGS=()
aws_args_from_env AWS_ARGS

RUN_ARGS=(
  ec2 run-instances
  --image-id "${AMI_ID}"
  --instance-type "${INSTANCE_TYPE}"
  --key-name "${KEY_NAME}"
  --security-group-ids "${SECURITY_GROUP_ID}"
  --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":${ROOT_SIZE_GB},\"VolumeType\":\"gp3\",\"DeleteOnTermination\":true}}]"
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${INSTANCE_NAME}}]"
  --query 'Instances[0].InstanceId'
  --output text
)

if [[ -n "${AVAILABILITY_ZONE:-}" ]]; then
  RUN_ARGS+=(--placement "AvailabilityZone=${AVAILABILITY_ZONE}")
fi

if [[ -n "${SUBNET_ID:-}" ]]; then
  RUN_ARGS+=(--subnet-id "${SUBNET_ID}")
fi

info "Launching instance '${INSTANCE_NAME}'"
INSTANCE_ID=$(aws "${AWS_ARGS[@]}" "${RUN_ARGS[@]}")

info "Waiting for instance ${INSTANCE_ID} to be running"
aws "${AWS_ARGS[@]}" ec2 wait instance-running --instance-ids "${INSTANCE_ID}"

info "Attaching ${VOLUME_ID} to ${INSTANCE_ID} as ${DEVICE_NAME}"
aws "${AWS_ARGS[@]}" ec2 attach-volume \
  --volume-id "${VOLUME_ID}" \
  --instance-id "${INSTANCE_ID}" \
  --device "${DEVICE_NAME}" >/dev/null

aws "${AWS_ARGS[@]}" ec2 wait volume-in-use --volume-ids "${VOLUME_ID}"

PUBLIC_IP=$(aws "${AWS_ARGS[@]}" ec2 describe-instances \
  --instance-ids "${INSTANCE_ID}" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo
echo "Instance launched and volume attached"
echo "  InstanceId    : ${INSTANCE_ID}"
echo "  PublicIp      : ${PUBLIC_IP}"
echo "  VolumeId      : ${VOLUME_ID}"
echo "  DeviceName    : ${DEVICE_NAME}"
echo "  InstanceName  : ${INSTANCE_NAME}"
