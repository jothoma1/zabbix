# Powershell script for Zabbix agents.

# Thanks to https://github.com/SpookOz/zabbix-wininventory

## This script will read a number of hardware inventory items from Windows and report them to Zabbix. It will also fill out the inventory tab for the host with the information it gathers.

#### This script gather only a few information, from virtual machine OS and in order to search for possible CVE

# ------------------------------------------------------------------------- #
# Variables
# ------------------------------------------------------------------------- #

# Change $ZabbixInstallPath to wherever your Zabbix Agent is installed

$ZabbixInstallPath = "$Env:Programfiles\Zabbix Agent"
$ZabbixConfFile = "$Env:Programfiles\Zabbix Agent"

# Do not change the following variables unless you know what you are doing

$Sender = "$ZabbixInstallPath\zabbix_sender.exe"
$Senderarg1 = '-vv'
$Senderarg2 = '-c'
$Senderarg3 = "$ZabbixConfFile\zabbix_agentd.conf"
$Senderarg4 = '-i'
$Senderarg5 = '-k'
$SenderargInvStatus = '\wininvstatus.txt'

# ------------------------------------------------------------------------- #
# This part gets the inventory data and writes it to a temp file
# ------------------------------------------------------------------------- #

$Winarch = Get-CimInstance Win32_OperatingSystem | Select-Object OSArchitecture | foreach { $_.OSArchitecture }
$WinOS = Get-CimInstance Win32_OperatingSystem | Select-Object Caption | foreach { $_.Caption }
$WinBuild = Get-CimInstance Win32_OperatingSystem | Select-Object BuildNumber | foreach { $_.BuildNumber }

$outputWinOS = "- inv.WinOS "
$outputWinOS += '"'
$outputWinOS += "$($WinOS)"
$outputWinOS += '"'

Write-Output "- inv.WinArch $Winarch" | Out-File -Encoding "ASCII" -FilePath $env:temp$SenderargInvStatus
Add-Content $env:temp$SenderargInvStatus $outputWinOS
Add-Content $env:temp$SenderargInvStatus "- inv.WinBuild $WinBuild"

# ------------------------------------------------------------------------- #
# This part sends the information in the temp file to Zabbix
# ------------------------------------------------------------------------- #

& $Sender $Senderarg1 $Senderarg2 $Senderarg3 $Senderarg4 $env:temp$SenderargInvStatus -s "$env:computername"
