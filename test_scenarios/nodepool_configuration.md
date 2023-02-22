# AKS Node configuration

This documents the dependencies required and their install steps to enable a GPU acceleration for AKS Nodes with `Standard_NC4as_T4_v3` SKU Windows Server Core 2022.

## Upgrade Containerd

```powershell
$Version="1.7.0-beta.3"
curl.exe -L https://github.com/containerd/containerd/releases/download/v$Version/containerd-$Version-windows-amd64.tar.gz -o containerd-windows-amd64.tar.gz
tar.exe xvf .\containerd-windows-amd64.tar.gz

Stop-Service kubeproxy
Stop-Service kubelet
Stop-Service containerd

Copy-Item -Path ".\bin\ctr.exe" -Destination "$Env:ProgramFiles\containerd" -Force
Copy-Item -Path ".\bin\containerd-shim-runhcs-v1.exe" -Destination "$Env:ProgramFiles\containerd" -Force
Copy-Item -Path ".\bin\containerd.exe" -Destination "$Env:ProgramFiles\containerd" -Force

Start-Service containerd; Start-Service kubeproxy; Start-Service kubelet
```

## Install NVIDIA GRID drivers

```powershell
curl.exe -L -o nvidia_grid.exe https://download.microsoft.com/download/7/3/6/7361d1b9-08c8-4571-87aa-18cf671e71a0/512.78_grid_win10_win11_server2016_server2019_server2022_64bit_azure_swl.exe
# add the '-s' flag to run headless. Warning: the exe will exit before it's finished in headless mode
.\nvidia_grid.exe 

# When installing silently, wait for nvidia_grid to finish
Wait-Process -name nvidia_grid

Restart-Computer # Computer will restart!
```

## Troubleshooting

Check packages are installed:

```powershell
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -AutoSize
```

```powershell
& 'C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe'
```

### Issue with installing driver in headless mode

```powershell
PS C:\Users\azureuser> & 'C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe'
>>
NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver. Make sure that the latest NVIDIA driver is installed and running. This can also be happening if non-NVIDIA GPU is running as primary display, and NVIDIA GPU is in WDDM mode.

Failed to properly shut down NVML: Driver Not Loaded
```
