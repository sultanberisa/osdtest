[CmdletBinding()]
param()

#Start the Transcript
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OSDCloud.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

#Region Variables
$ScriptName = 'sultan.OSDCloudTEST'
$ScriptVersion = '04.10.2023'

$appx2remove = @('OneNote','BingWeather','CommunicationsApps','OneDrive','OfficeHub','People','Skype','Solitaire','Xbox','ZuneMusic','ZuneVideo','FeedbackHub','TCUI')
#endregion


#Finish initialization
Write-Host -ForegroundColor DarkGray "$ScriptName $ScriptVersion $WindowsPhase"
#Start OSDCloud
Write-Host -ForegroundColor Gray "Windows 11 Enterprise Retail 22H2 nb-no is being installed now."
Start-OSDCloud -OSLanguage nb-no -OSBuild 22H2 -OSEdition Enterprise -OSLicense Retail -SkipODT -OSVersion 'Windows 11' -ZTI -SkipAutopilot
#================================================
#   WinPE PostOS Sample
#   OOBEDeploy Offline Staging
#================================================
$Params = @{
    Autopilot = $false
    RemoveAppx = $appx2remove
    UpdateDrivers = $false
    UpdateWindows = $false
}
Start-OOBEDeploy @Params

iex (irm winget.osdcloud.com)

winget install --id Git.Git -e --source winget --silent 

<#
#================================================
#   PostOS
#   Audit Mode OOBEDeploy
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
            <Path>PowerShell -Command "Install-Module OSD -Force"</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>3</Order>
            <Description>OOBEDeploy</Description>
            <Path>PowerShell -Command "Start-OOBEDeploy -AddNetFX3 -UpdateDrivers -UpdateWindows"</Path>
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

#>
