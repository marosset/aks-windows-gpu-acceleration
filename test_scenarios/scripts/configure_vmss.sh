#!/bin/bash
#
# Configure GPU acclerated Windows nodes in AKS cluster
# Following this example: https://github.com/marosset/aks-windows-gpu-acceleration

set -euo pipefail

# Global vars
readonly WIN_NODEPOOL_NAME="npwin"
readonly WIN_RESOURCE_GROUP="MC_akswintest_testaksclusterwithwingpu_northeurope"

#######################################
# Add the 'NVDIA GPU Driver Extension' to the VirtualMachineScaleSet created for the new node pool added before
# Globals:
#   RESOURCE_GROUP_NAME
#   AKS_CLUSTER_NAME
#   WIN_NODEPOOL_NAME
# Arguments:
#   None
# Outputs:
#   Writes info to stdout
#######################################
add_nvidia_driver_extension() {
    echo "- Adding extension"
    az vmss extension set \
    --resource-group $WIN_RESOURCE_GROUP \
    --vmss-name "aks$WIN_NODEPOOL_NAME" \
    --name NvidiaGpuDriverWindows \
    --publisher Microsoft.HpcCompute \
    --version 1.6 \
    --settings '{}'
}

#######################################
# Update the VMSS instances to use the latest model
# Globals:
#   WIN_RESOURCE_GROUP
#   WIN_NODEPOOL_NAME
# Arguments:
#   None
# Outputs:
#   Writes info to stdout
#######################################
update_instances() {
    az vmss update-instances \
    --resource-group "$WIN_RESOURCE_GROUP" \
    --name "aks$WIN_NODEPOOL_NAME" \
    --instance-ids "*"
}

run_main() {
    
    echo "--- Adding Nvidia driver extension ---"
    add_nvidia_driver_extension
    
    echo "--- Updating Instances ---"
    update_instances
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi