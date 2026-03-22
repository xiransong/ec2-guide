# EC2 Guide

This guide is for people who want a practical, repeatable EC2 workflow rather than a broad AWS tour.

The main pattern is simple:

- treat EC2 instances as temporary compute
- keep durable files on a persistent EBS volume
- use small scripts to make the workflow repeatable

## Start Here

1. Read [disposable-ec2-persistent-ebs.md](/Users/songxiran/code/banglab-aws-guide/ec2-guide/docs/guides/disposable-ec2-persistent-ebs.md)
2. Follow [first-time-setup.md](/Users/songxiran/code/banglab-aws-guide/ec2-guide/docs/guides/first-time-setup.md)
3. Reuse [daily-workflow.md](/Users/songxiran/code/banglab-aws-guide/ec2-guide/docs/guides/daily-workflow.md)
4. Keep [storage-and-safety.md](/Users/songxiran/code/banglab-aws-guide/ec2-guide/docs/guides/storage-and-safety.md) nearby

## Who This Is For

- researchers and engineers who use EC2 interactively
- people who want a stable personal workspace without keeping one instance alive forever
- users who are comfortable with the AWS CLI and basic shell commands

## What This Guide Tries To Avoid

- hiding every AWS concept behind wrappers
- mixing personal shell preferences into the core workflow
- encouraging expensive idle instances
