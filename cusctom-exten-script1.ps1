<#
    .SYNOPSIS
        1. Office16 Activation
#>

Param (
    [string]$nop
)

Start-Transcript
Invoke-Command -ScriptBlock {cscript //B "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act}


for($iu = 2; $iu -le 4; $iu++){

    $PasswordU = "P@ssWord$iu"
    $Secure_string = ConvertTo-SecureString $PasswordU -AsPlainText -Force
    New-LocalUser "itcamp$iu" -Password $Secure_string  -FullName "Camp User $i" -Description "Camp User $i"
    Add-LocalGroupMember -Group "Administrators" -Member "itcamp$iu"
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member "itcamp$iu"
    echo "itcamp$iu"
    echo $PasswordU
}


Stop-Transcript
