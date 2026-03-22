# Disposable EC2, Persistent EBS

This is the central idea behind the guide.

## The Model

Instead of treating one EC2 instance as your forever machine, split the problem in two:

- EC2 instance: temporary compute
- EBS volume: durable workspace

Your code, environments, data staging area, and outputs that need to persist should live on the EBS volume.

The instance itself should be easy to stop, replace, resize, or terminate.

## Why This Model Is Useful

- you can change instance type without rebuilding your entire workspace
- accidental instance termination is much less painful
- cost control becomes easier because you are less tempted to keep one large machine running forever
- storage decisions become more explicit

## The Tradeoff

This pattern is not magic.

You still need to understand:

- which disk is temporary and which one is durable
- when a volume is blank and needs formatting
- how to mount the correct device safely

That is why this repo keeps destructive actions separate from daily actions.

## One-Time Versus Daily Actions

One-time actions:

- create a volume
- format that volume

Daily or frequent actions:

- launch a new instance
- attach the existing volume
- mount it
- stop or terminate the instance when finished

## Supporting Scripts

- `scripts/create-volume.sh`
- `scripts/format-volume.sh`
- `scripts/launch-and-attach.sh`
- `scripts/mount-ebs.sh`
