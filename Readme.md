# IoT Simulator
Use this sample to deploy a set of sample IoT devices to ACI or AKS for load or end-to-end testing.

## Code samples
[CoreSimulatedDevice](../CoreSimulatedDevice/) - Sample device that can be deployed as a docker container. 
Uses environment variables to launch and connect to an IoT Hub and send sample messages.

[CreateDevices](../CreateDevices/) - Sample program that can be used to create and register several devices to an IoT Hub

Deployment scripts
* [DeployACIDevices.ps1](../DeploymentScripts/DeployACIDevices.ps1) - Used to deploy containers to an Azure Container Instances
* [DeployAKSwithImage.ps1](../DeploymentScripts/DeployACIDevices.ps1) - Used to deploy containers to an Azure Kuberbetes Service
* [PushImageToACR.ps1](../DeploymentScripts/DeployACIDevices.ps1) - Used to push a tagged simulated device container to an Azure Container Registry

## Deployment and usage

### Pre-reqs
1. Create an Azure AKS cluster
1. Create an Azure Container Instance resource
1. Create an Azure IoT Hub
1. Create an Azure Container Registry

### Running the sample
1. Build the CoreSimulatedDevice container
1. Use the CreateDevices sample to create a set of sample devices in IoT Hub
1. Modify the variables in the PushToACR.ps1 script to your distinct values
1. Use the PushToACR.ps1 script to push the built container to ACR
1. Modify the variables in the DeployACIDevices.ps1 script to your distinct values
1. Use the DeployACIDevices.ps1 script to launch the simulated device containers

