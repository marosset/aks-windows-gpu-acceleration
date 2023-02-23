# Overview

This repository holds instructions for configuring GPU accelerated Windows nodes in AKS clusters

## Node Setup

The following guide can be completed by following the links or by following the example command in `bash`.

1. Set up your env

    Install [kubectl](https://kubernetes.io/docs/reference/kubectl/) or the use provided [`devcontainer.json`](.devcontainer/devcontainer.json) to [Develop inside a Container using Visual Studio Code Remote Development](https://code.visualstudio.com/docs/devcontainers/containers).

    Create a `.env` var file:

    ```sh
    RES_GROUP=
    REGION="westeurope"
    ACR_NAME=
    AKS_NAME=
    NODE_POOL_NAME=
    NODE_POOL_SKU=

    WINDOWS_ADMIN_PASSWORD=
    SUBSCRIPTION=
    ```

    Load `.env` to terminal:

    ```sh
    source .env
    # OR
    export $(grep -v '^#' .env | xargs)
    ```

    Login to Azure CLI:

    ```sh
    az login
    az account set --subscription $SUBSCRIPTION
    ```

2. Create an AKS cluster following <https://docs.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-cli#create-an-aks-cluster>

    Create AKS Cluster and resource group:

    ```sh
    az group create --name $RES_GROUP --location $REGION

    az aks create \
        --resource-group $RES_GROUP \
        --name $AKS_NAME \
        --location $REGION \
        --node-count 2 \
        --enable-addons monitoring \
        --generate-ssh-keys \
        --vm-set-type VirtualMachineScaleSets \
        --network-plugin azure
    ```

    Connect to AKS

    ```sh
    az aks get-credentials --name $AKS_NAME --resource-group $RES_GROUP
    ```

3. Add a Windows Server node pool following <https://learn.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-cli#add-a-windows-node-pool>

    Notes:

    1. kubernetes version must be **1.23** or later

    2. node-vm-size should be a `NV*` OR `NC*` series which support DirectX acceleration. [https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-gpu]
    3. For `NC` machines, the NVIDIA GRID driver must be installed instead of CUDA

    ```sh
    az aks nodepool add \
        --resource-group $RES_GROUP \
        --name $NODE_POOL_NAME \
        --cluster-name $AKS_NAME \
        --node-vm-size $NODE_POOL_SKU  \    
        --os-type Windows \
        --os-sku Windows2022 \
        --node-count 1
    ```

4. Install drivers

   - For `NC*` machines: See [Manual nodepool configuration](test_scenarios/nodepool_configuration.md) (automatic is coming)
   - For `NV*` machines: Add the 'NVDIA GPU Driver Extension' to the VirtualMachineScaleSet created for the new node pool added above
       <https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/hpccompute-gpu-windows>
       <https://docs.microsoft.com/en-us/cli/azure/vmss/extension?view=azure-cli-latest>

       Get AKS's resource group and VMSS name

       ```sh
       CLUSTER_RG=$(az aks show --resource-group $RES_GROUP --name $AKS_NAME --query nodeResourceGroup -o tsv)
       VMSS_NAME=$(az vmss list -g $CLUSTER_RG --query "[1].name"  | tr -d '"' )
       ```

       ```sh
       az vmss extension set \
       --resource-group $CLUSTER_RG \
       --vmss-name $VMSS_NAME \
       --name NvidiaGpuDriverWindows \
       --publisher Microsoft.HpcCompute \
       --version 1.6 \
       --settings '{ }'
       ```

      1. Ensure VirtualMachineScaleSet instances are using the most up-to-date model: <https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-upgrade-scale-set#how-to-bring-vms-up-to-date-with-the-latest-scale-set-model>

            ```sh
            az vmss update-instances --resource-group $CLUSTER_RG --name $VMSS_NAME  --instance-ids "*"
            ```

      2. Wait for VM extensions to run
      3. If something goes wrong with the installation, delete the extension and try again

            ```sh
            az vmss extension delete \
            --resource-group $CLUSTER_RG \
            --vmss-name $VMSS_NAME \
            --name NvidiaGpuDriverWindows 
            ```

5. Deploy `k8s-directx-device-plugin.yaml` to your cluster

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/marosset/aks-windows-gpu-acceleration/main/k8s-directx-device-plugin/k8s-directx-device-plugin.yaml
    ```

    > NOTE: `k8s-directx-device` pod needs to be restarted if this applied before the VM is created or extension is installed


6. Optionally deploy [DirectX Sample container](directx-ml-sample/readme.md).

### Node Setup Verification

1. Run `kubectl describe node {gpu-node}` and look for

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

1. Check node has directX capacity enabled

```sh
k describe node {node_name}
```

```log
$ k describe node akswin22000002 
...
Capacity:
  cpu:                    4
  ephemeral-storage:      133703676Ki
  memory:                 29359668Ki
  microsoft.com/directx:  1
  pods:                   30
..
```

1. Check device plugin pod logs

    ```bash
    kubectl logs -n kube-system directx-device-plugin-{pod-guid}
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

1. Check `dxdiag` output in the container:

> Look for 'DXVA2 Modes'

```sh
kubectl exec --stdin --tty pods/{pod_name} -- PowerShell
dxdiag /t dxdiag.txt
cat dxdiag.txt
....
      Rank Of Driver: Unknown
         Video Accel: Unknown
         DXVA2 Modes: Unknown # Important, these modes should not be unknown with working GPU acceleration
      Deinterlace Caps: n/a
        D3D9 Overlay: Unknown
             DXVA-HD: Unknown
...
```

1. Upgrade AKS

[Upgrade an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn](https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster?tabs=azure-cli)

```sh
# Get available upgrades
az aks get-upgrades --resource-group $RES_GROUP --name  $AKS_NAME

# Upgrade
NEW_AKS_VERSION={version_to_upgrade_to}
az aks nodepool upgrade --resource-group $RES_GROUP --cluster-name $AKS_NAME --name $NODE_POOL_NAME --kubernetes-version $NEW_AKS_VERSION --no-wait

# View versions
az aks nodepool list --resource-group $RES_GROUP --cluster-name  $AKS_NAME
```

### Setting up RDP access to the node

Following [RDP to AKS Windows Server nodes - Azure Kubernetes Service | Microsoft Learn](https://learn.microsoft.com/en-us/azure/aks/rdp?tabs=azure-cli).

```sh
az aks update -g $RES_GROUP -n $AKS_NAME --windows-admin-password $WINDOWS_ADMIN_PASSWORD

CLUSTER_RG=$(az aks show -g $RES_GROUP -n $AKS_NAME --query nodeResourceGroup -o tsv)
VNET_NAME=$(az network vnet list -g $CLUSTER_RG --query [0].name -o tsv)
SUBNET_NAME=$(az network vnet subnet list -g $CLUSTER_RG --vnet-name $VNET_NAME --query [0].name -o tsv)
SUBNET_ID=$(az network vnet subnet show -g $CLUSTER_RG --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv)
NSG_NAME=$(az network nsg list -g $CLUSTER_RG --query [].name -o tsv)
```

```sh
PUBLIC_IP_ADDRESS_NAME="winVMPublicIP"

az vm image list --output table

az vm create \
    --resource-group $RES_GROUP \
    --name jumpBoxWinVM \
    --image Win2019Datacenter \
    --admin-username azureuser \
    --admin-password $WINDOWS_ADMIN_PASSWORD \
    --subnet $SUBNET_ID \
    --nic-delete-option delete \
    --os-disk-delete-option delete \
    --nsg "" \
    --public-ip-address winVMPublicIP \
    --query publicIpAddress -o tsv
```

Create network rule to allow rdp

```sh
CLUSTER_RG=$(az aks show -g $RES_GROUP -n $AKS_NAME --query nodeResourceGroup -o tsv)
NSG_NAME=$(az network nsg list -g $CLUSTER_RG --query [].name -o tsv)

az network nsg rule create \
 --name tempRDPAccess \
 --resource-group $CLUSTER_RG \
 --nsg-name $NSG_NAME \
 --priority 100 \
 --destination-port-range 3389 \
 --protocol Tcp \
 --description "Temporary RDP access to Windows nodes"
 ```

Go to the vm in portal -> Connect -> connect with RDP

Get AKS Node IP

```sh
k get nodes -o wide
```

In that VM, open RDP to connect to your AKS Node

## Useful commands

Start and Stop the cluster

```sh
az aks start --resource-group $RES_GROUP --name $AKS_NAME
az aks stop --resource-group $RES_GROUP --name $AKS_NAME
```

View available VM SKUs in a region

```sh
az vm list-usage --location "West Europe" -o table
az vm list-sizes --location "West Europe" -o table
```

Scale nodes up or down:

```sh
SCALE=1
az aks scale --resource-group $RES_GROUP --name $AKS_NAME --node-count $SCALE --nodepool-name $NODE_POOL_NAME
```

List all extensions available for VMSS

```sh
az vmss extension image list -o table
```
