#================================================
#   OSDCloud Task Sequence
#   Windows 10 21H1 Pro en-us Retail
#   No Autopilot
#   No Office Deployment Tool
#================================================
#   PreOS
#   Install and Import OSD Module
#================================================
Install-Module OSD -Force
Import-Module OSD -Force
#================================================
#   [OS] Start-OSDCloud with Params
#================================================
$Params = @{
    OSBuild = "21H1"
    OSEdition = "Pro"
    OSLanguage = "en-us"
    OSLicense = "Retail"
    SkipAutopilot = $true
    SkipODT = $true
}
Start-OSDCloud @Params
#================================================
#   WinPE PostOS Sample
#   OOBEDeploy Offline Staging
#================================================
$Params = @{
    Autopilot = $true
    RemoveAppx = "CommunicationsApps","OfficeHub","People","Skype","Solitaire","Xbox","ZuneMusic","ZuneVideo"
    UpdateDrivers = $true
    UpdateWindows = $true
}
Start-OOBEDeploy @Params

#================================================
#   PostOS
#   Trying to invoke some scripts using unattend
#================================================
$AuditUnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Reseal>
                <Mode>Audit</Mode>
            </Reseal>
        </component>
    </settings>
    <settings pass="auditUser">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
            
            <RunSynchronousCommand wcm:action="add">
            <Order>1</Order>
            <Description>Setting PowerShell ExecutionPolicy</Description>
            <Path>PowerShell -WindowStyle Hidden -Command "Set-ExecutionPolicy Unrestricted -Force"</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>2</Order>
            <Description>Update OSD Module</Description>
            <Path>PowerShell -Command "iex (irm winget.osdcloud.com)"</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>3</Order>
            <Description>Install GIT</Description>
            <Path>PowerShell -Command "winget install git.git --silent"</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>4</Order>
            <Description>Download Studio</Description>
            <Path>PowerShell -Command "Invoke-WebRequest -Uri "https://files.software2.com/deployment/cloudpaging/studio/9.3.1.1373/cloudpaging-studio-x64.msi" -OutFile C:\cloudpaging-studio-x64.msi"</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>5</Order>
            <Description>Install Studio</Description>
            <Path>PowerShell -Command "msiexec.exe /i C:\cloudpaging-studio-x64.msi /qn"</Path>
            </RunSynchronousCommand>

            </RunSynchronous>
        </component>
    </settings>
</unattend>
'@

#================================================
#   Set Unattend.xml
#================================================
$PantherUnattendPath = 'C:\Windows\Panther\Unattend'
if (-NOT (Test-Path $PantherUnattendPath)) {
    New-Item -Path $PantherUnattendPath -ItemType Directory -Force | Out-Null
}
$AuditUnattendPath = Join-Path $PantherUnattendPath 'Unattend.xml'
$AuditUnattendXml | Out-File -FilePath $AuditUnattendPath -Encoding utf8
Use-WindowsUnattend -Path 'C:\' -UnattendPath $AuditUnattendPath -Verbose

#===================================================================================================
#   PSGallery Modules
#===================================================================================================
Write-Host -ForegroundColor DarkGray    "================================================================="
Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
Write-Host -ForegroundColor Cyan        "PowerShell Modules and Scripts"

$PowerShellSavePath = 'C:\Program Files\WindowsPowerShell'


if (-NOT (Test-Path "$PowerShellSavePath\Configuration")) {
    New-Item -Path "$PowerShellSavePath\Configuration" -ItemType Directory -Force | Out-Null
}
if (-NOT (Test-Path "$PowerShellSavePath\Modules")) {
    New-Item -Path "$PowerShellSavePath\Modules" -ItemType Directory -Force | Out-Null
}
if (-NOT (Test-Path "$PowerShellSavePath\Scripts")) {
    New-Item -Path "$PowerShellSavePath\Scripts" -ItemType Directory -Force | Out-Null
}

if (Test-WebConnection -Uri "https://www.powershellgallery.com") {
    Save-Module -Name PackageManagement -Path "$PowerShellSavePath\Modules" -Force
    Save-Module -Name PowerShellGet -Path "$PowerShellSavePath\Modules" -Force
    Save-Module -Name Evergreen -Path "$PowerShellSavePath\Modules" -Force
}
else {
    $OSDCloudOfflinePath = Get-OSDCloudOfflinePath

    foreach ($Item in $OSDCloudOfflinePath) {
        Write-Host -ForegroundColor Cyan "Applying PowerShell Modules and Scripts in $($Item.FullName)\PowerShell\Required"
        robocopy "$($Item.FullName)\PowerShell\Required" "$PowerShellSavePath" *.* /e /ndl /njh /njs
    }
}

<##================================================
#   WinPE PostOS
#   Set AutopilotOOBE CMD.ps1
#================================================
$SetCommand = @'
@echo off

:: Set the PowerShell Execution Policy
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force

:: Add PowerShell Scripts to the Path
set path=%path%;C:\Program Files\WindowsPowerShell\Scripts

:: Open and Minimize a PowerShell instance just in case
start PowerShell -NoL -W Mi

:: Install the latest AutopilotOOBE Module
start "Install-Module AutopilotOOBE" /wait PowerShell -NoL -C Install-Module AutopilotOOBE -Force -Verbose

:: Start-AutopilotOOBE
:: There are multiple example lines. Make sure only one is uncommented
:: The next line assumes that you have a configuration saved in C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json
start "Start-AutopilotOOBE" PowerShell -NoL -C Start-AutopilotOOBE
:: The next line is how you would apply a CustomProfile
REM start "Start-AutopilotOOBE" PowerShell -NoL -C Start-AutopilotOOBE -CustomProfile OSDeploy
:: The next line is how you would configure everything from the command line
REM start "Start-AutopilotOOBE" PowerShell -NoL -C Start-AutopilotOOBE -Title 'OSDeploy Autopilot Registration' -GroupTag Enterprise -GroupTagOptions Development,Enterprise -Assign

exit
'@
$SetCommand | Out-File -FilePath "C:\Windows\Autopilot.cmd" -Encoding ascii -Force#>
#================================================
#   PostOS
#   Restart-Computer
#================================================
wpeutil reboot