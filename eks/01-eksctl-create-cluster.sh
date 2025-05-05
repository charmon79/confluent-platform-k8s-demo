#!/bin/sh

eksctl create cluster --name=$CLUSTER \
--region=$REGION \
--node-type=t3.medium \
--nodes=3 \
--ssh-access \
--ssh-public-key=$AWS_KEY_PAIR \
--tags "Owner_Email=$EMAIL,Owner_Name=$NAME,Reason=$REASON"
