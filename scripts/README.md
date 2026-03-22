# Script Layout

The public repo keeps the script set small and opinionated.

## Core Scripts

- `create-volume.sh`: create and tag a persistent EBS volume
- `format-volume.sh`: one-time filesystem creation for a blank attached volume
- `launch-and-attach.sh`: launch an instance and attach an existing volume
- `mount-ebs.sh`: resolve, verify, and mount the attached volume safely

## Non-Goals

- personal dotfiles backup
- SSH private key persistence
- organization-specific permission logic
- editor-specific automation in the core path
