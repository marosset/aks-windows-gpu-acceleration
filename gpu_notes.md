Create a .env

```sh
RES_GROUP=
REGION="westeurope"
ACR_NAME=
WINDOWS_AKS_NAME=
NODE_POOL_NAME=

WINDOWS_ADMIN_PASSWORD=
SUBSCRIPTION=
```

Load .env to terminal

```sh
export $(grep -v '^#' .env | xargs)
source .env
```



# az account set --subscription $SUBSCRIPTION

https://github.com/marosset/aks-windows-gpu-acceleration

az vm list-usage --location "West Europe" -o table
az vm list-sizes --location "West Europe" -o table

# GPU work

az group create --name $RES_GROUP --location $REGION


az aks create \
    --resource-group $RES_GROUP \
    --name $WINDOWS_AKS_NAME \
    --location $REGION \
    --node-count 2 \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --vm-set-type VirtualMachineScaleSets \
    --network-plugin azure

# ONLY WORKS ON NV MACHINES, NOT NC

az aks nodepool add \
    --resource-group $RES_GROUP \
    --name $NODE_POOL_NAME \
    --cluster-name $WINDOWS_AKS_NAME \
    # --node-vm-size Standard_NV6ads_A10_v5 \ 
    --node-vm-size Standard_NC4as_T4_v3  \    
    --os-type Windows \
    --os-sku Windows2019 \
    --node-count 1

CLUSTER_RESOURCE_GROUP=$(az aks show --resource-group $RES_GROUP --name $WINDOWS_AKS_NAME --query nodeResourceGroup -o tsv)
VMSS_NAME=$(az vmss list -g $CLUSTER_RESOURCE_GROUP --query "[1].name"  | tr -d '"' )

list all extensions avaliable

```sh
az vmss extension image list -o table
```

```sh
az vmss extension set \
  --resource-group $CLUSTER_RESOURCE_GROUP \
  --vmss-name $VMSS_NAME \
  --name NvidiaGpuDriverWindows \
  --publisher Microsoft.HpcCompute \
  --version 1.4 \
  --settings '{ }'
```


```sh
az vmss update-instances --resource-group $CLUSTER_RESOURCE_GROUP --name $VMSS_NAME  --instance-ids "*"

az aks get-credentials --name $WINDOWS_AKS_NAME --resource-group $RES_GROUP

kubectl apply -f https://raw.githubusercontent.com/marosset/aks-windows-gpu-acceleration/main/k8s-directx-device-plugin/k8s-directx-device-plugin.yaml

```


> NOTE: directX pod needs to be restarted if this applied before the VM is created or extension is isntalled


k describe node <node_name>

kubectl logs -n kube-system directx-device-<random-guid>

https://stackoverflow.com/questions/63608246/extensions-on-aks-vmss

https://unrealcontainers.com/docs/concepts/gpu-acceleration
https://github.com/MicrosoftDocs/Virtualization-Documentation/tree/main/windows-container-samples/directx

# Download the model manually and add it to the image

az acr build --platform windows --registry $ACR_NAME --image samplemlgpu:v1 . 

# NVIDIA GPU DRIVER EXTENSTION TROUBLE SHOOTING

```sh
az vmss extension list --resource-group $CLUSTER_RESOURCE_GROUP --vmss-name $VMSS_NAME -o table
az vmss list-instances --resource-group $CLUSTER_RESOURCE_GROUP --name $VMSS_NAME -o table
az acr create --resource-group $RES_GROUP --name $ACR_NAME --sku Standard --location $REGION
```
NVIDIA GPU DRIVER INSTALLTION ALTENATIVES

<https://github.com/Azure-Samples/aks-nvidia-driver-daemonset>


## MADNESS

https://github.com/onnx/models/raw/main/vision/object_detection_segmentation/tiny-yolov2/model/tinyyolov2-7.tar.gz

https://raw.githubusercontent.com/onnx/models/main/vision/object_detection_segmentation/tiny-yolov2/model/tinyyolov2-7.tar.gz

https://github.com/onnx/models/tree/main/vision/object_detection_segmentation/tiny-yolov2


