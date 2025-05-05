#!/bin/sh

eksctl utils associate-iam-oidc-provider \
  --region $REGION \
  --cluster $CLUSTER \
  --approve
