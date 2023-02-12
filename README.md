# XYZ Infra
This is a project to deploy an Azure AKS cluster with FluxCD installed and an example application.

The configuration will:
1. Create an AKS cluster.
2. Create a AKS extension registration for Flux.
3. Create a Flux configuration to deploy components from clusters/dev-cluster.
4. Ensure nginx ingress controller from common components as a helm release with a public ip address.
5. Ensure xyz-webapp helm release is deployed.

Below an overview of the directory structure with an explaination of the directory contents.
```
├── apps
│   └── xyz-webapp <- Defines how to deploy with flux
├── clusters
│   ├── common <- Common components to deploy with flux, (e.g. nginx-ingress)
│   └── dev-cluster <- Reference apps to deploy
└── terraform <- AKS deployment
    └── setup <- Azure SPN creation
```

# Getting Started
These instructions should help you run the project locally for testing purposes or running it through automation.

# Prerequisites
The terraform for the project can be run locally by a user with sufficient permissions or with a service principal which can be created with sufficient permissions to run it. Ensure you have Azure cli installed and can log in to your target Azure tenant.

## Running as an Azure Service Principal
The instructions to create an spn use the _current_ subscription. Please change to an appropriate subscription where you have the ability to create a service principal and assign IAM roles before running it.

```
az login
az account list
...
az account set --subscription <subscription>
```

To create the service principal assign roles and perform the provider registration:
```
cd ./terraform/setup
terraform apply
```
Use the newly provisioned SPN credentials and subscription information:
```
export ARM_CLIENT_ID=$(terraform output -raw client_id)
export ARM_CLIENT_SECRET=$(terraform output -raw client_secret)
export ARM_TENANT_ID=$(terraform output -raw tenant_id)
export ARM_SUBSCRIPTION_ID=$(terraform output -raw subscription_id)
```

### Set Github Actions Secrets
Optionally, if you want to run the action. Within the repo secret variables within the repo are required for azure authentication.
```
gh secret set AZURE_CLIENT_ID --body "$ARM_CLIENT_ID"
gh secret set AZURE_CLIENT_SECRET --body "$ARM_CLIENT_SECRET"
gh secret set AZURE_SUBSCRIPTION_ID --body "$ARM_TENANT_ID"
gh secret set AZURE_TENANT_ID --body "$ARM_SUBSCRIPTION_ID"
```


___


## Running as Global Admin
If you are a global admin or already have sufficient permissions in your azure tenant and want to run this project you will at least need to ensure the providers are registered. Then you can simply run the terraform within the `terraform` directory to interact with it further.
```
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KubernetesConfiguration
```

```
cd terraform
terraform apply
```

# Output
Upon completion and reconciliation of the required charts, you should be able to connect to the public IP address. Note that it takes a minute or two for the reconciliation process to complete.  From the terraform directory:

```
curl -s --header "Host: xyz.local" http://$(terraform output --raw public_ip) | jq
```


# Reference Material
[GitOps Flux v2 configurations with AKS and Azure Arc-enabled Kubernetes](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-gitops-flux2)
