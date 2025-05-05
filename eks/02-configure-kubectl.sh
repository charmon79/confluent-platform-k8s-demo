#!/bin/sh

aws eks --region $REGION update-kubeconfig --name $CLUSTER