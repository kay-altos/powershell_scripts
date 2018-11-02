Start-Transcript
param
(
    [string]$winkey,
    [string]$o2016key
)


Invoke-Command -ScriptBlock {cscript //B "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act}

Stop-Transcript
