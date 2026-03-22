# ec2-guide

Practical EC2 workflows for people who want simple, repeatable daily usage rather than a broad AWS tour.

The core idea is:

- EC2 instances are disposable compute
- one EBS volume holds your durable workspace
- scripts should make the safe path easier, not hide important decisions

This repository pairs explanation with execution:

- `docs/` explains the workflow and tradeoffs
- `scripts/` provides small shell helpers
- `examples/` shows the minimum config you can adapt locally

## Repository Shape

```text
ec2-guide/
├── docs/
│   ├── index.md
│   ├── guides/
│   │   ├── disposable-ec2-persistent-ebs.md
│   │   ├── first-time-setup.md
│   │   ├── daily-workflow.md
│   │   └── storage-and-safety.md
│   └── reference/
│       ├── configuration.md
│       └── script-philosophy.md
├── scripts/
│   ├── create-volume.sh
│   ├── format-volume.sh
│   ├── launch-and-attach.sh
│   └── mount-ebs.sh
└── examples/
    └── ec2.env.example
```

## Workflow At A Glance

1. Create one persistent EBS volume
2. Attach it to a temporary EC2 instance once and format it
3. For daily use, launch a new instance and attach the same volume
4. Mount the volume safely inside the instance
5. Stop or terminate the instance when you are done

## Where The Scripts Run

- `create-volume.sh` and `launch-and-attach.sh` run on your local machine
- `format-volume.sh` and `mount-ebs.sh` run inside the EC2 instance, usually with `sudo`

In practice, keep a copy of this repo available both locally and inside the instance, or copy the needed scripts over.

## Principles

- Keep durable state off the instance root disk
- Make destructive operations explicit and rare
- Parameterize account-specific details instead of hardcoding them
- Prefer a few understandable scripts over a large framework

## Status

This is currently a drafted public repo inside the private workspace while the structure and messaging are being refined.
