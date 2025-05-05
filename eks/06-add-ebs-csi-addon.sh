#!/bin/sh

eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster $CLUSTER \
  --region $REGION \
  --service-account-role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/$ROLE_NAME \
  --force
