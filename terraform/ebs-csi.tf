# IAM Role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver" {
  name               = "${var.cluster_name}-ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name = "${var.cluster_name}-ebs-csi-driver-role"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

# EKS Add-on for EBS CSI Driver
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.35.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  tags = {
    Name = "${var.cluster_name}-ebs-csi-addon"
  }

  depends_on = [
    aws_eks_node_group.main,
    aws_iam_role_policy_attachment.ebs_csi_driver_policy
  ]
}

# StorageClass for EBS CSI Driver
resource "kubernetes_storage_class" "ebs_csi" {
  metadata {
    name = "ebs-csi-gp2"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type   = "gp2"
    fsType = "ext4"
  }

  depends_on = [
    aws_eks_addon.ebs_csi
  ]
}