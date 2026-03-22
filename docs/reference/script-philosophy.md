# Script Philosophy

These scripts are intentionally small and opinionated.

## What They Should Do

- parameterize account-specific details instead of hardcoding them
- be explicit about region, profile, AMI, instance type, and volume ID
- print the important identifiers users will need later
- be safe by default, especially around mounts and destructive operations

## What They Should Not Do

- silently format disks
- mix personal dotfiles or editor setup into the core path
- assume one organization's role names or billing model
- try to replace the AWS CLI entirely

## Design Bias

The repo favors shell scripts you can read in a few minutes.

That means:

- fewer abstractions
- clearer prompts
- explicit confirmation before dangerous actions
- a small number of stable scripts rather than a growing pile of convenience wrappers