curl -o tiny_yolov2.tar.gz https://raw.githubusercontent.com/EliiseS/aks-windows-gpu-acceleration/main/gpu/gpu_docker/tinyyolov2-7.tar.gz

https://github.com/EliiseS/aks-windows-gpu-acceleration/blob/main/gpu/gpu_docker/tinyyolov2-7.tar.gz

curl -X POST  \
-H "Accept: application/vnd.git-lfs+json" \
-H "Content-type: application/json" \
-d '{"operation": "download", "transfer": ["basic"], "objects": [{"oid": "b20099da6c3d78ee60f1a68073eb2b522dd572c32b1787f588b822afd2d2e34c", "size": 60865248}]}' \
-o foo.txt \
https://github.com/onnx/models.git/info/lfs/objects/batch


# start stop

# Stop the cluster
az aks stop --resource-group $RES_GROUP --name $WINDOWS_AKS_NAME

# Start the cluster
az aks start --resource-group $RES_GROUP --name $WINDOWS_AKS_NAME

# exec into pod

kubectl exec --stdin --tty pods/sample-ml-workload-6896d6fb6b-c94sb -- PowerShell
dxdiag /t dxdiag.txt
cat dxdiag.txt

# Look for DXVA2 Modes:
# May be possible to change mode?
Tesla Compute Cluster (TCC)
https://docs.nvidia.com/gameworks/content/developertools/desktop/tesla_compute_cluster.htm

Azure N-series NVIDIA GPU driver setup for Windows - Azure Virtual Machines | Microsoft Learn
https://learn.microsoft.com/en-us/azure/virtual-machines/windows/n-series-driver-setup

### RDP into VM

RDP to AKS Windows Server nodes - Azure Kubernetes Service | Microsoft Learn
https://learn.microsoft.com/en-us/azure/aks/rdp?tabs=azure-cli



az aks update -g $RES_GROUP -n $WINDOWS_AKS_NAME --windows-admin-password $WINDOWS_ADMIN_PASSWORD

CLUSTER_RG=$(az aks show -g $RES_GROUP -n $WINDOWS_AKS_NAME --query nodeResourceGroup -o tsv)
VNET_NAME=$(az network vnet list -g $CLUSTER_RG --query [0].name -o tsv)
SUBNET_NAME=$(az network vnet subnet list -g $CLUSTER_RG --vnet-name $VNET_NAME --query [0].name -o tsv)
SUBNET_ID=$(az network vnet subnet show -g $CLUSTER_RG --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv)
NSG_NAME=$(az network nsg list -g $CLUSTER_RG --query [].name -o tsv)

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

VM_IP=20.73.78.71

NSG_NAME=$(az network nsg list -g $CLUSTER_RG --query [].name -o tsv)

az network nsg rule create \
 --name tempRDPAccess \
 --resource-group $CLUSTER_RG \
 --nsg-name $NSG_NAME \
 --priority 100 \
 --destination-port-range 3389 \
 --protocol Tcp \
 --description "Temporary RDP access to Windows nodes"

 # Go to the vm in portal -> Connect -> connect with RDP

# Get AKS Node IP

 k get nodes -o wide

In that VM, open RDP to connect to your AKS Node


PLugin not installed, somehow got uninstalled? 

```sh
PS C:\Users\azureuser> ls C:\WindowsAzure\Logs\Plugins\


    Directory: C:\WindowsAzure\Logs\Plugins


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----        1/31/2023  11:46 AM                Microsoft.AKS.Compute.AKS.Windows.Billing
d-----        1/31/2023  11:46 AM                Microsoft.Compute.CustomScriptExtension

```

```sh
PS C:\Users\azureuser> & '..\..\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe'
Tue Jan 31 13:27:15 2023
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 473.47       Driver Version: 473.47       CUDA Version: 11.4     |
|-------------------------------+----------------------+----------------------+
| GPU  Name            TCC/WDDM | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla T4            TCC  | 00000001:00:00.0 Off |                  Off |
| N/A   25C    P8     9W /  70W |      0MiB / 16225MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

```sh
PS C:\Users\azureuser> & '.\WinMLRunner v1.2.1.1\x64\WinMLRunner.exe' -model .\model\model.onnx -terse -iterations 10 -perf
Creating LearningModelDevice failed!Class not registered
```

install deps
```sh

