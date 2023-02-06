#!/bin/bash
#
# Configure GPU acclerated Windows nodes in AKS cluster
# Following this example: https://github.com/marosset/aks-windows-gpu-acceleration

set -euo pipefail

# Global vars
readonly DEVICE_PLUGIN_PATH=https://raw.githubusercontent.com/marosset/aks-windows-gpu-acceleration/main/k8s-directx-device-plugin/k8s-directx-device-plugin.yaml

#######################################

add_directx_plugin() {
    kubectl apply -f $DEVICE_PLUGIN_PATH
}

run_main() {
    
    echo "--- Add DirectX plugin to cluster ---"
    add_directx_plugin
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi