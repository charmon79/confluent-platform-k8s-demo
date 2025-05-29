# AWS EKS Cluster with Terraform

This Terraform configuration provisions a complete AWS EKS cluster with the following components:

- VPC with public and private subnets across 2 availability zones
- EKS cluster with managed node group
- IAM OIDC provider for the cluster
- AWS EBS CSI driver with appropriate IAM roles
- Default StorageClass using GP2 volumes

## Required Files

Ensure all these files are in the same directory:

- [ ] `versions.tf` - Terraform and provider versions
- [ ] `providers.tf` - Provider configurations
- [ ] `variables.tf` - Input variables
- [ ] `data.tf` - Data sources
- [ ] `vpc.tf` - VPC and networking resources
- [ ] `main.tf` - EKS cluster and node group
- [ ] `oidc.tf` - OIDC provider
- [ ] `ebs-csi.tf` - EBS CSI driver configuration
- [ ] `outputs.tf` - Output values
- [ ] `scaling-scripts.sh` - Helper scripts (optional)

## Prerequisites

- Terraform >= 1.9.0
- AWS CLI configured with appropriate credentials
- kubectl installed (for cluster interaction)

## Usage

1. Validate your setup:
```bash
chmod +x validate-setup.sh
./validate-setup.sh
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the planned changes:
```bash
terraform plan -var="owner_email=your-email@example.com"
```

4. Apply the configuration:
```bash
terraform apply -var="owner_email=your-email@example.com"
```

5. Configure kubectl:
```bash
aws eks update-kubeconfig --region us-east-2 --name my-eks-cluster
```

Note: The `owner_email` variable is required and must be a valid email address. All AWS resources will be tagged with this email for ownership tracking.

## Configuration

The main configuration variables can be found in `variables.tf`. Key variables include:

- `owner_email`: **Required** - Email address of the resource owner (used for tagging)
- `aws_region`: AWS region for deployment (default: us-east-2)
- `cluster_name`: Name of the EKS cluster
- `cluster_version`: Kubernetes version
- `node_instance_types`: EC2 instance types for worker nodes
- `node_group_size`: Fixed number of nodes (no auto-scaling)

You can also create a `terraform.tfvars` file to set these values:
```hcl
owner_email = "your-email@example.com"
cluster_name = "my-production-cluster"
node_group_size = 3
environment = "prod"
```

## Manual Scaling

This cluster is configured for manual scaling only. To change the number of nodes:

1. **Option 1 - Using Terraform** (Recommended for tracking changes):
   ```bash
   terraform apply -var="node_group_size=4"
   ```

2. **Option 2 - Using AWS CLI** (Faster, but bypasses Terraform):
   ```bash
   aws eks update-nodegroup-config \
     --cluster-name my-eks-cluster \
     --nodegroup-name my-node-group \
     --scaling-config minSize=4,maxSize=4,desiredSize=4
   ```

3. **Option 3 - Using AWS Console**:
   - Navigate to EKS → Clusters → Your Cluster → Node Groups
   - Select your node group and click "Edit"
   - Update the desired size

Note: If you scale using AWS CLI or Console, Terraform will not override your changes due to the `lifecycle` configuration.

## Components

### Provider Configuration
- AWS provider with default tags including `owner-email`, `Environment`, and `Project`
- These tags are automatically applied to all AWS resources that support tagging

### VPC Configuration
- Creates a VPC with CIDR 10.0.0.0/16
- 2 private subnets for worker nodes
- 2 public subnets for load balancers
- NAT gateways for private subnet internet access

### EKS Cluster
- Managed Kubernetes control plane
- OIDC provider for IAM integration
- Cluster security group

### Node Group
- Managed node group with auto-scaling
- Configured with necessary IAM policies
- Deployed in private subnets

### EBS CSI Driver
- AWS EBS CSI driver addon
- IAM role with AmazonEBSCSIDriverPolicy
- Default StorageClass with GP2 volumes

## Outputs

After deployment, the following outputs are available:

- `cluster_id`: EKS cluster name
- `cluster_endpoint`: API server endpoint
- `cluster_certificate_authority_data`: CA certificate for cluster
- `kubectl_config`: Configuration details for kubectl

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Security Considerations

- The cluster endpoint is publicly accessible by default
- Worker nodes are in private subnets
- Security groups are automatically managed by EKS
- IRSA (IAM Roles for Service Accounts) is enabled via OIDC

## Troubleshooting

### EBS Volumes Not Provisioning
Ensure the EBS CSI driver addon is in ACTIVE state:
```bash
aws eks describe-addon --cluster-name my-eks-cluster --addon-name aws-ebs-csi-driver
```

### Node Group Issues
Check node group status:
```bash
aws eks describe-nodegroup --cluster-name my-eks-cluster --nodegroup-name my-node-group
```

## Common Terraform Validation Errors

### "Reference to undeclared resource" errors
This usually means a required file is missing or not in the correct directory. Ensure all files listed in the "Required Files" section are present in the same directory.

To debug:
```bash
# List all .tf files
ls -la *.tf

# Validate individual files
terraform validate -json | jq '.diagnostics[]'

# Check if data.tf exists and contains the required data sources
cat data.tf
```

### Required data sources
The configuration requires these data sources to be defined in `data.tf`:
- `data.aws_availability_zones.available`
- `data.aws_eks_cluster_auth.cluster`
- `data.tls_certificate.eks`
- `data.aws_iam_policy_document.assume_role_policy`

If any are missing, copy the complete `data.tf` file from the artifact above.