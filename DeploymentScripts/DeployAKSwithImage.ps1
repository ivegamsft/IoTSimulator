#
# DeployAKSwithImage.ps1
#
#
# DeployAKSwithImage.ps1
#
#'TY1GyS73FXmpffEDiENbR1+GHGrIWySwGXAynLu2Zwc=', 'bKSPn0MhNZSNOPRBRmR7/rj0XFak57hQ3rKp/fVljbM=', 'AnEeuhlW+YMVmaRHI4iMJTgt+Vks7KmvU1C9//qQEcQ=', 'BK9O/fq5nVHACj0Uwjrvat4HMPOOaUNBTZx8BujVy/c=', 'qxMatju9UzwXus782p8zFsMYhLdU+tVW1FCV4N65tb0=', 'sBbMsD/DGt0oQjK1LjlTyA3nmDQwao0Zxr0L0as72d4=', 'u2Zv3PPnuD/wXEvCOYsdq/Rmc0jFDTI67mLxzRUmId4=', '1Gys57yiXk7soh+if8ebXvj2d1xC9Ue1ToYQEyAbwqg=', 'z6vU6hBC55QDCxnJexGSQqFOCVTaO9YmCPDcg1fL7ck=', 'bzLsC+JOmlfCKhiBfa2ux4fJeYRx95oxzv08j6TDJ68=', 'f9crw2I8cS9nhul4YGha8KFe1KWcQrnU8RXu4VgC1z8=', '82dIU2PM0yjtuLjlAwhwxdFRrj5QA3G/cpuQvAw+YKY=', 'I929zHS/vpS/94R9JjAK7qteM7Xze4K5WOURE2WBndo=', 'LkZD9FGQkve67Bg4IpAztRrF9Z6ZW91v0kPdqRe7pVk=', '9aDHuuPYUNFDmKzucUN1CuBGW4BSuEVVkkw3+6WEFg4=', '5V+froHw3xGrtsUlcU4vT1fPMs1QxmKHi+4pyz9EHK8=', 'bPQFUM6Prjuq1lHBIvQOJMfLR2RBKq9XppPONJZm/qg=', 'xLx7FTaERwqVg1rmsIitzQuHukzP8Du9r7mm3NHFg5c=',

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


$installAKS = $true

#Create AKS Cluster
if($installAKS){
    az aks create --resource-group $rgName --name $aksName --node-count 2 --generate-ssh-keys --location $aksLocation
    az aks install-cli
}

az aks get-credentials -g $rgName -n $aksName

for($i=0; $i -lt ($deviceName.Length); $i++)
#for($i=0; $i -lt 2; $i++)
{
    Write-Host "deviceName: " $deviceName[$i] 
    Write-Host "deviceModel: "  $deviceName[$i].Substring(0,7)
    Write-Host "key: " $keys[$i]
    $dName = $deviceName[$i]
    $dModel = $deviceName[$i].Substring(0,7)
    $dKey = $keys[$i]
   # $EnvironmentHash = @{"IOTHUB_URI"=$iotHubUri;"DEVICE_NAME"=$deviceName[$i];"DEVICE_KEY"=$keys[$i];"DEVICE_MODEL"=$deviceName[$i].Substring(0,7)}
   # New-AzureRmContainerGroup -ResourceGroupName $rgName -Name $deviceName[$i] -Image $imageName `
   # -Location $location -OsType Linux -Cpu 1 -MemoryInGB 1 -IpAddressType Public -RegistryCredential $acrcred -EnvironmentVariable $EnvironmentHash

    kubectl run $deviceName[$i] --image=$imageName --env="IOTHUB_URI="$iotHubUri --env="DEVICE_NAME="$dName --env="DEVICE_MODEL="$dModel --env="DEVICE_KEY="$dKey

}

az aks browse -g $rgName -n $aksName
