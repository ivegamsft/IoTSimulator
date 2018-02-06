#
# PushImageToACR.ps1
#
Login-AzureRmAccount
Select-AzureRmSubscription -Subscription "d8227dbe-9b3f-4f16-91a7-78436347d345"

$rgName = "rg_iot2"
$acrName = "acriot2srp"

$acr = Get-AzureRmContainerRegistry -ResourceGroupName $rgName -RegistryName $acrName
$acrImageName = $acr.LoginServer + "/coresimulateddevice:v1"

docker tag coresimulateddevice $acrImageName

$acrCreds = Get-AzureRmContainerRegistryCredential -RegistryName $acrName -ResourceGroupName $rgName

docker login $acr.LoginServer -u $acrCreds.Username -p $acrCreds.Password
docker push $acrImageName