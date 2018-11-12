#create multiple Azure VM from the image - Create-MultipleAzureRMVMfromImage.ps1
#code start
function Get-PrintCard{

    Param(
        [string]$IpAddres,
        [string]$Username,
        [string]$Password
    )

    $printIpAddres= $IpAddres.PadRight($IpAddres.Length+(34-(10+$IpAddres.Length))," ")
    $printUsername= $Username.PadRight($Username.Length+(34-(20+$Username.Length))," ")
    $printPassword = $Password.PadRight($Password.Length+(34-(10+$Password.Length))," ")

    $pattern = "====================================`n`b"
    $pattern += "=								   =`n`b"
    $pattern += "=  Сервер: $printIpAddres=`n`b"
    $pattern += "=  Имя пользователя: $printUsername=`n`b"
    $pattern += "=  Пароль: $printPassword=`n`b"
    $pattern += "=                                  =`n`b"
    $pattern += "====================================`n`b"
    $pattern += ">--------------------------------------------------------------------`n`b"

return $pattern
}

#
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
#
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}
#
function Get-PasswordString(){
    $password = Get-RandomCharacters -length 8 -characters 'abcdefghiklmnoprstuvwxyz'
    $password += Get-RandomCharacters -length 1 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
    $password += Get-RandomCharacters -length 1 -characters '1234567890'
    $password += Get-RandomCharacters -length 1 -characters '!$&'
    #
    return Scramble-String $password
}
#
 function Get-RandomUserName(){
    #
    return "user$(Get-Random -Minimum 1000 -Maximum 100000)"
}
#

#const
$i = 1
$quantity = 2
$resourceGroup = "Certification"
$storageAccountName = "certstorageaccount"
$location = "westeurope"
$baseVmName = "VGCert"
$size = 'Standard_D4s_v3'
$storageType = 'Premium_LRS'
$skuName = "Standard_LRS"
$path = "D:\Cert-$(get-random)"
$imageName = "W10C8O16v5-image-20181027092335"
#end const

#
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup -AccountName $storageAccountName
#
$image = Get-AzureRmImage | Where-Object {$_.Name -eq $imageName}
#
New-Item -ItemType Directory -Path $path -force
#

$Logfile = $path + "\logfile.log"
write-host "Logfile+"

$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
	-Name $resourceGroup"_subnet" `
	-AddressPrefix 192.168.1.0/24
write-host "subnetConfig+"
#
Add-content $Logfile -value "subnetConfig: $subnetConfig"

$vnet = New-AzureRmVirtualNetwork `
	-ResourceGroupName $resourceGroup -Location $location `
	-Name $resourceGroup"-vNET" `
	-AddressPrefix 192.168.0.0/16 `
	-Subnet $subnetConfig `
    -Tag @{ CertOth="Other"}
write-host "vnet+"
Add-content $Logfile -value "vnet: $vnet"
#

