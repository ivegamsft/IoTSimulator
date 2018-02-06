#
# DeployACIDevices.ps1
#
Login-AzureRmAccount
Select-AzureRmSubscription -Subscription "d8227dbe-9b3f-4f16-91a7-78436347d345"

az login 
az account set --subscription "d8227dbe-9b3f-4f16-91a7-78436347d345"

$rgName = "rg_iot2"
$acrName = "acriot2srp"
$location = "westus"
$imageName = "acriot2srp.azurecr.io/coresimulateddevice:v1"
$iotHubUri = "ioth-ingest.azure-devices.net"
$aksName = "aks-iot2"
$aksLocation = "southcentralus"

$deviceName = @('model-a-0', 'model-a-1','model-a-2','model-a-3','model-a-4','model-a-5','model-b-0', 'model-b-1','model-b-2','model-b-3','model-b-4','model-b-5','model-c-0', 'model-c-1','model-c-2','model-c-3','model-c-4','model-c-5')
$keys = @('b5gUNEtGGNmboSLSnGsdUsO+88BwkvtYx8QlQNNJrOM=', 'pJIoKCYZlLEeJxrmIi31zUIoyviNE4ei9gKtJZG0BZI=', 'ofBiSiKeOaPhnNJquhbVcDAckVHdL+53FbkYdnebkKY=', 'KMh5j8ERwoajC0fl50bSkKPFOByuzGGVW0TaH5kqeI4=', 'l/etIKB8MojLDYEo1DFfGye6sWISr6G7vA+4dgv0GBQ=', 'XBJPIOls0sjpXR4yfZNugfpT/t2w20G/HzPhr/6Wr7I=', 'iogFZIZHJt+GcQFryiueJ76qplY4vPYRtMg4HYUgej0=', 'WZTLFgoucAqpNef+vf+WOS5KP32CgFWOYJRuZFBjt1A=', 'hyxmMSP3H++Ge9g0N8oI4105BOW8CvKSt4ljIEhLyVw=', 'N9kn3G4ocrROiGc3bzMdukbiEY+ZPT2WnXoFZ99aDzw=', 'tB6GgWny8MfCumQc3tIu0B/Uq3+aNad6geYrKr1+nHY=', 'IeAIKLB1wpkwTq3wh+KUyDgyiK1r04hX9VOEF373vzE=', 'hs01ndyUBhIMKnT2Cql1HWASS/Xt+TblG2QSuq/DVO4=', 'lTpsCqmfLbqK8kG7XIdozyWUNydYJWQrxFI4Kaum8ug=', '2tnhF1ZfZ0ZvMC9OR+HmZxkqh6mwj5gkDUa3M466xfE=', 'JUEeDNCzoyxrQfPD/+9qQutmfT9lrJfr9QWO03/y1Ls=', '9rN5HtdTPbLK3/nDc+accY+C02xKeK98U3Dyja7jaHE=', 'iCPMJe3B7NvfGIUl6x9dmSFcbJI0RWsNW+ZVtmam3rc=');

$acr = Get-AzureRmContainerRegistry -ResourceGroupName $rgName -Name $acrName
$loginServer = $acr.LoginServer
$acrCreds = Get-AzureRmContainerRegistryCredential -RegistryName $acrName -ResourceGroupName $rgName 
$secpasswd = ConvertTo-SecureString $acrCreds.Password -AsPlainText -Force
$acrcred = New-Object System.Management.Automation.PSCredential ($acrCreds.Username, $secpasswd)

##Create a single container to test
#Write-Host "deviceName: " $deviceName[0] 
#Write-Host "deviceLat: "  $latitude[0] 
#Write-Host "deviceLong: " $longitude[0] 
#Write-Host "key: " $keys[0]
#$EnvironmentHash = @{"IOTHUB_URI"=$loginServer;"DEVICE_NAME"=$deviceName[0];"DEVICE_KEY"=$keys[0];"DEVICE_LATITUDE"=$latitude[0];"DEVICE_LONGITUDE"=$longitude[0]}
#New-AzureRmContainerGroup -ResourceGroupName $rgName -Name $deviceName[$i] -Image $imageName `
#    -Location $location -OsType Linux -Cpu 1 -MemoryInGB 1 -IpAddressType Public -RegistryCredential $acrcred -EnvironmentVariable $EnvironmentHash
##Show the Console output from the first container
#Get-AzureRmContainerInstanceLog -ContainerGroupName $deviceName[0] -ResourceGroupName $rgName
##Remove the test ACI
#Remove-AzureRmContainerGroup -ResourceGroupName $rgName -Name $deviceName[0]


#Create all the containers
for($i=0; $i -lt $deviceName.Length; $i++)
{
    Write-Host "deviceName: " $deviceName[$i] 
    Write-Host "deviceLat: "  $latitude[$i] 
    Write-Host "deviceLong: " $longitude[$i] 
    Write-Host "key: " $keys[$i]
    $EnvironmentHash = @{"IOTHUB_URI"=$loginServer;"DEVICE_NAME"=$deviceName[$i];"DEVICE_KEY"=$keys[$i]}
    New-AzureRmContainerGroup -ResourceGroupName $rgName -Name $deviceName[$i] -Image $imageName `
    -Location $location -OsType Linux -Cpu 1 -MemoryInGB 1 -IpAddressType Public -RegistryCredential $acrcred -EnvironmentVariable $EnvironmentHash
}


##Clean up Containers when done testing
for($i=0; $i -lt $deviceName.Length; $i++)
{
    Remove-AzureRmContainerGroup -ResourceGroupName $rgName -Name $deviceName[$i]
}
