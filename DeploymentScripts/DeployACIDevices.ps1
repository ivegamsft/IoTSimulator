#
# DeployACIDevices.ps1
#

$SubscriptionId = "[YOUR SUB ID]"
$rgName = "[RESOURCE GROUP NAME]"
$acrName = "[ACR NAME]"
$location = "[REGION]"
$acrImageName = "[ACR IMAGE NAME]"
$iotHubUri = "[IOT HUB URI]"
$aksName = "[AKS NAME]"
$aksLocation = "[AKS REGION]"
$aksNodeCount = "[AKS NODES TO DEPLOY]"
# REPLACE WITH DEVICE NAMES OR GENERATE THEM
$deviceNames = @('device-0', 'device-1')
$keys = @('IOT-KEY-1', 'IOT-KEY-2');


Login-AzureRmAccount
Select-AzureRmSubscription -Subscription $SubscriptionId

az login 
az account set --subscription $SubscriptionId

$acr = Get-AzureRmContainerRegistry -ResourceGroupName $rgName -Name $acrName
$loginServer = $acr.LoginServer
$acrCreds = Get-AzureRmContainerRegistryCredential -RegistryName $acrName -ResourceGroupName $rgName 
$secpasswd = ConvertTo-SecureString $acrCreds.Password -AsPlainText -Force
$acrcred = New-Object System.Management.Automation.PSCredential ($acrCreds.Username, $secpasswd)

##Create a single container to test
#Write-Host "deviceName: " $deviceNames[0] 
#Write-Host "deviceLat: "  $latitude[0] 
#Write-Host "deviceLong: " $longitude[0] 
#Write-Host "key: " $keys[0]
#$EnvironmentHash = @{"IOTHUB_URI"=$loginServer;"DEVICE_NAME"=$deviceNames[0];"DEVICE_KEY"=$keys[0];"DEVICE_LATITUDE"=$latitude[0];"DEVICE_LONGITUDE"=$longitude[0]}
#New-AzureRmContainerGroup -ResourceGroupName $rgName -Name $deviceNames[$i] -Image $acrImageName `
#    -Location $location -OsType Linux -Cpu 1 -MemoryInGB 1 -IpAddressType Public -RegistryCredential $acrcred -EnvironmentVariable $EnvironmentHash
##Show the Console output from the first container
#Get-AzureRmContainerInstanceLog -ContainerGroupName $deviceNames[0] -ResourceGroupName $rgName
##Remove the test ACI
#Remove-AzureRmContainerGroup -ResourceGroupName $rgName -Name $deviceNames[0]


#Create all the containers
for($i=0; $i -lt $deviceNames.Length; $i++)
{
    Write-Host "deviceName: " $deviceNames[$i] 
    Write-Host "deviceLat: "  $latitude[$i] 
    Write-Host "deviceLong: " $longitude[$i] 
    Write-Host "key: " $keys[$i]
    $EnvironmentHash = @{"IOTHUB_URI"=$loginServer;"DEVICE_NAME"=$deviceNames[$i];"DEVICE_KEY"=$keys[$i]}
    New-AzureRmContainerGroup -ResourceGroupName $rgName -Name $deviceNames[$i] -Image $acrImageName `
    -Location $location -OsType Linux -Cpu 1 -MemoryInGB 1 -IpAddressType Public -RegistryCredential $acrcred -EnvironmentVariable $EnvironmentHash
}


##Clean up Containers when done testing
for($i=0; $i -lt $deviceNames.Length; $i++)
{
    Remove-AzureRmContainerGroup -ResourceGroupName $rgName -Name $deviceNames[$i]
}