while($i -le $quantity){
#
	$vmName = $baseVmName + $i
#
	
	Add-content $Logfile -value "==================START $vmName=================="
	Add-content $Logfile -value "VMName: $vmName"
#
	Add-content $Logfile -value "Logfile: $Logfile"
#
	$osDiskName = $vmName+"-OsDisk-"+$(Get-Random)
	Add-content $Logfile -value "osDiskName: $osDiskName"
#
	$LocalRdpFilePath =  $path + "\" + $vmName + ".rdp"
	Add-content $Logfile -value "LocalRdpFilePath: $LocalRdpFilePath"
#	
	$azVmUserName = Get-RandomUserName
	Add-content $Logfile -value "azVmUserName: $azVmUserName"
#
	$azVmPassword = Get-PasswordString
	Add-content $Logfile -value "azVmPassword: $azVmPassword"
#
	$secureStringPassword = $azVmPassword | ConvertTo-SecureString -asPlainText -Force
	$cred = New-Object System.Management.Automation.PSCredential($azVmUserName,$secureStringPassword)
	Add-content $Logfile -value "Cred +"
#
	
#Get publick ip
	$pip = New-AzureRmPublicIpAddress `
		-ResourceGroupName $resourceGroup `
		-Location $location `
		-Name "$vmName-pip-$(Get-Random)" `
		-AllocationMethod Static `
		-IdleTimeoutInMinutes 4 `
        -Tag @{ CertOth="Other"}
	Add-content $Logfile -value "pip +"
    write-host "pip+"

#set rule NSG RDP	
	$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig `
		-Name $vmName"-nsgRuleRDP"  -Protocol Tcp `
		-Direction Inbound `
		-Priority 1000 `
		-SourceAddressPrefix * `
		-SourcePortRange * `
		-DestinationAddressPrefix * `
		-DestinationPortRange 3389 `
		-Access Allow
	Add-content $Logfile -value "nsgRuleRDP +"
    write-host "nsgRuleRDP+"
#set NSG  
	$nsg = New-AzureRmNetworkSecurityGroup `
		-ResourceGroupName $resourceGroup `
		-Location $location `
		-Name $vmName"-NetworkSecurityGroup" `
		-SecurityRules $nsgRuleRDP `
        -Tag @{ CertOth="Other"}
	Add-content $Logfile -value "nsg +"
    write-host "nsg+"
#set NIC 
	$nic = New-AzureRmNetworkInterface `
		-Name $vmName"-Nic" `
		-ResourceGroupName $resourceGroup `
		-Location $location `
		-SubnetId $vnet.Subnets[0].Id `
		-PublicIpAddressId $pip.Id `
		-NetworkSecurityGroupId $nsg.Id `
        -Tag @{ CertOth="Other"}
	Add-content $Logfile -value "nic +"
    write-host "nic+"
###
	$vmConf = New-AzureRmVMConfig -VMName $vmName -VMSize $size | `
		Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | `
		Set-AzureRmVMSourceImage -Id $image.id | `
		Set-AzureRmVMOSDisk -Name $osDiskName -DiskSizeInGB 127 -CreateOption FromImage -Caching ReadWrite -StorageAccountType $storageType |`
		Set-AzureRmVMBootDiagnostics -Enable -ResourceGroupName $resourceGroup -StorageAccountName $storageAccount.StorageAccountName |`
		Add-AzureRmVMNetworkInterface -Id $nic.Id
	Add-content $Logfile -value "vmConf +"
    write-host "vmConf+"
###	
#create new VM
	New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConf -Tag @{ CertVM="Vm"}
    write-host "New-AzureRmVM+"
	Add-content $Logfile -value "vm +"
#
    $r = Get-AzureRmResource -ResourceName $osDiskName -ResourceGroupName $resourceGroup
    Set-AzureRmResource -Tag @{ CertOth="Other"} -ResourceId $r.ResourceId -Force
#
#GET RDP FILE  
    Start-Sleep -s 25
	Get-AzureRmRemoteDesktopFile -ResourceGroupName $resourceGroup -Name $vmName -LocalPath $LocalRdpFilePath
	Add-content $Logfile -value "RDP +"
#
	Set-AzureRMVMCustomScriptExtension -ResourceGroupName $resourceGroup `
		-VMName $vmName `
		-Location $location `
		-FileUri https://raw.githubusercontent.com/kay-altos/powershell_scripts/master/cusctom-exten-script1.ps1 `
		-Run 'cusctom-exten-script1.ps1' `
		-Name ScriptExtension1
	Add-content $Logfile -value "EXT +"
    write-host "EXT+"
    $publicIp123 = Get-AzureRmPublicIpAddress -Name $pip.Name -ResourceGroupName $resourceGroup
    Write-Host $publicIp123.IpAddress
    Add-content $Logfile -value $publicIp123.IpAddress
#
	Add-content $Logfile -value "==================STOP $vmName=================="

    $printCard = Get-PrintCard -IpAddres $publicIp123.IpAddress -Username $azVmUserName -Password $azVmPassword

    Add-content $Logfile -value $printCard

#
$i++
}