# Try 7zip to unarchive headless
curl.exe -L -o nvidia_grid.exe https://download.microsoft.com/download/7/3/6/7361d1b9-08c8-4571-87aa-18cf671e71a0/512.78_grid_win10_win11_server2016_server2019_server2022_64bit_azure_swl.exe
.\nvidia_grid.exe

curl.exe -L -o vcredist_x64_2010.exe https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe
.\vcredist_x64_2010.exe


curl.exe -L -o VC_redist_x64_2017.exe https://download.visualstudio.microsoft.com/download/pr/11100230/15ccb3f02745c7b206ad10373cbca89b/VC_redist.x64.exe
.\VC_redist_x64_2017.exe


curl.exe -L -o windowsdesktop-runtime-6.0.13-win-x64.exe https://download.visualstudio.microsoft.com/download/pr/01dfbf9b-d2d1-4bd2-acb1-51d998c4812e/cf4fd6732540a78b4f44cbd9a285ce80/dotnet-sdk-6.0.405-win-x64.exe
.\windowsdesktop-runtime-6.0.13-win-x64.exe

# restart
shutdown /r

# check out nvida-smi
 & 'C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe'
 Wed Feb  1 13:19:44 2023
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 512.78       Driver Version: 512.78       CUDA Version: 11.6     |
|-------------------------------+----------------------+----------------------+
| GPU  Name            TCC/WDDM | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla T4           WDDM  | 00000001:00:00.0 Off |                  Off |
| N/A   30C    P8    14W /  70W |    257MiB / 16384MiB |     11%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|    0   N/A  N/A      1048    C+G   ...dows\System32\LogonUI.exe    N/A      |
|    0   N/A  N/A      1056    C+G   C:\Windows\System32\dwm.exe     N/A      |
|    0   N/A  N/A      3096    C+G   C:\Windows\System32\dwm.exe     N/A      |
|    0   N/A  N/A      6236    C+G   ...y\ShellExperienceHost.exe    N/A      |
|    0   N/A  N/A      6392    C+G   ...w5n1h2txyewy\SearchUI.exe    N/A      |
+-----------------------------------------------------------------------------+

```

Install program:

``sh
Copy-Item  Microsoft.PowerShell.Core\FileSystem::\\tsclient\C\Users\azureuser\Downloads\XRSession.zip -Destination C:\Users\azureuser\Downloads\


Expand-Archive -Path C:\Users\azureuser\Downloads\XRSession.zip -DestinationPath C:\

. C:\XRSession\Aveva.Cvp.Cloud.Poc.VideoService.XrSession.Executable.exe 027efe6f-aca8-4c3d-8e53-71535114e625 043efe6f-aca8-4c3d-8e53-71535114e625 sessionId vm1 contractEndpointUri 027efe6f-aca8-4c3d-aaaa-71535114e625


Get-Process -Name Aveva.Cvp.Cloud.Poc.VideoService.XrSession.Executable | Stop-Process
```

Results:

```sh

PS C:\Users\azureuser>  & 'C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe'
Wed Feb  1 13:31:08 2023
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 512.78       Driver Version: 512.78       CUDA Version: 11.6     |
|-------------------------------+----------------------+----------------------+
| GPU  Name            TCC/WDDM | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla T4           WDDM  | 00000001:00:00.0 Off |                  Off |
| N/A   29C    P8    14W /  70W |    221MiB / 16384MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|    0   N/A  N/A      1084    C+G   ...dows\System32\LogonUI.exe    N/A      |
|    0   N/A  N/A      1092    C+G   C:\Windows\System32\dwm.exe     N/A      |
|    0   N/A  N/A      3212    C+G   C:\Windows\System32\dwm.exe     N/A      |
|    0   N/A  N/A      3504    C+G   ...w5n1h2txyewy\SearchUI.exe    N/A      |
|    0   N/A  N/A      6556    C+G   C:\Windows\explorer.exe         N/A      |
|    0   N/A  N/A      6808    C+G   ...y\ShellExperienceHost.exe    N/A      |
+-----------------------------------------------------------------------------+

```


