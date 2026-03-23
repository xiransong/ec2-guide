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

## Quickstart

1. Copy the example config:

```bash
cp examples/ec2.env.example ec2.env.local
```

2. Edit `ec2.env.local` with your real values:

- `AWS_PROFILE`
- `AMI_ID`
- `KEY_NAME`
- `SECURITY_GROUP_ID`
- your preferred instance and volume settings

3. Validate the config before launching anything:

```bash
./scripts/validate-config.sh --env-file ./ec2.env.local --mode launch
```

4. Create a persistent volume:

```bash
./scripts/create-volume.sh --env-file ./ec2.env.local
```

5. Launch an instance and attach that volume:

```bash
./scripts/launch-and-attach.sh \
  --env-file ./ec2.env.local \
  --volume-id vol-xxxxxxxxxxxxxxxxx
```

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
- `validate-config.sh` runs on your local machine
- `format-volume.sh` and `mount-ebs.sh` run inside the EC2 instance, usually with `sudo`

In practice, keep a copy of this repo available both locally and inside the instance, or copy the needed scripts over.

## Principles

- Keep durable state off the instance root disk
- Make destructive operations explicit and rare
- Parameterize account-specific details instead of hardcoding them
- Prefer a few understandable scripts over a large framework

## Start Reading

- Guide index: [docs/index.md](docs/index.md)
- First-time setup: [docs/guides/first-time-setup.md](docs/guides/first-time-setup.md)
- Daily loop: [docs/guides/daily-workflow.md](docs/guides/daily-workflow.md)
- Configuration reference: [docs/reference/configuration.md](docs/reference/configuration.md)

## Docs Site

This repo now includes an `mkdocs.yml` and a GitHub Pages workflow.

The published site is intended to deploy from `main` via GitHub Actions.

For local preview:

```bash
python3 -m pip install -r requirements.txt
mkdocs serve
```

For a production build:

```bash
mkdocs build --strict
```
