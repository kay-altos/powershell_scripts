Start-Transcript
<#
    .SYNOPSIS
        1. Office16 Activation
#>


Param (
    [string]$nop
)


Invoke-Command -ScriptBlock {cscript //B "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act}

Stop-Transcript
