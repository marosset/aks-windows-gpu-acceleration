# NOTES

Notes based on trying to run the guide on running Windows GPUS in AKS: <https://github.com/marosset/aks-windows-gpu-acceleration>




<https://stackoverflow.com/questions/63608246/extensions-on-aks-vmss>

<https://unrealcontainers.com/docs/concepts/gpu-acceleration>



##  NVIDIA GPU DRIVER EXTENSTION TROUBLE SHOOTING

```sh
az vmss extension list --resource-group $CLUSTER_RG --vmss-name $VMSS_NAME -o table
az vmss list-instances --resource-group $CLUSTER_RG --name $VMSS_NAME -o table
az acr create --resource-group $RES_GROUP --name $ACR_NAME --sku Standard --location $REGION
```

NVIDIA GPU DRIVER INSTALLTION ALTENATIVES

<https://github.com/Azure-Samples/aks-nvidia-driver-daemonset>

> May be possible to change mode?
> [Tesla Compute Cluster (TCC)](https://docs.nvidia.com/gameworks/content/developertools/desktop/tesla_compute_cluster.htm)
> DOES NOT WORK

[Azure N-series NVIDIA GPU driver setup for Windows - Azure Virtual Machines | Microsoft Learn](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/n-series-driver-setup)



### RDP into cluster NODE



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


## Quick start servers rdp in a new day

```sh
source .env
az aks start --resource-group $RES_GROUP --name $AKS_NAME

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

## Install NVIDIA driver headless

```sh
curl.exe -L -o 7zip-64x.exe https://www.7-zip.org/a/7z2201-x64.exe
.\7zip-64x.exe /S
& 'C:\Program Files\7-Zip\7z.exe'

curl.exe -L -o nvidia_grid.exe https://download.microsoft.com/download/7/3/6/7361d1b9-08c8-4571-87aa-18cf671e71a0/512.78_grid_win10_win11_server2016_server2019_server2022_64bit_azure_swl.exe
.\nvidia_grid.exe -s

```

 
```powershell
C:\NVIDIA\DisplayDriver\512.78\Win11_Win10_64\International

New-Service -Name RenderSession -BinaryPathName "C:\XRSession\Aveva.Cvp.Cloud.Poc.VideoService.XrSession.Executable.exe 027efe6f-aca8-4c3d-8e53-71535114e625 043efe6f-aca8-4c3d-8e53-71535114e625 sessionId vm1 contractEndpointUri 027efe6f-aca8-4c3d-aaaa-71535114e625" -DisplayName "Render Session" -Description "Render Session exe"

sc.exe config RenderSession obj=LocalSystem type=interact
Start-Service -Name RenderSession


# Define the service control handler code
function Start-MyService {
    Start-Process $exePath
}

function Stop-MyService {
    Stop-Process -Name Aveva.Cvp.Cloud.Poc.VideoService.XrSession.Executable
}


Get-Service -name RenderSession

Set-Service -Name  RenderSession -CanStop $true -CanPauseAndContinue $true


curl.exe -L -o nssm-2.24.zip https://nssm.cc/release/nssm-2.24.zip
tar.exe xvf nssm-2.24.zip

.\nssm-2.24\win64\nssm.exe install renderservice Aveva.Cvp.Cloud.Poc.VideoService.XrSession.Executable.exe 027efe6f-aca8-4c3d-8e53-71535114e625 043efe6f-aca8-4c3d-8e53-71535114e625 sessionId vm1 contractEndpointUri 027efe6f-aca8-4c3d-aaaa-71535114e625
.\nssm-2.24\win64\nssm.exe set renderservice AppDirectory C:\XRSession\
.\nssm-2.24\win64\nssm.exe start renderservice

Get-EventLog -LogName System -Source "Service Control Manager" -InstanceId 3221232496  | Format-Table  -Wrap  




curl.exe -L -o serman.zip https://github.com/kflu/serman/releases/download/0.3.2/serman.zip
tar.exe xvf serman.zip

New-Item config.xml


$contentToAdd = @"
<?xml version="1.0" encoding="utf-8"?>
<config version="1.0">
    <struct name="Platform" description="This section contains a set of parameters that are used to customize application loading and initial set-up.">
        <struct name="sound" description="">
            <item name="enable" type="sbool" value="False" description="Enable sounds/musics effects. If set to false no audio device is linked despite of the sound.device value. This means that disabling audio can be necessary to run on devices that offer no audio device." constraints="" />
            <item name="device" type="sint" value="-1" description="This parameter defines which audio device to use to play sound among the available ones. Set -1 to use windows default device. Check application log file to look for devices and their number id." constraints="" />
        </struct>
        <struct name="dirs" description="These section defines the folders to be used to load the different types of application contents.">
            <item name="textures" type="sstring" value="./GameData/Textures/;./GameData/Lightmaps/;./Gamedata/Menutextures/;./Gamedata/TexturesCache/;./Gamedata/Textures/modules/simsetup/Textures/;./Gamedata/Textures/modules/simsetup/Lightmaps/;./Gamedata/Menutextures/simsetup/;./Gamedata/Textures/modules/simulation/Textures/;./Gamedata/Textures/modules/simulation/Lightmaps/;./Gamedata/Textures/modules/avatar/Textures/;./Gamedata/Textures/modules/avatar/Lightmaps/;./Gamedata/Menutextures/simulation/;./Gamedata/Textures/user/Textures/;./GameData/Textures/user/Lightmaps/;./Gamedata/Menutextures/scenario/;./GameData/Textures/user/AlternativeAssets/fog/;./GameData/Textures/user/AlternativeAssets/rain/" description="Textures directories (comma separated). The order of the list defines the priority. So if a file is present in more than a folder it's taken from the one that comes first in the list. This is used sometimes to override paked contents." constraints="" />
            <item name="models" type="sstring" value="./GameData/Models/" description="Models directory." constraints="" />
            <item name="movies" type="sstring" value="./GameData/Movies/" description="Movies directory." constraints="" />
            <item name="scripts" type="sstring" value="./GameData/Scripts/" description="Scripts directory." constraints="" />
            <item name="shaders" type="sstring" value="./GameData/Shaders/" description="Shaders directory." constraints="" />
            <item name="streams" type="sstring" value="./GameData/Sounds/" description="Music Streams directory." constraints="" />
            <item name="sounds" type="sstring" value="./GameData/Sounds/" description="Sounds directory." constraints="" />
            <item name="cache" type="sstring" value="./GameData/Cache/" description="Cache system directory." constraints="" />
            <item name="probes" type="sstring" value="./GameData/Probes/" description="Probes directory." constraints="" />
            <item name="usershaders" type="sstring" value="./GameData/Shaders/user/" description="User Shaders directory." constraints="" />
        </struct>
        <struct name="fileSystem" description="This section is used to customize data file loading.">
            <item name="enablePAKFilesPreload" type="sbool" value="True" description="Enables preload in memory of the files included in PAK when accessed." constraints="" />
            <item name="mapMinimumSizeKB" type="sint" value="4" description="Minimum size of a file to be opened with a Map function (both for PAK and standard files)" constraints="range:0 inf" />
        </struct>
    </struct>
    <struct name="Graphics" description="This section contains the configuration for many engine rendering related functionalities.">
        <item name="renderSetupFilePath" type="sstring" value="./GameData/Viewport/rendersetup_fgi.xml" description="Render Setup configuration file path. This configuration determines both which rendering pipeline to be used (HDR or FGI) and which output mode or device to use (screen, stereo modes, oculus, openvr)." constraints="combo:default=./GameData/Viewport/rendersetup_default.xml,FGI=./GameData/Viewport/rendersetup_fgi.xml,oculus rift=./GameData/Viewport/rendersetup_oculus.xml,oculus rift FGI=./GameData/Viewport/rendersetup_oculus_fgi.xml,VIVE (openvr)=./GameData/Viewport/rendersetup_openvr.xml,VIVE (openvr) FGI=./GameData/Viewport/rendersetup_openvr_fgi.xml,dualhead=./GameData/Viewport/rendersetup_dualhead.xml,dualhead FGI=./GameData/Viewport/rendersetup_fgi_dualhead.xml,side by side=./GameData/Viewport/rendersetup_dualhead_sidebyside.xml,side by side FGI=./GameData/Viewport/rendersetup_fgi_dualhead_sidebyside.xml,3d vision=./GameData/Viewport/rendersetup_dualhead_3dvision.xml,3d vision FGI=./GameData/Viewport/rendersetup_fgi_dualhead_3dvision.xml,dualhead SLI=./GameData/Viewport/rendersetup_dualhead_sli.xml,side by side SLI=./GameData/Viewport/rendersetup_dualhead_sidebyside_sli.xml" />
        <struct name="window" description="Contains all the configurations belonging to the aspect and behavior of the window hosting the application.">
            <item name="orientation" type="sstring" value="landscape_right" description="Preferred App UI Orientation" constraints="combo:any,portrait_any,landscape_any,portrait_top,portrait_down,landscape_left,landscape_right" />
            <item name="width" type="sint" value="1280" description="Window width in windowed mode." constraints="range:1 inf" />
            <item name="height" type="sint" value="720" description="Window height in windowed mode." constraints="range:1 inf" />
            <item name="fullScreenWidth" type="sint" value="1920" description="FullScreen display width" constraints="blocked" />
            <item name="fullScreenHeight" type="sint" value="1080" description="FullScreen display height" constraints="blocked" />
            <item name="posx" type="sint" value="-1" description="Window position x (-1 to centre on desktop). Used only in windowed mode." constraints="range:-1 inf" />
            <item name="posy" type="sint" value="-1" description="Window position y (-1 to centre on desktop) Used only in windowed mode." constraints="range:-1 inf" />
            <item name="fullScreen" type="sbool" value="False" description="When set to true the application is started in fullscreen. When set to false the application is started windowed." constraints="function:refreshGFX" />
            <item name="backgroundColor" type="scolor3" value="0.5019608 1 1" description="Background color (R,G,B). This color is displayed as window background color and is visible where nothing is drawn." constraints="" />
            <item name="showCursor" type="sbool" value="True" description="When enabled the mouse cursor is shown over the rendered screen." constraints="" />
            <item name="interactive" type="sbool" value="True" description="Enables/Disables interaction with mouse and keyboard." constraints="" />
            <item name="skipHWFullscreen" type="sbool" value="True" description="This setting is used only when the application is in fullscreen mode. If set to true instead of rendering in hardware fullscreen the application is rendered into a borderless fullscreen window." constraints="" />
        </struct>
        <struct name="display" description="Contains the display related configurations.">
            <item name="adapterIndex" type="sint" value="1" description="Display Adapter index." constraints="blocked" />
            <item name="refreshRate" type="sint" value="60" description="Fullscreen Refresh Rate." constraints="blocked" />
            <item name="backBuffers" type="sint" value="1" description="Number of back buffers." constraints="" />
            <item name="vsynch" type="sbool" value="True" description="Enable vsynch." constraints="" />
            <item name="headless" type="sbool" value="True" description="Run in headless mode." constraints="" />
            <struct name="debug" description="">
                <item name="d3dDebugMode" type="sbool" value="False" description="Enable D3D debugging info." constraints="" />
            </struct>
        </struct>
        <struct name="detail" description="These parameters can be used to adapt the visual quality in order to maximize performance.">
            <item name="textureRes" type="sstring" value="High" description="Texture Resolution" constraints="combo:High=High,Medium=Medium,Low=Low,VeryLow=VeryLow,2x2=2x2,OneForAll=OneForAll" />
            <item name="maxLightsPerMesh" type="sint" value="4" description="Max Lights that a Mesh can use inside a Shader" constraints="range:1 8" />
            <item name="maxLightProbesPerMesh" type="sint" value="8" description="Max Light Probes that a Mesh can use inside a Shader" constraints="range:1 12" />
            <item name="maxLightsPerMeshForProbesGeneration" type="sint" value="24" description="Max Lights that a Mesh can use inside a Shader (during LightProbes generation)" constraints="range:1 64" />
        </struct>
        <struct name="mipmaps" description="This section is dedicated to automatic mipmap generation and caching.">
            <item name="generate" type="sbool" value="True" description="Automatically generates MipMaps for textures that do not have them (DDS files excluded)." constraints="" />
            <item name="enableCache" type="sbool" value="True" description="Enables a cache system to save the generated textures." constraints="" />
        </struct>
        <struct name="stereo3d" description="This parameters are used to adjust stereo parameters in those stereo modalities that supports them.">
            <item name="defaultOffset" type="sfloat" value="0.8000" description="Default Stereo offset (to invert cameras, use a negative value)." constraints="range:0 inf" />
            <item name="enableTrueStereo" type="sbool" value="False" description="Enable true 3d stereo." constraints="" />
            <item name="invertEyes" type="sbool" value="False" description="Invert 3d eyes." constraints="" />
        </struct>
        <struct name="geometry" description="Geometry caching related parameters.">
            <item name="enableCache" type="sbool" value="False" description="Enables geometry cache system to speed up loading times." constraints="" />
        </struct>
        <struct name="lod" description="Parameters used to customize engine LOD behavior.">
            <item name="meshValuesModifier" type="sfloat" value="1.0" description="This is a multiplier to LOD ranges. To display the Mesh LODs further away use a number above 1, otherwise below 1" constraints="range:0 inf" />
        </struct>
        <struct name="shaders" description="Parameters used to customize the shader compilation.">
            <item name="enableCache" type="sbool" value="False" description="Enables a cache system to speed up loading times." constraints="" />
        </struct>
        <struct name="shadows" description="These parameters sets the default shadowcasting behaviors for those meshes whose material does not explicitly define it.">
            <item name="defaultCastShadows" type="sbool" value="True" description="Default value for objects without the cast shadows flag" constraints="" />
            <item name="defaultReceiveShadows" type="sbool" value="True" description="Default value for objects without the receive shadows flag" constraints="" />
        </struct>
        <struct name="physx" description="PhysX is a realtime physics engine that can be used to simulate physical behaviors like kimematics, collisions and particles.">
            <item name="simPerSec" type="sint" value="60" description="Simulation cycles per second." constraints="range:1 120" />
            <item name="numCPUThreads" type="sint" value="4" description="Number of CPU Threads." constraints="range:1 8" />
            <item name="enableGPU" type="sbool" value="True" description="Enables GPU for physics computations (it works only if the GFX card supports Physx). If set to false the physical simulation calculation is performed in CPU slowering the performace." constraints="" />
            <item name="enablePVD" type="sbool" value="False" description="Enables PhysX Visual Debugger." constraints="" />
        </struct>
        <struct name="culling" description="Culling tecniques can be used to improve rendering performances by culling out object from being rendered.">
            <struct name="screenSpace" description="Screen space culling can be used to improve rendering performances avoiding to render objects whose screen space occupation percentage is lower than a treshold.">
                <item name="enable" type="sbool" value="True" description="Enable/Disable automatic screen space culling." constraints="" />
                <item name="percent" type="sfloat" value="0.7" description="Percent (along the X axis) after which the object is culled." constraints="range:0 100" />
                <item name="noCullingDistance" type="sfloat" value="9" description="Objects whose distance is less than value , will skip the screen space test." constraints="range:0 inf" />
            </struct>
        </struct>
        <struct name="oculus" description="This section is used by the engine when the Graphics.renderSetupPath is set to an oculus one. Allows to customize few oculus related parameters.">
            <item name="mirrorScreen" type="sbool" value="False" description="If set to true mirror image will be displayed on the application window shown on the monitor." constraints="" />
            <item name="mirrorScreenOptions" type="sint" value="4" description="Selecting RightEyeAndGuardian instead of Default enables the visualizaion of the oculus guardian and other info directly managed by oculus drivers." constraints="combo:Default=4,RightEyeAndGuardian=44" />
            <item name="log" type="sbool" value="False" description="Log Oculus messages." constraints="" />
        </struct>
        <struct name="openvr" description="This section is used by the engine when the Graphics.renderSetupPath is set to an openvr one. Allows to customize few openvr related parameters.">
            <item name="mirrorScreen" type="sbool" value="False" description="If set to true mirror image will be displayed on the application window shown on the monitor. The mirror image shows a single eye point of view." constraints="" />
        </struct>
        <struct name="rfc" description="These parameters are used to customize RFC contents visualization.">
            <item name="lodAreaMultiplier" type="sfloat" value="100.0000" description="Will scale screen area used to choose the LOD (increase to make the hi-def LODs appear sooner (inf)." constraints="range:1 1000" />
            <item name="minVisiblePercentArea" type="sfloat" value="0.0015" description="Below this percent of screen area (x*y) the object will be culled (b.sphere test) (inf)." constraints="range:0 10" />
            <item name="pickingLOD" type="sint" value="1" description="LOD used when picking." constraints="combo:low=0,mid=1,high=2" />
        </struct>
        <struct name="clipPlanes" description="These parameters are used to customize clipping functionalities">
            <item name="enable" type="sbool" value="True" description="Enables clip planes and clip volumes" constraints="" />
        </struct>
        <struct name="debug" description="Allow to enable debug functionalities used during development phase.">
            <item name="saveRTCubeMaps" type="sbool" value="False" description="Saves realtime cubemaps when generated (only the first time)." constraints="" />
            <item name="saveRTHeightMaps" type="sbool" value="False" description="Saves realtime heightmaps when generated (only the first time)." constraints="" />
        </struct>
    </struct>
    <struct name="AntiAlias" description="This section is used to customize the anti-aliasing functionalities of the rendering. The different anti-aliasing functionalities can be used both separately and together.">
        <struct name="msaa" description="Multi sampling anti-aliasing.">
            <item name="enable" type="sbool" value="True" description="Enable MSAA." constraints="" />
            <item name="count" type="sint" value="4" description="Number of Samples per pixel (may not be supported by all GPUs)." constraints="combo:2=2,4=4,8=8,16=16,32=32" />
            <item name="quality" type="sint" value="0" description="The higher the quality, the lower the performance. The valid range is between zero (standard multisample pattern) and any additional GPU vendor specific value" constraints="range:0 inf" />
        </struct>
        <struct name="fxaa" description="Fast approximate anti-aliasing.">
            <item name="enable" type="sbool" value="False" description="Enable FXAA." constraints="" />
            <item name="quality" type="sint" value="15" description="Quality level." constraints="combo:10,11,12,13,14,15,20,21,22,23,24,25,26,27,28,29,39" />
            <item name="subpix" type="sfloat" value="0.7500" description="Choose the amount of sub-pixel aliasing removal." constraints="range:0 1" />
            <item name="edgeThreshold" type="sfloat" value="0.1660" description="The minimum amount of local contrast required to apply algorithm." constraints="range:0.063 0.333" />
            <item name="edgeThresholdMin" type="sfloat" value="0.0833" description="Trims the algorithm from processing darks." constraints="range:0.0312 0.0833" />
            <item name="preset" type="sstring" value="none" description="Predefined presets (will override all the other params)." constraints="combo:UseParams=none,Low,Medium,High,Ultra" />
        </struct>
        <struct name="smaa" description="Sub-pixel morphological anti-aliasing">
            <item name="enable" type="sbool" value="False" description="Enable SMAA" constraints="" />
            <item name="quality" type="sint" value="1" description="Quality level." constraints="combo:low=0,medium=1,high=2,ultra=3" />
            <item name="edgeDetectionAlgorithm" type="sint" value="1" description="Choose the algorithm used for the edge detection." constraints="combo:depth=0,luma=1,color=2" />
        </struct>
    </struct>
    <struct name="Scene" description="This section contains all the configuration parameters used to configure the logic layer of the engine.">
        <item name="logic" type="sstring" value="./GameData/Logic/custom_main.xml" description="This is the path of the first logic file to load. By default is set to ./GameData/Logic/main.xml. All the other logic files are loaded according to the 'include' statements found in the scripts code." constraints="" />
        <item name="debug" type="sbool" value="True" description="Enables/Disables access to Debug and Log panels in realtime. The panels are shown when starting the application and can be re-opened using F10 if closed. Scene.debug configuration is used only when application is started windowed, so the Log and Debug panels are not accessible from applications started in fullscreen." constraints="" />
        <item name="lang" type="sstring" value="en" description="Allow to select the language used by the application. All the texts defined into the localization will change accordingly." constraints="combo:English=en,Italian=it" />
        <item name="pak" type="sstring" value="app_core.pak" description="Name of the application data pak to load. The application data pak is created when packing the application to deliver." constraints="" />
        <item name="additionalConf" type="sstring" value="./GameData/Logic/user/cfg_commons.xml;./GameData/Logic/user/cfg_simulation.xml;./GameData/Logic/user/cfg_simsetup.xml;./GameData/Logic/user/cfg_scenario.xml;./GameData/Logic/user/cfg_viewer.xml" description="Product additional configuration files. List of other config type files that the engine has to load in addition to config.xml and custom.xml." constraints="" />
        <item name="maxVisiblePopupTrends" type="sint" value="5" description="Max number of contemporaly visible ItemTrend Popups." constraints="" />
        <item name="profiling" type="sbool" value="False" description="Enables/Disables Realtime Scene Profiling functionalities that can be accessed from Debug Panel." constraints="" />
        <item name="quitWithESC" type="sbool" value="True" description="Enables/disable application exiting triggered by the pression of ESC key on the keyboard." constraints="" />
        <struct name="fps" description="This section is really important as allows to customize the rendering loop behavior and performances. For this reason these setting should be managed with care and require knwledge about engine rendering behavior knowledge.">
            <item name="game" type="sint" value="60" description="Target fps for (game) logic." constraints="range:0 inf" />
            <item name="render" type="sint" value="30" description="Target fps of render" constraints="range:0 inf" />
            <item name="type" type="sstring" value="static" description="Framerate type can be choose between static and adaptive. With static (game)logic and render are executed in sequence targeting fps.render value. With adaptive (game)logic and render are executed in parallel each one targeting its own fps. Adaptive rendering requires more data synchronization and this can impact performances." constraints="combo:adaptive,static" />
            <item name="useTimers" type="sbool" value="False" description="Enables/Disables use of windows timers for rendering and game loops." constraints="" />
        </struct>
        <struct name="capture" description="Allows to customize the screen capturing functionalities that can be managed from the Debug Panel. Capturing system will save a sequence of screen images to be later used by a video editing software to be compiled as a movie. Audio is not recorded.">
            <item name="enable" type="sbool" value="False" description="Enables/Disables capturing of video." constraints="" />
            <item name="fps" type="sint" value="25" description="Capture framerate. The framerate is static, it means that will capture that specific amount of screens in a second." constraints="" />
            <item name="path" type="sstring" value="capture\capture_" description="The path where to store the captured images." constraints="" />
        </struct>
    </struct>
    <struct name="Message" description="This section covers the configuration of the communications over the framework Message Bus.">
        <item name="enable" type="sbool" value="True" description="Enables/Disables the communications over the framework Message Bus." constraints="" />
        <item name="name" type="sstring" value="player0" description="Messaging Node Name. Identifies uniquely the application node inside the Message Bus network." constraints="combo:player0,player1,player2,player3,player4,player5,viewer" />
        <item name="type" type="sstring" value="server" description="Message Bus network role. Can be set to server, client or plugin. When using the embedded transfer protocol the network must have one and one only node configured as server. All other nodes must be assigned as clients." constraints="combo:client=client,server=server,plugin=plugin" />
        <item name="host" type="sstring" value="localhost" description="Host IP address or Hostname of the server of the Message Bus network. This field is used only if type is set to client." constraints="" />
        <item name="port" type="sint" value="10666" description="Port used for Message Bus TCP communications. By default should be set to 10666. All nodes connected to the same Message Bus must use the same port." constraints="range:0 65535" />
        <item name="webport" type="sint" value="10667" description="Port used for embedded http server. If set to -1 the http server is disabled." constraints="combo:10667,-1" />
        <item name="udpport" type="sint" value="10665" description="Port used for Message Bus UDP communications. By default should be set to 10665. All nodes connected to the same Message Bus must use the same port." constraints="combo:10665" />
        <item name="exitsOnDisconnect" type="sbool" value="False" description="Automatically close the application when disconnecting from Message Bus." constraints="" />
        <item name="streamType" type="sstring" value="none" description="Message Bus stream network role. Can be set to server, client or none. Stream communications work similarly to share ones with a node configured as server and all the other as clients. The port used is the udpport one." constraints="combo:client,server,none" />
    </struct>
    <struct name="License" description="">
        <item name="type" type="sstring" value="AUTO" description="License to use" constraints="combo:XR_STUDIO,XR_RUNTIME,XR_RUNTIME_DEMO,XR_RUNTIME_LITE,MWPL,AUTO" />
    </struct>
</config>
"@

Set-Content C:\RenderSession\config.xml $contentToAdd

.\serman.exe install config.xml

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "ServicesPipeTimeout" -Value 60000 -Type DWORD



```


```xml
<service>
  <id>hello</id>
  <name>hello</name>
  <description>This service runs the hello application</description>

  <executable>C:\XRSession\Aveva.Cvp.Cloud.Poc.VideoService.XrSession.Executable.exe 027efe6f-aca8-4c3d-8e53-71535114e625 043efe6f-aca8-4c3d-8e53-71535114e625 sessionId vm1 contractEndpointUri 027efe6f-aca8-4c3d-aaaa-71535114e625</executable>

  <!-- 
       {{dir}} will be expanded to the containing directory of your 
       config file, which is normally where your executable locates 
   -->
  <arguments>027efe6f-aca8-4c3d-8e53-71535114e625</arguments>
  <arguments>043efe6f-aca8-4c3d-8e53-71535114e625</arguments>
  <arguments>sessionId</arguments>
  <arguments>vm1</arguments>
  <arguments>contractEndpointUri</arguments>
  <arguments>027efe6f-aca8-4c3d-aaaa-71535114e625</arguments>

  <logmode>rotate</logmode>

  <!-- OPTIONAL FEATURE:
       NODE_ENV=production will be an environment variable 
       available to your application, but not visible outside 
       of your application
   -->
  <env name="NODE_ENV" value="production"/>

  <!-- OPTIONAL FEATURE:
       FOO_SERVICE_PORT=8989 will be persisted as an environment
       variable to the system.
   -->
  <persistent_env name="FOO_SERVICE_PORT" value="8989" />
</service>
```