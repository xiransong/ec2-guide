# Storage and Safety

The workflow is simple, but it is only safe if you stay clear about which resources are temporary and which are durable.

## The Three Storage Buckets In Your Head

- instance root volume: temporary machine-local storage
- persistent EBS volume: durable workspace
- object storage such as S3: durable shared storage

Confusing these is the fastest way to lose work or waste money.

## Safety Rules

- format a volume only when you are certain it is new and blank
- keep the formatting step separate from daily mount logic
- verify the volume ID before mounting or formatting
- do not assume `/dev/sdf` is the final Linux device name on Nitro instances
- use `/dev/disk/by-id` resolution when possible

## Cost Rules

- avoid leaving large instances idle
- remember that EBS still costs money even when the instance is stopped
- delete volumes you truly no longer need

## Public Repo Boundary

This guide intentionally avoids personal shell persistence, private keys, and organization-specific access details.

Those can exist as optional extensions elsewhere, but they should not be part of the core public workflow.
