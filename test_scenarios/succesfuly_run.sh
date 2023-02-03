PS Microsoft.PowerShell.Core\FileSystem::\\wsl.localhost\Debian\home\eliise\src\mine\kube-workshop> & '.\gpu\WinMLRunner v1.2.1.1\x64\WinMLRunner.exe' -model .\gpu\gpu_docker\model\model.onnx -terse -iterations 10 -perf

Created LearningModelDevice with CPU device

Created LearningModelDevice with GPU: Intel(R) UHD Graphics
Loading model (path = \\wsl.localhost\Debian\home\eliise\src\mine\kube-workshop\gpu\gpu_docker\model\model.onnx)...
=================================================================
Name: Example Model
Author: OnnxMLTools
Version: 0
Domain: onnxconverter-common
Description: The Tiny YOLO network from the paper 'YOLO9000: Better, Faster, Stronger' (2016), arXiv:1612.08242
Path: \\wsl.localhost\Debian\home\eliise\src\mine\kube-workshop\gpu\gpu_docker\model\model.onnx
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
Binding and Evaluating 9 more times...
Results (device = CPU, numIterations = 10, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML):

First Iteration Performance (load, bind, session creation, and evaluate):
  Load: 389.594 ms
  Bind: 0.449 ms
  Session Creation: 59.8519 ms
  Evaluate: 42.6565 ms

  Working Set Memory usage (evaluate): 28.4023 MB
  Working Set Memory usage (load, bind, session creation, and evaluate): 166.801 MB
  Peak Working Set Memory Difference (load, bind, session creation, and evaluate): 198.129 MB

  Dedicated Memory usage (evaluate): 0 MB
  Dedicated Memory usage (load, bind, session creation, and evaluate): 0 MB

  Shared Memory usage (evaluate): 0 MB
  Shared Memory usage (load, bind, session creation, and evaluate): 0 MB

Average Performance excluding first iteration. Iterations 2 to 10. (Iterations greater than 1 only bind and evaluate)
  Average Bind: 0.291411 ms
  Average Evaluate: 36.2924 ms

  Average Working Set Memory usage (bind): 0.000868056 MB
  Average Working Set Memory usage (evaluate): 0.661458 MB

  Average Dedicated Memory usage (bind): 0 MB
  Average Dedicated Memory usage (evaluate): 0 MB

  Average Shared Memory usage (bind): 0 MB
  Average Shared Memory usage (evaluate): 0 MB



Binding (device = GPU, iteration = 1, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML)...[SUCCESS]
Evaluating (device = GPU, iteration = 1, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML)...[SUCCESS]
Binding and Evaluating 9 more times...
Results (device = GPU, numIterations = 10, inputBinding = CPU, inputDataType = Tensor, deviceCreationLocation = WinML):

First Iteration Performance (load, bind, session creation, and evaluate):
  Load: 389.594 ms
  Bind: 0.7212 ms
  Session Creation: 9044.1 ms
  Evaluate: 52.2558 ms

  Working Set Memory usage (evaluate): 67.3516 MB
  Working Set Memory usage (load, bind, session creation, and evaluate): 251.611 MB
  Peak Working Set Memory Difference (load, bind, session creation, and evaluate): 248.941 MB

  Dedicated Memory usage (evaluate): 0 MB
  Dedicated Memory usage (load, bind, session creation, and evaluate): 0 MB

  Shared Memory usage (evaluate): 69.4414 MB
  Shared Memory usage (load, bind, session creation, and evaluate): 100.156 MB

Average Performance excluding first iteration. Iterations 2 to 10. (Iterations greater than 1 only bind and evaluate)
  Average Bind: 0.387411 ms
  Average Evaluate: 36.0319 ms

  Average Working Set Memory usage (bind): 0 MB
  Average Working Set Memory usage (evaluate): 0.0381944 MB

  Average Dedicated Memory usage (bind): 0 MB
  Average Dedicated Memory usage (evaluate): 0 MB

  Average Shared Memory usage (bind): 0 MB
  Average Shared Memory usage (evaluate): 0.0381944 MB

