#!/bin/bash

# Helper scripts for manual EKS node group scaling

# Get current node group size
get_current_size() {
    local cluster_name="${1:-my-eks-cluster}"
    local nodegroup_name="${2:-my-node-group}"

    aws eks describe-nodegroup \
        --cluster-name "$cluster_name" \
        --nodegroup-name "$nodegroup_name" \
        --query 'nodegroup.scalingConfig.desiredSize' \
        --output text
}

# Scale node group to specific size
scale_nodegroup() {
    local new_size="$1"
    local cluster_name="${2:-my-eks-cluster}"
    local nodegroup_name="${3:-my-node-group}"

    if [ -z "$new_size" ]; then
        echo "Usage: scale_nodegroup <new_size> [cluster_name] [nodegroup_name]"
        return 1
    fi

    echo "Current size: $(get_current_size "$cluster_name" "$nodegroup_name")"
    echo "Scaling to: $new_size"

    aws eks update-nodegroup-config \
        --cluster-name "$cluster_name" \
        --nodegroup-name "$nodegroup_name" \
        --scaling-config minSize="$new_size",maxSize="$new_size",desiredSize="$new_size"

    echo "Scaling initiated. Monitor progress with: watch_scaling $cluster_name $nodegroup_name"
}

# Watch scaling progress
watch_scaling() {
    local cluster_name="${1:-my-eks-cluster}"
    local nodegroup_name="${2:-my-node-group}"

    watch -n 5 "aws eks describe-nodegroup \
        --cluster-name $cluster_name \
        --nodegroup-name $nodegroup_name \
        --query 'nodegroup.{Status:status,Desired:scalingConfig.desiredSize,Current:resources.autoScalingGroups[0].desiredCapacity}' \
        --output table"
}

# List all nodes with their status
list_nodes() {
    kubectl get nodes -o custom-columns=\
NAME:.metadata.name,\
STATUS:.status.conditions[?@.type==\'Ready\'].status,\
AGE:.metadata.creationTimestamp,\
INSTANCE-TYPE:.metadata.labels.node\\.kubernetes\\.io/instance-type,\
AZ:.metadata.labels.topology\\.kubernetes\\.io/zone
}

# Drain node before scaling down (safe node removal)
drain_node() {
    local node_name="$1"

    if [ -z "$node_name" ]; then
        echo "Usage: drain_node <node_name>"
        echo "Available nodes:"
        kubectl get nodes -o name | sed 's/node\///'
        return 1
    fi

    echo "Draining node: $node_name"
    kubectl drain "$node_name" \
        --ignore-daemonsets \
        --delete-emptydir-data \
        --force
}

# Check node resource utilization before scaling decisions
check_resource_usage() {
    echo "=== Node Resource Usage ==="
    kubectl top nodes
    echo ""
    echo "=== Pod Distribution ==="
    kubectl get pods --all-namespaces -o json | \
        jq -r '.items[] | select(.spec.nodeName != null) | .spec.nodeName' | \
        sort | uniq -c | sort -nr
}

# Example usage:
echo "EKS Node Group Scaling Helper Functions Loaded!"
echo ""
echo "Available commands:"
echo "  get_current_size [cluster_name] [nodegroup_name]  - Get current node count"
echo "  scale_nodegroup <size> [cluster_name] [nodegroup]  - Scale to specific size"
echo "  watch_scaling [cluster_name] [nodegroup_name]      - Monitor scaling progress"
echo "  list_nodes                                          - List all nodes with details"
echo "  drain_node <node_name>                              - Safely drain a node"
echo "  check_resource_usage                                - Check resource utilization"
echo ""
echo "Example: scale_nodegroup 5"