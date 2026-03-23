# EC2 Guide

This guide is for people who want a practical, repeatable EC2 workflow rather than a broad AWS tour.

The main pattern is simple:

- treat EC2 instances as temporary compute
- keep durable files on a persistent EBS volume
- use small scripts to make the workflow repeatable

## Start Here

1. Read [Disposable EC2, Persistent EBS](guides/disposable-ec2-persistent-ebs.md)
2. Follow [First-Time Setup](guides/first-time-setup.md)
3. Reuse [Daily Workflow](guides/daily-workflow.md)
4. Keep [Storage and Safety](guides/storage-and-safety.md) nearby

## Fastest Path

If you already understand the basic idea, the shortest useful path is:

1. Copy `examples/ec2.env.example` to `ec2.env.local`
2. Edit the values for your account
3. Run `./scripts/validate-config.sh --env-file ./ec2.env.local --mode launch`
4. Follow [First-Time Setup](guides/first-time-setup.md)

## Who This Is For

- researchers and engineers who use EC2 interactively
- people who want a stable personal workspace without keeping one instance alive forever
- users who are comfortable with the AWS CLI and basic shell commands

## What This Guide Tries To Avoid

- hiding every AWS concept behind wrappers
- mixing personal shell preferences into the core workflow
- encouraging expensive idle instances
