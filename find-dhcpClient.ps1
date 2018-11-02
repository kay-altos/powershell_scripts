Import-Module DhcpServer
<#
    CliantId format: XX-YY-ZZ-VV-FF-LL
#>

$ClientId = "00-21-91-80-d4-74"
#$IPAddress = "172.18.112.21"

if(-not ([string]::IsNullOrEmpty($ClientId))){
    $Scops = $(Get-DhcpServerv4Scope -ComputerName "dvorec-dc3.dvorec.net").ScopeId
    ForEach ($Scop in $Scops) 
    {
	    Get-DhcpServerv4Lease -ComputerName "dvorec-dc3.dvorec.net" -ScopeId $scop.IPAddressToString -ClientId $ClientId -ErrorVariable err -ErrorAction SilentlyContinue
       
    }

     Remove-Variable -Name ClientId
} elseif (-not ([string]::IsNullOrEmpty($IPAddress))){

    Get-DhcpServerv4Lease -ComputerName "dvorec-dc3.dvorec.net" -IPAddress $IPAddress -ErrorVariable err -ErrorAction SilentlyContinue

    Remove-Variable -Name IPAddress
}
