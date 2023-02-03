# Upgrade Containerd

```powershell
# Download and extract desired containerd Windows binaries
$Version="v1.7.0-beta.3"
curl.exe -L https://github.com/containerd/containerd/releases/download/v$Version/containerd-$Version-windows-amd64.tar.gz -o containerd-windows-amd64.tar.gz
tar.exe xvf .\containerd-windows-amd64.tar.gz

# Copy and configure
Copy-Item -Path ".\bin\*" -Destination "$Env:ProgramFiles\containerd" -Recurse -Force
cd $Env:ProgramFiles\containerd\
.\containerd.exe config default | Out-File config.toml -Encoding ascii

# Review the configuration. Depending on setup you may want to adjust:
# - the sandbox_image (Kubernetes pause image)
# - cni bin_dir and conf_dir locations
Get-Content config.toml

# Register and start service
.\containerd.exe --register-service
Start-Service containerd
```
