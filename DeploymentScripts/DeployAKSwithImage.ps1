#
# DeployAKSwithImage.ps1
#
#
# DeployAKSwithImage.ps1
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

$installAKS = $true

#Create AKS Cluster
if($installAKS){
    az aks create --resource-group $rgName --name $aksName --node-count $aksNodeCount --generate-ssh-keys --location $aksLocation
    az aks install-cli
}

az aks get-credentials -g $rgName -n $aksName

for($i=0; $i -lt ($deviceNames.Length); $i++)
#for($i=0; $i -lt 2; $i++)
{
    Write-Host "deviceName: " $deviceNames[$i] 
    Write-Host "deviceModel: "  $deviceNames[$i].Substring(0,7)
    Write-Host "key: " $keys[$i]
    $dName = $deviceNames[$i]
    $dModel = $deviceNames[$i].Substring(0,7)
    $dKey = $keys[$i]

    kubectl run $deviceNames[$i] --image=$acrImageName --env="IOTHUB_URI="$iotHubUri --env="DEVICE_NAME="$dName --env="DEVICE_MODEL="$dModel --env="DEVICE_KEY="$dKey
}

az aks browse -g $rgName -n $aksName
