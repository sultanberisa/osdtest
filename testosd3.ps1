<#PSScriptInfo
.VERSION 23.6.10.1
.GUID 9670c013-d1b1-4f5d-9bd0-0fa185b9f203
.AUTHOR David Segura @SeguraOSD
.COMPANYNAME osdcloud.com
.COPYRIGHT (c) 2023 David Segura osdcloud.com. All rights reserved.
.TAGS OSDeploy OSDCloud WinPE OOBE Windows AutoPilot
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/OSD
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri sandbox.osdcloud.com)
This is abbreviated as
powershell iex (irm sandbox.osdcloud.com)
#>
# URL ORIGINAL: start.osdcloud.com
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    PowerShell Script which supports the OSDCloud environment
.DESCRIPTION
    PowerShell Script which supports the OSDCloud environment
.NOTES
    Version 23.6.10.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/sandbox.osdcloud.com.ps1
.EXAMPLE
    powershell iex (irm sandbox.osdcloud.com)
#>
[CmdletBinding()]
param()
$ScriptName = 'sandbox.osdcloud.com'
$ScriptVersion = '23.6.10.1'

#region Initialize
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$ScriptName.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

if ($env:SystemDrive -eq 'X:') {
    $WindowsPhase = 'WinPE'
}
else {
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($env:UserName -eq 'defaultuser0') {$WindowsPhase = 'OOBE'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {$WindowsPhase = 'Specialize'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') {$WindowsPhase = 'AuditMode'}
    else {$WindowsPhase = 'Windows'}
}

Write-Host -ForegroundColor Green "[+] $ScriptName $ScriptVersion ($WindowsPhase Phase)"
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
#endregion

#region Admin Elevation
$whoiam = [system.security.principal.windowsidentity]::getcurrent().name
$isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if ($isElevated) {
    Write-Host -ForegroundColor Green "[+] Running as $whoiam (Admin Elevated)"
}
else {
    Write-Host -ForegroundColor Red "[!] Running as $whoiam (NOT Admin Elevated)"
    Break
}
#endregion

#region Transport Layer Security (TLS) 1.2
Write-Host -ForegroundColor Green "[+] Transport Layer Security (TLS) 1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
#endregion

#region WinPE
if ($WindowsPhase -eq 'WinPE') {
    #Process OSDCloud startup and load Azure KeyVault dependencies
   # osdcloud-StartWinPE -OSDCloud
   # Write-Host -ForegroundColor Cyan "To start a new PowerShell session, type 'start powershell' and press enter"
   # Write-Host -ForegroundColor Cyan "Start-OSDCloud, Start-OSDCloudGUI, or Start-OSDCloudAzure, can be run in the new PowerShell window"
    Write-Host -ForegroundColor Cyan "TESTESTESTSULTAN"
    #Stop the startup Transcript.  OSDCloud will create its own
    $null = Stop-Transcript -ErrorAction Ignore

    #Start OSDCloud and pass all the parameters except the Language to allow for prompting
    Start-OSDCloud -OSVersion 'Windows 10' -OSBuild 22H2 -OSEdition Enterprise -OSLanguage nb-no -SkipAutopilot $true -SkipODT $true -Restart

    Restart-Computer

}
#endregion

#region Specialize
if ($WindowsPhase -eq 'Specialize') {
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region AuditMode
if ($WindowsPhase -eq 'AuditMode') {
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region OOBE
<#if ($WindowsPhase -eq 'OOBE') {
    #Load everything needed to run AutoPilot and Azure KeyVault
    #osdcloud-StartOOBE -Display -Language -DateTime -InstallWinGet -WinGetUpgrade -WinGetPwsh

    osdcloud-RemoveAppx -Basic
    osdcloud-NetFX
 
    $null = Stop-Transcript -ErrorAction Ignore

    osdcloud-RestartComputer
}#>
#endregion

<#

[OSDCloud]: PS C:\WINDOWS\system32> iex (irm start.osdcloud.com)
[+] sandbox.osdcloud.com 23.6.10.1 (Windows Phase)
[+] functions.osdcloud.com 23.6.10.1 (Windows Phase)
[+] Running as VIKEN\sultanb (Admin Elevated)
[+] Transport Layer Security (TLS) 1.2
[OSDCloud]: PS C:\WINDOWS\system32> Get-Command osdcloud-*

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           osdcloud-ShowAutopilotInfo
Function        osdcloud-addserviceui
Function        osdcloud-GetAutopilotEvents
Function        osdcloud-GetKeyVaultSecretList
Function        osdcloud-HPBIOSDetermine
Function        osdcloud-HPBIOSEXEDownload
Function        osdcloud-HPBIOSSetSetting
Function        osdcloud-HPBIOSUpdate
Function        osdcloud-HPIADownload
Function        osdcloud-HPIAExecute
Function        osdcloud-HPIAOfflineSync
Function        osdcloud-HPSetupCompleteAppend
Function        osdcloud-HPTPMBIOSSettings
Function        osdcloud-HPTPMDetermine
Function        osdcloud-HPTPMDowngrade
Function        osdcloud-HPTPMDownload
Function        osdcloud-HPTPMEXEDownload
Function        osdcloud-HPTPMEXEInstall
Function        osdcloud-HPTPMUpdate
Function        osdcloud-InstallModuleAutopilot
Function        osdcloud-InstallModuleAzAccounts
Function        osdcloud-InstallModuleAzKeyVault
Function        osdcloud-InstallModuleAzResources
Function        osdcloud-InstallModuleAzStorage
Function        osdcloud-InstallModuleAzureAD
Function        osdcloud-InstallModuleHPCMSL
Function        osdcloud-InstallModuleMSGraphAuthentication
Function        osdcloud-InstallModuleMSGraphDeviceManagement
Function        osdcloud-InstallModuleOSD
Function        osdcloud-InstallModulePester
Function        osdcloud-InstallNuget
Function        osdcloud-InstallPackageManagement
Function        osdcloud-InstallPowerShellModule
Function        osdcloud-InstallPwsh
Function        osdcloud-InstallScriptAutopilot
Function        osdcloud-InstallWinGet
Function        osdcloud-InvokeKeyVaultSecret
Function        osdcloud-RemoveAppx
Function        osdcloud-RenamePC
Function        osdcloud-RestartComputer
Function        osdcloud-SetExecutionPolicy
Function        osdcloud-SetPowerShellProfile
Function        osdcloud-ShowAutopilotProfile
Function        osdcloud-StopComputer
Function        osdcloud-TestAutopilotProfile
Function        osdcloud-TestHPIASupport
Function        osdcloud-TrustPSGallery
Function        osdcloud-UpdateDefender
Function        osdcloud-UpdateDefenderStack
Function        osdcloud-UpdateModuleFilesManually

#>

#region Windows
<#if ($WindowsPhase -eq 'Windows') {
    #Load OSD and Azure stuff
    osdcloud-SetExecutionPolicy
    osdcloud-TrustPSGallery
    osdcloud-InstallWinGet
    osdcloud-InstallNuget
    osdcloud-InstallPackageManagement
    winget install --id Git.Git --exact --silent
    osdcloud-InstallPowerShellModule -Name OSD
    $null = Stop-Transcript -ErrorAction Ignore
}#>
#endregion

# from winget.osdcloud.com
#region OOBE
if ($WindowsPhase -eq 'OOBE') {
    osdcloud-RemoveAppx -Basic
    osdcloud-SetExecutionPolicy
    osdcloud-SetPowerShellProfile
    osdcloud-InstallPackageManagement
    osdcloud-TrustPSGallery
    osdcloud-InstallPowerShellModule -Name Pester
    osdcloud-InstallPowerShellModule -Name PSReadLine
    osdcloud-InstallWinGet

    if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor Green "[+] winget upgrade --all --accept-source-agreements --accept-package-agreements"
        winget upgrade --all --accept-source-agreements --accept-package-agreements
        Write-Host -ForegroundColor Green 'winget install --id Git.Git --exact --silent'
        winget install --id Git.Git --exact --silent
    }
    osdcloud-InstallPwsh
    Write-Host -ForegroundColor Green "[+] winget.osdcloud.com Complete"
    $null = Stop-Transcript -ErrorAction Ignore
    osdcloud-RestartComputer
}
#endregion

#region Windows
if ($WindowsPhase -eq 'Windows') {
    osdcloud-SetExecutionPolicy
    osdcloud-SetPowerShellProfile
    osdcloud-InstallPackageManagement
    osdcloud-TrustPSGallery
    osdcloud-InstallPowerShellModule -Name Pester
    osdcloud-InstallPowerShellModule -Name PSReadLine
    osdcloud-InstallWinGet
    if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor Green '[+] winget upgrade --all --accept-source-agreements --accept-package-agreements'
        winget upgrade --all --accept-source-agreements --accept-package-agreements
        Write-Host -ForegroundColor Green 'winget install --id Git.Git --exact --silent'
        winget install --id Git.Git --exact --silent
    }
    osdcloud-InstallPwsh
    Write-Host -ForegroundColor Green "[+] winget.osdcloud.com Complete"
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

# end from winget.osdcloud.com