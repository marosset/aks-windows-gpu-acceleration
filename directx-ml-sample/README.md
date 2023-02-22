# Run DirectX sample on AKS

This documents how to deploy the [Windows GPU DirectX Sample](https://github.com/MicrosoftDocs/Virtualization-Documentation/tree/main/windows-container-samples/directx) within AKS.

This document assumes you have a working AKS cluster with Windows GPU node pools and `kubectl` access set up.

K8s manifests deployed in the cluster:

- [directx-ml-sample.yaml](directx-ml-sample.yaml)
  - The image used in this deployment can be found here: [Dockerfile](../gpu/gpu_docker/Dockerfile)

    > Note: The above docker image references the [tinyyolov2-7.tar.gz](docker/tinyyolov2-7.tar.gz) because the original download link is no longer working

1. Build DirectX sample container:

    ```sh
    $ACR_NAME=<your_image_registry_name>
    az acr build --platform windows --registry $ACR_NAME --image samplemlgpu:v1 --file Dockerfile-2019 ./directx-ml-sample/docker/
    ```

2. Modify the [directx-ml-sample.yaml](directx-ml-sample.yaml) to use your image registry

3. Deploy the [directx-ml-sample.yaml](directx-ml-sample.yaml) to you cluster

    ```sh
    kubectl apply -f ./directx-ml-sample/directx-ml-sample.yaml 
    ```

4. If the application is working successfully, the logs should look something like this:


```sh
$ kubectl logs pods/sample-ml-workload-6896d6fb6b-7sslp 

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
  Load: 912.294 ms
  Bind: 0.0935 ms
  Session Creation: 58.3539 ms
  Evaluate: 51.9955 ms

  Working Set Memory usage (evaluate): 27.6055 MB
  Working Set Memory usage (load, bind, session creation, and evaluate): 154.676 MB
  Peak Working Set Memory Difference (load, bind, session creation, and evaluate): 187.406 MB

  Dedicated Memory usage (evaluate): 0 MB
  Dedicated Memory usage (load, bind, session creation, and evaluate): 0 MB

  Shared Memory usage (evaluate): 0 MB
  Shared Memory usage (load, bind, session creation, and evaluate): 0 MB

Average Performance excluding first iteration. Iterations 2 to 100. (Iterations greater than 1 only bind and evaluate)
  Average Bind: 0.0363616 ms
  Average Evaluate: 120.076 ms

  Average Working Set Memory usage (bind): 0 MB
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
  Load: 912.294 ms
  Bind: 18.9939 ms
  Session Creation: 257.863 ms
  Evaluate: 204.067 ms

  Working Set Memory usage (evaluate): 35.9727 MB
  Working Set Memory usage (load, bind, session creation, and evaluate): 255.289 MB
  Peak Working Set Memory Difference (load, bind, session creation, and evaluate): 196.863 MB

  Dedicated Memory usage (evaluate): 0 MB
  Dedicated Memory usage (load, bind, session creation, and evaluate): 0 MB

  Shared Memory usage (evaluate): 0 MB
  Shared Memory usage (load, bind, session creation, and evaluate): 0 MB

Average Performance excluding first iteration. Iterations 2 to 100. (Iterations greater than 1 only bind and evaluate)
  Average Bind: 0.277544 ms
  Average Evaluate: 7.91117 ms

  Average Working Set Memory usage (bind): 0.000157828 MB
  Average Working Set Memory usage (evaluate): 0.00441919 MB

  Average Dedicated Memory usage (bind): 0 MB
  Average Dedicated Memory usage (evaluate): 0 MB

  Average Shared Memory usage (bind): 0 MB
  Average Shared Memory usage (evaluate): 0 MB
```
