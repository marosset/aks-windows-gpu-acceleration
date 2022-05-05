# Overview

This reposity holds instructions for configuring GPU acclerated Windows nodes in AKS clusters

## Node Setup

1. Create an AKS cluster following https://docs.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-cli#create-an-aks-cluster

1. Add a Windows Server node pool following https://docs.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-cli#create-an-aks-cluster

    Notes:

    1. kubernetes version must be **1.23** or later

    1. node-vm-size should be a `NV*` series which support DirectX acceleration. [https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-gpu]

1. Add the 'NVDIA GPU Driver Extension' to the VirtualMachineScaleSet created for the new node pool added above

    https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/hpccompute-gpu-windows

    https://docs.microsoft.com/en-us/cli/azure/vmss/extension?view=azure-cli-latest

1. Ensure VirtualMachineScaleSet instances are using the most up-to-date model

    https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-upgrade-scale-set#how-to-bring-vms-up-to-date-with-the-latest-scale-set-model

1. Wait for VM extensions to run

1. Deploy `k8s-directx-device-plugin.yaml to your cluster

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/marosset/aks-windows-gpu-acceleration/main/k8s-directx-device-plugin/k8s-directx-device-plugin.yaml
    ```

### Node Setup Verification

1. run `kubectl describe node {gpu-node}` and look for

    ```yaml
    Capacity:
        cpu:                    6
        ephemeral-storage:      133703676Ki
        memory:                 58719796Ki
        microsoft.com/directx:  1
        pods:                   30
    Allocatable:
        cpu:                    5840m
        ephemeral-storage:      133703676Ki
        memory:                 51379764Ki
        microsoft.com/directx:  1
        pods:                   30
    ```

## Requesting GPU acceleration in container instances

1. In your workload deployment files add requests for 'microsoft.com/directx` resoruces 

    ```yaml
    ...
    spec:
      containers:
    ...
        resources:
          requests:
            microsoft.com/directx: "1"
    ```

## Troubleshooting

1. Ensure `daemonSet` pods are running

    Check status with

    ```bash
    kubectl get pods -A
    ```

1. Check device plugin pod logs

    ```bash
    kubectl logs -n kube-system {pod-name}
    ```

    You should see something like

    ```log
    kubectl logs -n kube-system directx-device-plugin-5t7dc
    ERROR: logging before flag.Parse: I0505 19:10:39.046785    5076 main.go:98] GPU NVIDIA Tesla M60 id: PCI\VEN_10DE&DEV_13F2&SUBSYS_115E10DE&REV_A1\6&2B78CA89&0&0
    ERROR: logging before flag.Parse: W0505 19:10:39.096589    5076 main.go:90] 'Microsoft Hyper-V Video' doesn't match  'nvidia', ignoring this gpu
    ERROR: logging before flag.Parse: I0505 19:10:39.096589    5076 main.go:101] pluginSocksDir: /var/lib/kubelet/device-plugins/
    ERROR: logging before flag.Parse: I0505 19:10:39.096589    5076 main.go:103] socketPath: /var/lib/kubelet/device-plugins/directx.sock
    2022/05/05 19:10:40 Starting to serve on /var/lib/kubelet/device-plugins/directx.sock
    2022/05/05 19:10:40 Deprecation file not found. Invoke registration
    2022/05/05 19:10:40 ListAndWatch
    ```
