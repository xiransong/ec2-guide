# Configuration

The scripts in this repo accept explicit flags and can also load defaults from an env file.

## Example Env File

See:

- [Example Env File](example-env-file.md)

## Common Variables

- `AWS_PROFILE`
- `AWS_REGION`
- `AVAILABILITY_ZONE`
- `AMI_ID`
- `KEY_NAME`
- `SECURITY_GROUP_ID`
- `INSTANCE_TYPE`
- `ROOT_SIZE_GB`
- `VOLUME_SIZE_GB`
- `VOLUME_TYPE`
- `INSTANCE_NAME`
- `VOLUME_NAME`
- `MOUNT_POINT`
- `WORKSPACE_DIRS`

## Recommendation

Keep one small env file per workflow or account rather than editing scripts directly.

A good pattern is:

```bash
cp examples/ec2.env.example ec2.env.local
```

Then point scripts at it with:

```bash
--env-file ./ec2.env.local
```
