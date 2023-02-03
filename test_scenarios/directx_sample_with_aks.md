# Run DirectX sample on AKS

This is documents the results of running the [Windows GPU DirectX Sample](https://github.com/MicrosoftDocs/Virtualization-Documentation/tree/main/windows-container-samples/directx) within AKS following the steps in [this document](../README.md).
The AKS windows nodepool is `Standard_NC4as_T4_v3` SKU Windows Server Core 2019.

K8s manifests deployed in the cluster:

- [directx-ml-sample.yaml](../directx-ml-sample/directx-ml-sample.yaml)
  - The image used in this deployment can be found here: [Dockerfile](../gpu/gpu_docker/Dockerfile)
- [k8s-directx-device-plugin.yaml](../k8s-directx-device-plugin/k8s-directx-device-plugin.yaml)

Tested driver installation methods:

- NVIDIA Grid drivers (installed manually on the VM):

  ```powershell
  curl.exe -L -o nvidia_grid.exe https://download.microsoft.com/download/7/3/6/7361d1b9-08c8-4571-87aa-18cf671e71a0/512.78_grid_win10_win11_server2016_server2019_server2022_64bit_azure_swl.exe
  .\nvidia_grid.exe
  ```

- NVIDIA CUDA drivers:

  ```sh
  az vmss extension set \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --vmss-name $VMSS_NAME \
    --name NvidiaGpuDriverWindows \
    --publisher Microsoft.HpcCompute \
    --version 1.6 \
    --settings '{ }'
  ```

The results were identical for both tested drivers.

## NVIDIA driver output

CUDA driver:

```powershell
PS C:\Users\azureuser>  & 'C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe'
Thu Feb  2 21:28:43 2023
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 473.47       Driver Version: 473.47       CUDA Version: 11.4     |
|-------------------------------+----------------------+----------------------+
| GPU  Name            TCC/WDDM | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla T4            TCC  | 00000001:00:00.0 Off |                  Off |
| N/A   23C    P8     9W /  70W |      0MiB / 16225MiB |      0%      Default |
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

GRID driver

```sh
PS C:\Users\azureuser>  & 'C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe'
Thu Feb  2 21:37:26 2023
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 512.78       Driver Version: 512.78       CUDA Version: 11.6     |
|-------------------------------+----------------------+----------------------+
| GPU  Name            TCC/WDDM | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla T4           WDDM  | 00000001:00:00.0 Off |                  Off |
| N/A   38C    P8    15W /  70W |      4MiB / 16384MiB |      0%      Default |
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

## AKS Cluster output

AKS version

```sh
$ k version --short
Flag --short has been deprecated, and will be removed in the future. The --short output will become the default.
Client Version: v1.26.1
Kustomize Version: v4.5.7
Server Version: v1.25.4
```

AKS nodes

```sh
$ k get nodes -o wide
NAME                                STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-67476830-vmss000008   Ready    agent   21h   v1.25.4   10.224.0.4    <none>        Ubuntu 22.04.1 LTS               5.15.0-1031-azure   containerd://1.6.15+azure-1
aks-nodepool1-67476830-vmss000009   Ready    agent   21h   v1.25.4   10.224.0.33   <none>        Ubuntu 22.04.1 LTS               5.15.0-1031-azure   containerd://1.6.15+azure-1
akswin19000005                      Ready    agent   21h   v1.25.4   10.224.0.62   <none>        Windows Server 2019 Datacenter   10.0.17763.3887     containerd://1.6.14+azure
```

Describe windows node:

```sh
$ k describe nodes akswin19000005 
Name:               akswin19000005
Roles:              agent
Labels:             accelerator=nvidia
                    agentpool=win19
                    beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=Standard_NC4as_T4_v3
                    beta.kubernetes.io/os=windows
                    failure-domain.beta.kubernetes.io/region=westeurope
                    failure-domain.beta.kubernetes.io/zone=0
                    kubernetes.azure.com/accelerator=nvidia
                    kubernetes.azure.com/agentpool=win19
                    kubernetes.azure.com/cluster=MC_esms-kube-workshop_esmswinaks_westeurope
                    kubernetes.azure.com/kubelet-identity-client-id=73855f26-13bd-4d21-a745-92d67fc500ec
                    kubernetes.azure.com/mode=user
                    kubernetes.azure.com/node-image-version=AKSWindows-2019-containerd-17763.3887.230111
                    kubernetes.azure.com/os-sku=Windows2019
                    kubernetes.azure.com/role=agent
                    kubernetes.azure.com/windows-password-version=4cb16bce23a320bfefba341c9911ff2a9caaf7dd643fca41001181810cf1f4
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=akswin19000005
                    kubernetes.io/os=windows
                    kubernetes.io/role=agent
                    node-role.kubernetes.io/agent=
                    node.kubernetes.io/instance-type=Standard_NC4as_T4_v3
                    node.kubernetes.io/windows-build=10.0.17763
                    topology.disk.csi.azure.com/zone=
                    topology.kubernetes.io/region=westeurope
                    topology.kubernetes.io/zone=0
Annotations:        csi.volume.kubernetes.io/nodeid: {"disk.csi.azure.com":"akswin19000005","file.csi.azure.com":"akswin19000005"}
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Thu, 02 Feb 2023 20:06:05 +0000
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  akswin19000005
  AcquireTime:     <unset>
  RenewTime:       Fri, 03 Feb 2023 17:19:15 +0000
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  MemoryPressure   False   Fri, 03 Feb 2023 17:14:22 +0000   Thu, 02 Feb 2023 21:39:28 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Fri, 03 Feb 2023 17:14:22 +0000   Thu, 02 Feb 2023 21:39:28 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Fri, 03 Feb 2023 17:14:22 +0000   Thu, 02 Feb 2023 21:39:28 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Fri, 03 Feb 2023 17:14:22 +0000   Thu, 02 Feb 2023 21:39:28 +0000   KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:  10.224.0.62
  Hostname:    akswin19000005
Capacity:
  cpu:                    4
  ephemeral-storage:      133703676Ki
  memory:                 29359668Ki
  microsoft.com/directx:  1
  pods:                   30
Allocatable:
  cpu:                    3860m
  ephemeral-storage:      133703676Ki
  memory:                 23781940Ki
  microsoft.com/directx:  1
  pods:                   30
System Info:
  Machine ID:                 akswin19000005
  System UUID:                78CB0558-09F0-48B1-86DE-FF275401A1C6
  Boot ID:                    10
  Kernel Version:             10.0.17763.3887
  OS Image:                   Windows Server 2019 Datacenter
  Operating System:           windows
  Architecture:               amd64
  Container Runtime Version:  containerd://1.6.14+azure
  Kubelet Version:            v1.25.4
  Kube-Proxy Version:         v1.25.4
ProviderID:                   azure:///subscriptions/d6b34f04-a058-4a19-a4c6-9da902217ddc/resourceGroups/mc_esms-kube-workshop_esmswinaks_westeurope/providers/Microsoft.Compute/virtualMachineScaleSets/akswin19/virtualMachines/5
Non-terminated Pods:          (6 in total)
  Namespace                   Name                                   CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                                   ------------  ----------  ---------------  -------------  ---
  default                     sample-ml-workload-6896d6fb6b-7sslp    500m (12%)    1 (25%)     050Mi (0%)       1000Mi (4%)    19h
  kube-system                 ama-logs-windows-w7dlj                 500m (12%)    500m (12%)  600Mi (2%)       600Mi (2%)     21h
  kube-system                 cloud-node-manager-windows-rjm8v       50m (1%)      0 (0%)      50Mi (0%)        512Mi (2%)     21h
  kube-system                 csi-azuredisk-node-win-6jwmb           60m (1%)      0 (0%)      120Mi (0%)       600Mi (2%)     21h
  kube-system                 csi-azurefile-node-win-ccqvx           60m (1%)      0 (0%)      120Mi (0%)       700Mi (3%)     21h
  kube-system                 directx-device-plugin-lcpbr            0 (0%)        0 (0%)      0 (0%)           0 (0%)         19h
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource               Requests     Limits
  --------               --------     ------
  cpu                    1170m (30%)  1500m (38%)
  memory                 940Mi (4%)   3412Mi (14%)
  ephemeral-storage      0 (0%)       0 (0%)
  microsoft.com/directx  1            1
Events:                  <none>
```

DirectX Sample pod:

```sh
$ k get pods -o wide
NAME                                  READY   STATUS    RESTARTS       AGE   IP            NODE             NOMINATED NODE   READINESS GATES
sample-ml-workload-6896d6fb6b-7sslp   1/1     Running   41 (23m ago)   19h   10.224.0.63   akswin19000005   <none>           <none>

```

```sh
$ k describe pod sample-ml-workload-6896d6fb6b-7sslp 
Name:             sample-ml-workload-6896d6fb6b-7sslp
Namespace:        default
Priority:         0
Service Account:  default
Node:             akswin19000005/10.224.0.62
Start Time:       Thu, 02 Feb 2023 21:41:17 +0000
Labels:           app=sample-ml-workload
                  pod-template-hash=6896d6fb6b
Annotations:      <none>
Status:           Running
IP:               10.224.0.63
IPs:
  IP:           10.224.0.63
Controlled By:  ReplicaSet/sample-ml-workload-6896d6fb6b
Containers:
  sample-ml-workload-container:
    Container ID:   containerd://e5cbe9dd1f86206096587d6b2b1631a0ab047daa84f02def15b363dcea84ab2b
    Image:          esmskubeacr.azurecr.io/samplemlgpu:v3
    Image ID:       esmskubeacr.azurecr.io/samplemlgpu@sha256:31c7cc8cacc3c07d596fd248d4e263796e1b432df3a973b7f6e1b4d6403d1e3b
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 03 Feb 2023 16:48:13 +0000
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Fri, 03 Feb 2023 16:23:24 +0000
      Finished:     Fri, 03 Feb 2023 16:48:03 +0000
    Ready:          True
    Restart Count:  41
    Limits:
      cpu:                    1
      memory:                 1000Mi
      microsoft.com/directx:  1
    Requests:
      cpu:                    500m
      memory:                 050Mi
      microsoft.com/directx:  1
    Environment:              <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8cbvn (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-8cbvn:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 microsoft.com/directx:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason   Age                 From     Message
  ----    ------   ----                ----     -------
  Normal  Pulled   54m                 kubelet  Successfully pulled image "esmskubeacr.azurecr.io/samplemlgpu:v3" in 422.913ms
  Normal  Pulling  29m (x42 over 19h)  kubelet  Pulling image "esmskubeacr.azurecr.io/samplemlgpu:v3"
  Normal  Created  29m (x42 over 19h)  kubelet  Created container sample-ml-workload-container
  Normal  Pulled   29m                 kubelet  Successfully pulled image "esmskubeacr.azurecr.io/samplemlgpu:v3" in 345.5373ms
  Normal  Started  29m (x42 over 19h)  kubelet  Started container sample-ml-workload-container
```

```sh
$ k logs pods/sample-ml-workload-6896d6fb6b-7sslp 

Created LearningModelDevice with CPU device

Created LearningModelDevice with GPU: Microsoft Basic Render Driver
Loading model (path = C:\App\model\model.onnx)...
=================================================================
Name: Example Model
Author: OnnxMLTools
Version: 0
Domain: onnxconverter-common
Description: The Tiny YOLO network from the paper 'YOLO9000: Better, Faster, Stronger' (2016), arXiv:1612.08242
Path: C:\App\model\model.onnx
Support FP16: false

Input Feature Info:
Name: image
Feature Kind: Image (Height: 416, Width:  416)

Output Feature Info:
Name: grid
Feature Kind: Float

=================================================================

Binding (device = CPU, iteration = 1, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML)...[SUCCESS]
Evaluating (device = CPU, iteration = 1, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML)...[SUCCESS]
Binding and Evaluating 99 more times...
Results (device = CPU, numIterations = 100, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML):

First Iteration Performance (load, bind, session creation, and evaluate): 
  Load: 928.989 ms
  Bind: 0.0866 ms
  Session Creation: 58.9057 ms
  Evaluate: 51.7193 ms

  Working Set Memory usage (evaluate): 27.4414 MB
  Working Set Memory usage (load, bind, session creation, and evaluate): 154.773 MB
  Peak Working Set Memory Difference (load, bind, session creation, and evaluate): 187.406 MB

  Dedicated Memory usage (evaluate): 0 MB
  Dedicated Memory usage (load, bind, session creation, and evaluate): 0 MB

  Shared Memory usage (evaluate): 0 MB
  Shared Memory usage (load, bind, session creation, and evaluate): 0 MB

Average Performance excluding first iteration. Iterations 2 to 100. (Iterations greater than 1 only bind and evaluate)
  Average Bind: 0.0353354 ms
  Average Evaluate: 120.132 ms

  Average Working Set Memory usage (bind): 0 MB
  Average Working Set Memory usage (evaluate): 0.0608428 MB

  Average Dedicated Memory usage (bind): 0 MB
  Average Dedicated Memory usage (evaluate): 0 MB

  Average Shared Memory usage (bind): 0 MB
  Average Shared Memory usage (evaluate): 0 MB

```

Full pod list:

```sh
$ k get pods -A -o wide 
NAMESPACE     NAME                                  READY   STATUS    RESTARTS       AGE   IP            NODE                                NOMINATED NODE   READINESS GATES
default       sample-ml-workload-6896d6fb6b-7sslp   1/1     Running   41 (26m ago)   19h   10.224.0.63   akswin19000005                      <none>           <none>
kube-system   ama-logs-qc97k                        2/2     Running   0              21h   10.224.0.38   aks-nodepool1-67476830-vmss000009   <none>           <none>
kube-system   ama-logs-rs-66f849497c-zzk4f          1/1     Running   0              21h   10.224.0.6    aks-nodepool1-67476830-vmss000008   <none>           <none>
kube-system   ama-logs-windows-w7dlj                1/1     Running   2 (19h ago)    21h   10.224.0.65   akswin19000005                      <none>           <none>
kube-system   ama-logs-zhv2p                        2/2     Running   0              21h   10.224.0.8    aks-nodepool1-67476830-vmss000008   <none>           <none>
kube-system   azure-ip-masq-agent-8c7bz             1/1     Running   0              21h   10.224.0.33   aks-nodepool1-67476830-vmss000009   <none>           <none>
kube-system   azure-ip-masq-agent-z99ln             1/1     Running   0              21h   10.224.0.4    aks-nodepool1-67476830-vmss000008   <none>           <none>
kube-system   cloud-node-manager-ccgnc              1/1     Running   0              21h   10.224.0.4    aks-nodepool1-67476830-vmss000008   <none>           <none>
kube-system   cloud-node-manager-td9cn              1/1     Running   0              21h   10.224.0.33   aks-nodepool1-67476830-vmss000009   <none>           <none>
kube-system   cloud-node-manager-windows-rjm8v      1/1     Running   2 (19h ago)    21h   10.224.0.73   akswin19000005                      <none>           <none>
kube-system   coredns-59b6bf8b4f-hm4ps              1/1     Running   0              21h   10.224.0.36   aks-nodepool1-67476830-vmss000009   <none>           <none>
kube-system   coredns-59b6bf8b4f-lmfbq              1/1     Running   0              21h   10.224.0.14   aks-nodepool1-67476830-vmss000008   <none>           <none>
kube-system   coredns-autoscaler-5655d66f64-z4r7t   1/1     Running   0              21h   10.224.0.10   aks-nodepool1-67476830-vmss000008   <none>           <none>
kube-system   csi-azuredisk-node-45jdk              3/3     Running   0              21h   10.224.0.4    aks-nodepool1-67476830-vmss000008   <none>           <none>
kube-system   csi-azuredisk-node-lp798              3/3     Running   0              21h   10.224.0.33   aks-nodepool1-67476830-vmss000009   <none>           <none>
kube-system   csi-azuredisk-node-win-6jwmb          3/3     Running   6 (19h ago)    21h   10.224.0.64   akswin19000005                      <none>           <none>
kube-system   csi-azurefile-node-6672q              3/3     Running   0              21h   10.224.0.33   aks-nodepool1-67476830-vmss000009   <none>           <none>
kube-system   csi-azurefile-node-dmn7j              3/3     Running   0              21h   10.224.0.4    aks-nodepool1-67476830-vmss000008   <none>           <none>
kube-system   csi-azurefile-node-win-ccqvx          3/3     Running   6 (19h ago)    21h   10.224.0.75   akswin19000005                      <none>           <none>
kube-system   directx-device-plugin-lcpbr           1/1     Running   1              19h   10.224.0.62   akswin19000005                      <none>           <none>
kube-system   konnectivity-agent-db86bb65d-685rc    1/1     Running   0              21h   10.224.0.42   aks-nodepool1-67476830-vmss000009   <none>           <none>
kube-system   konnectivity-agent-db86bb65d-6ssss    1/1     Running   0              21h   10.224.0.29   aks-nodepool1-67476830-vmss000008   <none>           <none>
kube-system   kube-proxy-7dwqs                      1/1     Running   0              21h   10.224.0.33   aks-nodepool1-67476830-vmss000009   <none>           <none>
kube-system   kube-proxy-rkvr2                      1/1     Running   0              21h   10.224.0.4    aks-nodepool1-67476830-vmss000008   <none>           <none>
kube-system   metrics-server-686f5fc4bc-2h2fc       2/2     Running   0              21h   10.224.0.26   aks-nodepool1-67476830-vmss000008   <none>           <none>
kube-system   metrics-server-686f5fc4bc-mskxg       2/2     Running   0              21h   10.224.0.49   aks-nodepool1-67476830-vmss000009   <none>           <none>
```

DirectX daemon set pod:

```sh
vscode ➜ /workspaces/aks-windows-gpu-acceleration (main ✗) $ k describe -n kube-system pod directx-device-plugin-lcpbr 
Name:             directx-device-plugin-lcpbr
Namespace:        kube-system
Priority:         0
Service Account:  default
Node:             akswin19000005/10.224.0.62
Start Time:       Thu, 02 Feb 2023 21:38:35 +0000
Labels:           controller-revision-hash=c97b9464b
                  k8s-app=directx-device-plugin
                  pod-template-generation=1
Annotations:      <none>
Status:           Running
IP:               10.224.0.62
IPs:
  IP:           10.224.0.62
Controlled By:  DaemonSet/directx-device-plugin
Containers:
  directx-device-plugin:
    Container ID:   containerd://dbdfda0076152954e8bf95f70ae96fd0c04b65a4318f4b5bb8be0547ab38e220
    Image:          mrosse3/k8s-directx-device-plugin:hpc-0.1.0
    Image ID:       docker.io/mrosse3/k8s-directx-device-plugin@sha256:dde2ccf7fcf1fe0f096f00df49ab2145e3320a269b22c922a7f2baffd6d3a139
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 02 Feb 2023 21:39:30 +0000
    Ready:          True
    Restart Count:  1
    Environment:
      KUBERNETES_SERVICE_HOST:       esmswinaks-esms-kube-worksh-d6b34f-75e4f939.hcp.westeurope.azmk8s.io
      DIRECTX_GPU_MATCH_NAME:        nvidia
      KUBERNETES_PORT_443_TCP_ADDR:  esmswinaks-esms-kube-worksh-d6b34f-75e4f939.hcp.westeurope.azmk8s.io
      KUBERNETES_PORT:               tcp://esmswinaks-esms-kube-worksh-d6b34f-75e4f939.hcp.westeurope.azmk8s.io:443
      KUBERNETES_PORT_443_TCP:       tcp://esmswinaks-esms-kube-worksh-d6b34f-75e4f939.hcp.westeurope.azmk8s.io:443
    Mounts:
      /var/lib/kubelet/device-plugins from device-plugin (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-22m9k (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  device-plugin:
    Type:          HostPath (bare host directory volume)
    Path:          /var/lib/kubelet/device-plugins
    HostPathType:  
  kube-api-access-22m9k:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              kubernetes.io/os=windows
Tolerations:                 node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/network-unavailable:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists
                             node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                             node.kubernetes.io/unreachable:NoExecute op=Exists
                             node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:                      <none>
```

```sh
vscode ➜ /workspaces/aks-windows-gpu-acceleration (main ✗) $ k logs -n kube-system directx-device-plugin-lcpbr 
ERROR: logging before flag.Parse: W0202 21:39:31.120569     848 main.go:90] 'Microsoft Hyper-V Video' doesn't match  'nvidia', ignoring this gpu
ERROR: logging before flag.Parse: I0202 21:39:31.142569     848 main.go:98] GPU NVIDIA Tesla T4 id: PCI\VEN_10DE&DEV_1EB8&SUBSYS_12A210DE&REV_A1\6&1397ADA&0&0
ERROR: logging before flag.Parse: I0202 21:39:31.142569     848 main.go:101] pluginSocksDir: /var/lib/kubelet/device-plugins/
ERROR: logging before flag.Parse: I0202 21:39:31.142569     848 main.go:103] socketPath: /var/lib/kubelet/device-plugins/directx.sock
2023/02/02 21:39:31 Starting to serve on /var/lib/kubelet/device-plugins/directx.sock
2023/02/02 21:39:31 Deprecation file not found. Invoke registration
2023/02/02 21:39:31 ListAndWatch
2023/02/02 21:41:19 Allocate, &AllocateRequest{ContainerRequests:[&ContainerAllocateRequest{DevicesIDs:[PCI\VEN_10DE&DEV_1EB8&SUBSYS_12A210DE&REV_A1\6&1397ADA&0&0],}],}
```

## Dxdiag output within the pod

Below you can find the command to retrieve the `dxdiag` with a snippet. Full report can be found here: [CUDA driver dxdiag](aks_pod_dxdiag_cuda_driver.txt), [GRID driver dxdiag](aks_pod_dxdiag_grid_driver.txt).

```sh
kubectl exec --stdin --tty pods/sample-ml-workload-6896d6fb6b-c94sb -- PowerShell
dxdiag /t dxdiag.txt
cat dxdiag.txt
....
      Rank Of Driver: Unknown
         Video Accel: Unknown
         DXVA2 Modes: Unknown # Important, according to the guide these modes should not be unknown with working GPU acceleration
      Deinterlace Caps: n/a
        D3D9 Overlay: Unknown
             DXVA-HD: Unknown
...
```
