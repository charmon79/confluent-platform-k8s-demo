#!/bin/sh

#CFK cluster name
export CLUSTER=<name>

# The AWS region where you want to create your EKS in
export REGION=<region>

# Your email address
export EMAIL=<email>

# Your mame
export NAME=<your name>

# Reason why you are setting up cluster
export REASON="CFK testing/demo"

# Create a PEM keypair in AWS->EC2->Network&Security->KeyPairs
# Make sure to use the tag "owner_email: <email_id>" when creating the keypair
# The name of the keypair is as it appears in the Key pairs list on AWS console
# More details on PEM keypair can be found in the link https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html
export AWS_KEY_PAIR=<keypair name>

# IAM Role name for attaching the EBS policy; you can just make one up, any random name
export ROLE_NAME=<yourname-cfk-test-AmazonEKS_EBS_CSI_DriverRole>

# This is the AWS account ID
export AWS_ACCOUNT_ID=<account id>