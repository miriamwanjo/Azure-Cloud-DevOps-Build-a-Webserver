# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code


### Dependencies
1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Create a tagging policy that ensures all indexed resources in your subscription have tags and deny deployment if they don't.
    - run az policy assignment create --name policy-name --rules tagpolicy.json
    - run az policy assignment list to see if your policy has been created
2. Create a server image using Packer:
    - First you need to create a resource group where Packer will store the generated images:
      run az group create --name packerimage --location eastUS output jsonc
      *choose an azure location that is right for you depending on geography and pricing and availability.
    - Create a service principal to create the packer image - give a contributor role to your service principal.
      run: az ad sp create-for-rbac --name name --role="Contributor" --scopes="/subscriptions/$subcriptionId" --output json
      *if you are unsure of your subscription_id simply run az account list --output table
    - The command above will output the environment variables which you can simply use to fill out the client_id, client_secret, subscription_id, tenant_id on the server.json file.
3. Create a terraform template that contains information on how to create and deploy the infrastructure.
    - Ensure that the resource group you specified in the Packer image is the same image in terraform
    - There are two files that terraform reads from:
        - main.tf: contains the main configurations for your Infrastructure
        - var.tf: contains the variable definitions
4. Once both the Packer and Terraform templates are complete, its time to deploy:
    - First deploy your VM Packer image by running: packer build server.json
    - Then initialize Terraform: terraform init
    - then run terraform plan -out solution.plan to save the flag with the name solution.plan
    - Run terraform apply solution.plan to deploy your terraform Infrastructure
5. Destroy all the Resources  
    - Destroy all the resources built by Terraform using terraform Destroy
    - Destroy the Packer image by running: az image delete -g packer-rg -n packer_image_name
### Output
**Your words here**
