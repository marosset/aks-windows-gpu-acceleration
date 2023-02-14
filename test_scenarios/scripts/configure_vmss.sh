#!/bin/bash

set -euo pipefail

# Global vars
readonly WIN_NAMESPACE="windows-nodepool"

#######################################
# Apply daemonset to configure GPU nodes
# Globals:
#   WIN_NAMESPACE
# Arguments:
#   None
# Outputs:
#   Writes info to stdout
#######################################
apply_daemonset() {

    # create kubernetes namespace
    kubectl create namespace $WIN_NAMESPACE

    # apply daemonset
    kubectl apply -f manifests/daemonset-configure-node.yml
}

run_main() {

    echo "--- Applying daemonset to configure GPU nodes ---"
    apply_daemonset

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi
