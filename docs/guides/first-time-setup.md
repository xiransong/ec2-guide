# First-Time Setup

This section covers the part you should only need to do once per persistent workspace volume.

Before starting, make sure the scripts in this repo are available:

- on your local machine for AWS CLI launch steps
- inside the EC2 instance for formatting and mounting steps

## 1. Create the Volume

Create a volume in the same availability zone where you expect to launch your instances.

Use:

```bash
./scripts/create-volume.sh --env-file ./examples/ec2.env.example --name my-workspace
```

The important output is the `VolumeId`.

Save it somewhere safe.

## 2. Attach It to an Instance

Launch a temporary EC2 instance and attach the new volume:

```bash
./scripts/launch-and-attach.sh \
  --env-file ./examples/ec2.env.example \
  --volume-id vol-xxxxxxxxxxxxxxxxx
```

The output should include:

- instance ID
- public IP
- attached volume ID

## 3. Format the Blank Volume Once

SSH into the instance and run:

```bash
sudo ./scripts/format-volume.sh --volume-id vol-xxxxxxxxxxxxxxxxx
```

Formatting is destructive and should be done exactly once for a brand new volume.

## 4. Mount It

Still inside the instance:

```bash
sudo ./scripts/mount-ebs.sh \
  --volume-id vol-xxxxxxxxxxxxxxxxx \
  --mount-point /home/ubuntu/workspace
```

At this point the volume is ready for day-to-day use.

## 5. End the Bootstrap Session

When formatting and mounting are complete, you can stop or terminate the temporary bootstrap instance.

The point is to keep the volume and discard the machine.
