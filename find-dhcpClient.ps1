Import-Module DhcpServer
<#
    CliantId format: XX-YY-ZZ-VV-FF-LL
#>
$dhcpServer = ""
$ClientId = "00-21-91-80-d4-74"
#$IPAddress = "172.18.112.21"

if(-not ([string]::IsNullOrEmpty($ClientId))){
    $Scops = $(Get-DhcpServerv4Scope -ComputerName $dhcpServer).ScopeId
    ForEach ($Scop in $Scops) 
    {
	    Get-DhcpServerv4Lease -ComputerName $dhcpServer -ScopeId $scop.IPAddressToString -ClientId $ClientId -ErrorVariable err -ErrorAction SilentlyContinue
       
    }

     Remove-Variable -Name ClientId
} elseif (-not ([string]::IsNullOrEmpty($IPAddress))){

    Get-DhcpServerv4Lease -ComputerName $dhcpServer -IPAddress $IPAddress -ErrorVariable err -ErrorAction SilentlyContinue

    Remove-Variable -Name IPAddress
}
