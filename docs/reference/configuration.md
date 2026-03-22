# Configuration

The scripts in this repo accept explicit flags and can also load defaults from an env file.

## Example Env File

See:

- [ec2.env.example](/Users/songxiran/code/banglab-aws-guide/ec2-guide/examples/ec2.env.example)

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
