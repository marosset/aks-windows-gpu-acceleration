# Run containerized DirectX sample on Windows Server Core 2019

This is documents on how to run the [Windows GPU DirectX Sample](https://github.com/MicrosoftDocs/Virtualization-Documentation/tree/main/windows-container-samples/directx) within a container on Windows Server Core VM. The following command have been tested on the VM SKU `Standard_NC4as_T4_v3`.

All commands will be run in the powershell terminal of the server.

Install NVIDIA Grid drivers:

```sh
curl.exe -L -o nvidia_grid.exe https://download.microsoft.com/download/7/3/6/7361d1b9-08c8-4571-87aa-18cf671e71a0/512.78_grid_win10_win11_server2016_server2019_server2022_64bit_azure_swl.exe
.\nvidia_grid.exe
```

Add your docker ACR URL and password to the terminal session in your windows machine:

```sh
$ACR_NAME=""
$ACR_USERNAME=""
$ACR_PASSWORD=""
```

Configure your environment to enable container-related OS features and install the Docker runtime.
Reference docs [here](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce#windows-server-1).

```powershell
Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1
.\install-docker-ce.ps1
```

Login to docker

```powershell
docker login "${ACR_NAME}.azurecr.io" -u $ACR_USERNAME -p $ACR_PASSWORD
```

Run DirectX sample.

```powershell
# Run with device not bound
docker run "${ACR_NAME}.azurecr.io/samplemlgpu:v3"

# Run with device bound
docker run --isolation process --device "class/5B45201D-F2F2-4F3B-85BB-30FF1F953599" "${ACR_NAME}.azurecr.io/samplemlgpu:v3"
```

> TIP: To open a new Command Prompt window in Windows Server Core, press `CTRL+ALT+DELETE`. If you are using RDP to connect remotely, use `CTRL+ALT+END`.
> Next click `Start Task Manager`, click `More Details`, click `File`, click `Run`, and then type `cmd.exe`.

## Results

### Run without binding a device

These are the results for running the DirectX sample with the device unbound. Interesting thing to note is that the model still detects the GPU, but errors out on when trying to use it.
Unlike when running the container within AKS, where GPU device is not detected by the sample at all.

```powershell
PS C:\Users\azureuser> docker run -it "${ACR_NAME}.azurecr.io/samplemlgpu:v3"

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

Binding (device = CPU, iteration = 1, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML)...[SUC
CESS]
Evaluating (device = CPU, iteration = 1, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML)...[
SUCCESS]
Binding and Evaluating 99 more times...
Results (device = CPU, numIterations = 100, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML):


First Iteration Performance (load, bind, session creation, and evaluate):
  Load: 947.591 ms
  Bind: 0.2644 ms
  Session Creation: 64.1526 ms
  Evaluate: 61.5811 ms

  Working Set Memory usage (evaluate): 27.4375 MB
  Working Set Memory usage (load, bind, session creation, and evaluate): 154.773 MB
  Peak Working Set Memory Difference (load, bind, session creation, and evaluate): 187.402 MB

  Dedicated Memory usage (evaluate): 0 MB
  Dedicated Memory usage (load, bind, session creation, and evaluate): 0 MB

  Shared Memory usage (evaluate): 0 MB
  Shared Memory usage (load, bind, session creation, and evaluate): 0 MB

Average Performance excluding first iteration. Iterations 2 to 100. (Iterations greater than 1 only bind and evaluate)
  Average Bind: 0.0380101 ms
  Average Evaluate: 68.1482 ms

  Average Working Set Memory usage (bind): 3.94571e-05 MB
  Average Working Set Memory usage (evaluate): 0.0608428 MB

  Average Dedicated Memory usage (bind): 0 MB
  Average Dedicated Memory usage (evaluate): 0 MB

  Average Shared Memory usage (bind): 0 MB
  Average Shared Memory usage (evaluate): 0 MB



Binding (device = GPU, iteration = 1, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML)...[SUC
CESS]
Evaluating (device = GPU, iteration = 1, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML)...[
SUCCESS]

-----

PS C:\Users\azureuser> docker ps -a
CONTAINER ID   IMAGE                                       COMMAND                  CREATED          STATUS                                   PORTS     NAMES
f7316cfb99bd   esmskubeacr.azurecr.io/samplemlgpu:v3       "C:/App/WinMLRunner …"   3 minutes ago    Exited (3221225786) About a minute ago             hardcore_kirch

```

### Run with device class bound

These are the results for running the DirectX sample with the device bound. From the results we can see the GPU is both detected and utilized by the sample.
In addition the docker container exits with code 0.

```powershell
PS C:\Users\azureuser> docker run --isolation process --device "class/5B45201D-F2F2-4F3B-85BB-30FF1F953599" "${ACR_NAME}.azurecr.io/samplemlgpu:v3"
Created LearningModelDevice with CPU device

Created LearningModelDevice with GPU: NVIDIA Tesla T4
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
  Load: 1031.48 ms
  Bind: 0.0899 ms
  Session Creation: 57.8559 ms
  Evaluate: 52.5231 ms

  Working Set Memory usage (evaluate): 27.6836 MB
  Working Set Memory usage (load, bind, session creation, and evaluate): 154.789 MB
  Peak Working Set Memory Difference (load, bind, session creation, and evaluate): 187.512 MB

  Dedicated Memory usage (evaluate): 0 MB
  Dedicated Memory usage (load, bind, session creation, and evaluate): 0 MB

  Shared Memory usage (evaluate): 0 MB
  Shared Memory usage (load, bind, session creation, and evaluate): 0 MB

Average Performance excluding first iteration. Iterations 2 to 100. (Iterations greater than 1 only bind and evaluate)
  Average Bind: 0.0366596 ms
  Average Evaluate: 60.4515 ms

  Average Working Set Memory usage (bind): 3.94571e-05 MB
  Average Working Set Memory usage (evaluate): 0.0603299 MB

  Average Dedicated Memory usage (bind): 0 MB
  Average Dedicated Memory usage (evaluate): 0 MB

  Average Shared Memory usage (bind): 0 MB
  Average Shared Memory usage (evaluate): 0 MB



Binding (device = GPU, iteration = 1, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML)...[SUCCESS]
Evaluating (device = GPU, iteration = 1, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML)...[SUCCESS]
Binding and Evaluating 99 more times...
Results (device = GPU, numIterations = 100, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML):

First Iteration Performance (load, bind, session creation, and evaluate):
  Load: 1031.48 ms
  Bind: 17.4046 ms
  Session Creation: 184.708 ms
  Evaluate: 296.901 ms

  Working Set Memory usage (evaluate): 36.0508 MB
  Working Set Memory usage (load, bind, session creation, and evaluate): 255.291 MB
  Peak Working Set Memory Difference (load, bind, session creation, and evaluate): 196.707 MB

  Dedicated Memory usage (evaluate): 0 MB
  Dedicated Memory usage (load, bind, session creation, and evaluate): 0 MB

  Shared Memory usage (evaluate): 0 MB
  Shared Memory usage (load, bind, session creation, and evaluate): 0 MB

Average Performance excluding first iteration. Iterations 2 to 100. (Iterations greater than 1 only bind and evaluate)
  Average Bind: 0.261838 ms
  Average Evaluate: 10.9364 ms

  Average Working Set Memory usage (bind): 0.000157828 MB
  Average Working Set Memory usage (evaluate): 0.00449811 MB

  Average Dedicated Memory usage (bind): 0 MB
  Average Dedicated Memory usage (evaluate): 0 MB

  Average Shared Memory usage (bind): 0 MB
  Average Shared Memory usage (evaluate): 0 MB

-----

PS C:\Users\azureuser> docker ps -a
CONTAINER ID   IMAGE                                       COMMAND                  CREATED          STATUS                                   PORTS     NAMES
4d3cf49c72e9   esmskubeacr.azurecr.io/samplemlgpu:v3       "C:/App/WinMLRunner …"   8 minutes ago    Exited (0) 8 minutes ago                           crazy_wright

-----

PS C:\Users\azureuser> & 'C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe'
Fri Feb  3 14:40:32 2023
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 512.78       Driver Version: 512.78       CUDA Version: 11.6     |
|-------------------------------+----------------------+----------------------+
| GPU  Name            TCC/WDDM | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla T4           WDDM  | 00000001:00:00.0 Off |                  Off |
| N/A   28C    P8    16W /  70W |    365MiB / 16384MiB |     53%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|    0   N/A  N/A      9304    C+G   ...2.1.1\x64\WinMLRunner.exe    N/A      |
+-----------------------------------------------------------------------------+
```