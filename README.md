
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
    - The command above will output the environment variables which you will export and save in a ~/.bashrc file. Export and save the appid(client_id), password (client_secret), subscription_id, tenant_id to the file.
    - To extend the ~/.bashrc file, run nano ~/.bashrc file.
    - fill out and save the environment variables: example:
          export ARM_TENANT_ID=###############################
          export ARM_SUBSCRIPTION_ID=########################
          export ARM_CLIENT_ID=############################
          export ARM_CLIENT_SECRET=######################
    - run source ~/.bashrc to source the file and then env to check if the environment variables are set.

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
    - Once complete, run terraform show to view and inspect the state of your infrastructure    
5. Destroy all the Resources  
    - Destroy all the resources built by Terraform using terraform Destroy
    - Destroy the Packer image by running: az image delete -g packer-rg -n packer_image_name
### Output
The following resources will be built:

1. Main Load balancer with a front end IP configuration
2. Backend address pool.
3. 2 Lb health probes
4. Load balancer security rules
5. 2 virtual virtual Machines
6. 2 Network Interface cards
7. Security Group with Inbound and Outbound security rules
8. Main Resource group
9. Public IP address
10. Subnet
- To get any of the output variables, define the output variable in the output.tf file.
- run terraform refresh and the output variable should be displayed:

    Outputs:
    location = "eastus"
    main_public_ip = "52.188.130.207"


11. Topology: ![topology](https://user-images.githubusercontent.com/41089682/110250560-7fe13700-7f41-11eb-8f01-9f81ee7e8ebd.PNG)
