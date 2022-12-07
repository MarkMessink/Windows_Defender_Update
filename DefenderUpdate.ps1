<#
.SYNOPSIS
	Force Windows Defender Update
	
	FileName:    DefenderUpdate.ps1
    Author:      Mark Messink
    Contact:     
    Created:     2022-05-04
    Updated:     2023-02-02

    Version history:
    1.0.0 - (2022-05-04) Initial Script
	1.0.1 - (21-12-2022) Script verniewd
	1.1.0 - 

.DESCRIPTION
	Update Windows Defender als de versie lager is dan opgegeven $MinVersion in de variabelen
	Check huidige versie op een bijgewerkte versie van Windows via Powershell: (Get-MpComputerStatus).AntivirusSignatureVersion

.PARAMETER
	<beschrijf de parameters die eventueel aan het script gekoppeld moeten worden>

.INPUTS


.OUTPUTS
	logfiles:
	PSlog_<naam>	Log gegenereerd door een powershell script
	INlog_<naam>	Log gegenereerd door Intune (Win32)
	AIlog_<naam>	Log gegenereerd door de installer van een applicatie bij de installatie van een applicatie
	ADlog_<naam>	Log gegenereerd door de installer van een applicatie bij de de-installatie van een applicatie
	Een datum en tijd wordt automatisch toegevoegd

.EXAMPLE
	./scriptnaam.ps1

.LINK Information

.NOTES
	WindowsBuild:
	Het script wordt uitgevoerd tussen de builds LowestWindowsBuild en HighestWindowsBuild
	LowestWindowsBuild = 0 en HighestWindowsBuild 50000 zijn alle Windows 10/11 versies
	LowestWindowsBuild = 19000 en HighestWindowsBuild 19999 zijn alle Windows 10 versies
	LowestWindowsBuild = 22000 en HighestWindowsBuild 22999 zijn alle Windows 11 versies
	Zie: https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information

#>

#################### Variabelen #####################################
$logpath = "C:\IntuneLogs"
$NameLogfile = "PSlog_DefenderUpdate.txt"
$LowestWindowsBuild = 0
$HighestWindowsBuild = 50000
#minimum AntivirusSignatureVersion
$MinVersion = "1.379.0.0" # nov 2022



#################### Einde Variabelen ###############################


#################### Start base script ##############################
### Niet aanpassen!!!

# Prevent terminating script on error.
$ErrorActionPreference = 'Continue'

# Create logpath (if not exist)
If(!(test-path $logpath))
{
      New-Item -ItemType Directory -Force -Path $logpath
}

# Add date + time to Logfile
$TimeStamp = "{0:yyyyMMdd-HHmm}" -f (get-date)
$logFile = "$logpath\" + "$TimeStamp" + "_" + "$NameLogfile"

# Start Transcript logging
Start-Transcript $logFile -Append -Force

# Start script timer
$scripttimer = [system.diagnostics.stopwatch]::StartNew()

# Controle Windows Build
$WindowsBuild = [System.Environment]::OSVersion.Version.Build
Write-Output "------------------------------------"
Write-Output "Windows Build: $WindowsBuild"
Write-Output "------------------------------------"
If ($WindowsBuild -ge $LowestWindowsBuild -And $WindowsBuild -le $HighestWindowsBuild)
{
#################### Start base script ################################

#################### Start uitvoeren script code ####################
Write-Output "-------------------------------------------------------------------------------------"
Write-Output "### Start uitvoeren script code ###"
Write-Output "-------------------------------------------------------------------------------------"

	Write-Output "-------------------------------------------------------------------"
	Write-Output "----- Check Defender Versions"
	Get-MpComputerStatus | select *updated, *version
	Write-Output "-------------------------------------------------------------------"
	
	# AntivirusSignatureVersion $MinVersion
	if((Get-MpComputerStatus).AntivirusSignatureVersion -le $MinVersion){
	Write-Output "----- Update Defender, AntivirusSignatureVersion is lower then $MinVersion"
	Update-MpSignature -verbose
	Write-Output "-------------------------------------------------------------------"
	Write-Output "----- Check New Defender Versions"
	Get-MpComputerStatus | select *updated, *version		
    Write-Output "-------------------------------------------------------------------"

	}
	Else {
	Write-Output "----- Defender not updated, version is $MinVersion or higher"
	Write-Output "-------------------------------------------------------------------"
	} 

Write-Output "-------------------------------------------------------------------------------------"
Write-Output "### Einde uitvoeren script code ###"
Write-Output "-------------------------------------------------------------------------------------"
#################### Einde uitvoeren script code ####################

#################### End base script #######################

# Controle Windows Build
}Else {
Write-Output "-------------------------------------------------------------------------------------"
Write-Output "### Windows Build versie voldoet niet, de script code is niet uitgevoerd. ###"
Write-Output "-------------------------------------------------------------------------------------"
}

#Stop and display script timer
$scripttimer.Stop()
Write-Output "------------------------------------"
Write-Output "Script elapsed time in seconds:"
$scripttimer.elapsed.totalseconds
Write-Output "------------------------------------"

#Stop Logging
Stop-Transcript
#################### End base script ################################

#################### Einde Script ################################### 
