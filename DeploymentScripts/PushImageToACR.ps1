#
# PushImageToACR.ps1
#

$SubscriptionId = "[YOUR SUB ID]"
$rgName = "[RESOURCE GROUP NAME]"
$acrName = "[ACR NAME]"
$location = "[REGION]"
$acrImageName = "[ACR IMAGE NAME]"
$SimulatedDeviceName = "[YOUR SIMULATED DEVICE NAME]" # ie. coresimulateddevice
$SimulatedDeviceTag = "[YOUR SIMULATED DEVICE TAG]" # i.e. v1


Login-AzureRmAccount
Select-AzureRmSubscription -Subscription $SubscriptionId

$acr = Get-AzureRmContainerRegistry -ResourceGroupName $rgName -RegistryName $acrName
$acrImageName = $acr.LoginServer + "/" + $SimulatedDeviceName + ":" + $SimulatedDeviceTag

docker tag $SimulatedDeviceName $acrImageName

$acrCreds = Get-AzureRmContainerRegistryCredential -RegistryName $acrName -ResourceGroupName $rgName

docker login $acr.LoginServer -u $acrCreds.Username -p $acrCreds.Password
docker push $acrImageName