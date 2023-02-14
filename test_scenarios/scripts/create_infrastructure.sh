#!/bin/bash
#
# Configure GPU acclerated Windows nodes in AKS cluster
# Following this example: https://github.com/marosset/aks-windows-gpu-acceleration

set -euo pipefail

# Global vars
readonly RESOURCE_GROUP_NAME="${1-testakswin}"
readonly LOCATION="${2-westeurope}"
readonly AKS_NODE_COUNT=2
readonly WIN_NODE_COUNT=1
readonly WINDOWS_USERNAME="azureuser"
readonly WINDOWS_PASSWORD="testpasswordw1thSpeci@lchars"
readonly AKS_CLUSTER_NAME="testaksclusterwithwingpu"
readonly WIN_NODEPOOL_NAME="npwin"
readonly NODEPOOL_OS_SKU="Windows2022"
readonly VM_SIZE="Standard_NV8as_v4"

#######################################
# Set up AKS cluster and Windows nodepool
# Globals:
#   RESOURCE_GROUP_NAME
#   AKS_CLUSTER_NAME
#   AKS_NODE_COUNT
#   WINDOWS_USERNAME
#   WINDOWS_PASSWORD
#   LOCATION
# Arguments:
#   None
# Outputs:
#   Writes info to stdout
#######################################
create_infrastructure() {

    echo "- Create resource group $RESOURCE_GROUP_NAME"
    az group create \
        --location $LOCATION \
        --name "$RESOURCE_GROUP_NAME"

    echo ""
    echo "- Create AKS cluster $AKS_CLUSTER_NAME"

    az aks create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name $AKS_CLUSTER_NAME \
        --location $LOCATION \
        --node-count $AKS_NODE_COUNT \
        --enable-addons monitoring \
        --generate-ssh-keys \
        --windows-admin-username $WINDOWS_USERNAME \
        --windows-admin-password $WINDOWS_PASSWORD \
        --vm-set-type VirtualMachineScaleSets \
        --network-plugin azure

    echo ""
    echo "- Add Windows nodepool $WIN_NODEPOOL_NAME of size $VM_SIZE"

    az aks nodepool add \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name $WIN_NODEPOOL_NAME \
        --cluster-name $AKS_CLUSTER_NAME \
        --node-vm-size $VM_SIZE \
        --os-type Windows \
        --os-sku $NODEPOOL_OS_SKU \
        --node-count $WIN_NODE_COUNT

    echo ""
    echo "- Conntect to AKS cluster"
    az aks get-credentials \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name $AKS_CLUSTER_NAME
}

run_main() {

    echo "--- Creating infrastructure ---"
    create_infrastructure
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi
