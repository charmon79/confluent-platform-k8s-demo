#!/bin/sh

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# check if EBS CSI Driver pods are running
# kubectl get pods -n kube-system | grep ebs