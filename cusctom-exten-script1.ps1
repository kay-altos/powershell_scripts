<#
    .SYNOPSIS
        1. Office16 Activation
#>

Param (
    [string]$nop
)

Start-Transcript

if ((Test-Path  "C:\campinstall.lock") -ne $True){
Invoke-Command -ScriptBlock {cscript //B "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act}
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose

New-Item "C:\campinstall.lock"
}





Stop-Transcript
