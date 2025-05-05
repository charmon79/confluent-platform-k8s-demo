#!/bin/sh

# Check if gp2 storage class exists and remove default annotation if it does
if kubectl get storageclass gp2 &> /dev/null; then
  echo "Removing default annotation from existing gp2 StorageClass"
  kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
fi

# Create EBS CSI storage class and set it as default
cat <<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ebs-sc
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp2
  fsType: ext4
EOF

echo "Created default StorageClass using EBS CSI driver"