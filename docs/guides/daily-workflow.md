# Daily Workflow

Once your workspace volume exists and has already been formatted, the daily loop is simple.

Keep this repo available:

- on your laptop for launch steps
- inside the instance for the mount step

## 1. Launch and Attach

From your laptop:

```bash
./scripts/validate-config.sh --env-file ./ec2.env.local --mode launch

./scripts/launch-and-attach.sh \
  --env-file ./ec2.env.local \
  --volume-id vol-xxxxxxxxxxxxxxxxx
```

## 2. SSH In

Use the printed public IP:

```bash
ssh -i ~/.ssh/your-key ubuntu@<PUBLIC_IP>
```

## 3. Mount the Volume

Inside the instance:

```bash
sudo ./scripts/mount-ebs.sh \
  --volume-id vol-xxxxxxxxxxxxxxxxx \
  --env-file ./ec2.env.local
```

If you did not copy the env file into the instance, use explicit mount arguments instead.

## 4. Work Normally

Keep durable files under the mounted workspace rather than on the instance root disk.

## 5. End the Session

When you are done:

- stop the instance if you expect to resume it soon
- terminate it if it was disposable compute

Your workspace stays on the EBS volume, not on the instance.
