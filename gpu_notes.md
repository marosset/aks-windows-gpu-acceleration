# NOTES

Notes based on trying to run the guide on running Windows GPUS in AKS: <https://github.com/marosset/aks-windows-gpu-acceleration>

Create a .env

```sh
RES_GROUP=
REGION="westeurope"
ACR_NAME=
AKS_NAME=
NODE_POOL_NAME=

WINDOWS_ADMIN_PASSWORD=
SUBSCRIPTION=
```

Load .env to terminal

```sh
export $(grep -v '^#' .env | xargs)
# OR
source .env
```

Login and set your account

```sh
az login
az account set --subscription $SUBSCRIPTION
```

View available VMs

```sh
az vm list-usage --location "West Europe" -o table
az vm list-sizes --location "West Europe" -o table
```

Create resource group and AKS

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

> WARNING: ONLY WORKS ON NV MACHINES, NOT NC

```sh
az aks nodepool add \
    --resource-group $RES_GROUP \
    --name $NODE_POOL_NAME \
    --cluster-name $AKS_NAME \
    # --node-vm-size Standard_NV6ads_A10_v5 \ 
    --node-vm-size Standard_NC4as_T4_v3  \    
    --os-type Windows \
    --os-sku Windows2019 \
    --node-count 1
```

Scale nodes up or down:

```sh
SCALE=1
az aks scale --resource-group $RES_GROUP --name $AKS_NAME --node-count $SCALE --nodepool-name $NODE_POOL_NAME
```

Get AKS's resource group and VMSS name

```sh
CLUSTER_RESOURCE_GROUP=$(az aks show --resource-group $RES_GROUP --name $AKS_NAME --query nodeResourceGroup -o tsv)
VMSS_NAME=$(az vmss list -g $CLUSTER_RESOURCE_GROUP --query "[1].name"  | tr -d '"' )
```

list all extensions available in azure

```sh
az vmss extension image list -o table
```

```sh
az vmss extension set \
  --resource-group $CLUSTER_RESOURCE_GROUP \
  --vmss-name $VMSS_NAME \
  --name NvidiaGpuDriverWindows \
  --publisher Microsoft.HpcCompute \
  --version 1.6 \
  --settings '{ }'
```

```sh
az vmss extension delete \
  --resource-group $CLUSTER_RESOURCE_GROUP \
  --vmss-name $VMSS_NAME \
  --name NvidiaGpuDriverWindows 
```

```sh
az vmss update-instances --resource-group $CLUSTER_RESOURCE_GROUP --name $VMSS_NAME  --instance-ids "*"


kubectl apply -f https://raw.githubusercontent.com/marosset/aks-windows-gpu-acceleration/main/k8s-directx-device-plugin/k8s-directx-device-plugin.yaml

```

> NOTE: directX pod needs to be restarted if this applied before the VM is created or extension is installed

```sh
k describe node <node_name>

kubectl logs -n kube-system directx-device-<random-guid>
```

<https://stackoverflow.com/questions/63608246/extensions-on-aks-vmss>

<https://unrealcontainers.com/docs/concepts/gpu-acceleration>

Download the model manually and add it to the image

```sh
az acr build --platform windows --registry $ACR_NAME --image samplemlgpu:v1 .
```

##  NVIDIA GPU DRIVER EXTENSTION TROUBLE SHOOTING

```sh
az vmss extension list --resource-group $CLUSTER_RESOURCE_GROUP --vmss-name $VMSS_NAME -o table
az vmss list-instances --resource-group $CLUSTER_RESOURCE_GROUP --name $VMSS_NAME -o table
az acr create --resource-group $RES_GROUP --name $ACR_NAME --sku Standard --location $REGION
```

NVIDIA GPU DRIVER INSTALLTION ALTENATIVES

<https://github.com/Azure-Samples/aks-nvidia-driver-daemonset>

> May be possible to change mode?
> [Tesla Compute Cluster (TCC)](https://docs.nvidia.com/gameworks/content/developertools/desktop/tesla_compute_cluster.htm)

[Azure N-series NVIDIA GPU driver setup for Windows - Azure Virtual Machines | Microsoft Learn](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/n-series-driver-setup)

## Quality of life commands

Start the cluster

```sh
az aks start --resource-group $RES_GROUP --name $AKS_NAME
```

Stop the cluster

```sh
az aks stop --resource-group $RES_GROUP --name $AKS_NAME
```

exec into pod and get `dxdiag` output:
> Look for DXVA2 Modes

```sh
kubectl exec --stdin --tty pods/sample-ml-workload-6896d6fb6b-c94sb -- PowerShell
dxdiag /t dxdiag.txt
cat dxdiag.txt
```

### RDP into cluster NODE

[RDP to AKS Windows Server nodes - Azure Kubernetes Service | Microsoft Learn](https://learn.microsoft.com/en-us/azure/aks/rdp?tabs=azure-cli)

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
    --name winRemoteVM \
    --image Win2019Datacenter \
    --admin-username azureuser \
    --admin-password $WINDOWS_ADMIN_PASSWORD \
    --subnet $SUBNET_ID \
    --nic-delete-option delete \
    --os-disk-delete-option delete \
    --nsg "" \
    --public-ip-address $PUBLIC_IP_ADDRESS_NAME \ 
    --query publicIpAddress -o tsv

  # --public-ip-sku Standard \

```

Create network rule to allow rdp

```sh
NSG_NAME=$(az network nsg list -g $CLUSTER_RG --query [].name -o tsv)

az network nsg rule create \
 --name tempRDPAccess \
 --resource-group $CLUSTER_RG \
 --nsg-name $NSG_NAME \
 --priority 100 \
 --destination-port-range 3389 \
 --protocol Tcp \
 --description "Temporary RDP access to Windows nodes"
#  & '.\WinMLRunner v1.2.1.1\x64\WinMLRunner.exe' -model .\model\model.onnx -terse -iterations 10 -perf
 ```

Go to the vm in portal -> Connect -> connect with RDP

Get AKS Node IP

```sh
k get nodes -o wide
```

In that VM, open RDP to connect to your AKS Node

```sh
az aks nodepool upgrade  --resource-group $RES_GROUP --cluster-name $AKS_NAME --name win19 --kubernetes-version 1.25.4 --no-wait
az aks get-upgrades --resource-group $RES_GROUP --name  $AKS_NAME
az aks upgrade --resource-group $RES_GROUP --name  $AKS_NAME --kubernetes-version 1.25.4
az aks nodepool list --resource-group $RES_GROUP --cluster-name  $AKS_NAME
```

## Issues encountered

PLugin not installed, somehow got uninstalled?

```sh
PS C:\Users\azureuser> ls C:\WindowsAzure\Logs\Plugins\


    Directory: C:\WindowsAzure\Logs\Plugins


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----        1/31/2023  11:46 AM                Microsoft.AKS.Compute.AKS.Windows.Billing
d-----        1/31/2023  11:46 AM                Microsoft.Compute.CustomScriptExtension

```
