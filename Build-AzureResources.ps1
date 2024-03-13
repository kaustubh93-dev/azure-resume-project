[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $ResourceGroup, # A mandatory parameter representing the name of the Azure resource group.

    [Parameter(Mandatory)]
    [string]
    $Subscription, # A mandatory parameter representing the Azure subscription.

    [Parameter(Mandatory)]
    [string]
    $StorageAccountName, # A mandatory parameter representing the name of the storage account.

    [Parameter()]
    [string]
    $StorageAccountSku = 'Standard_LRS', # An optional parameter with a default value of ‘Standard_LRS’, representing the storage account SKU (Standard Locally Redundant Storage in this case).

    [Parameter(Mandatory)]
    [string]
    $Region,  # A mandatory parameter representing the Azure region.

    [Parameter(Mandatory)]
    [string]
    $WebsiteFilePath # A mandatory parameter representing the local path to the website files.
)

# This command logs you in to your Azure account
az login

# Sets the active Azure subscription to deploy resources
az account set --subscription $Subscription

# Creates an Azure resource group with the given name in the specified region
az group create --name $ResourceGroup --location $Region

# Creates an Azure storage account with the specified name, resource group, location, SKU, and kind (StorageV2)
az storage account create --name $StorageAccountName --resource-group $ResourceGroup --location $Region --sku $StorageAccountSku --kind StorageV2

# Enables static website hosting for the storage account and specifies the default index document as “index.html”.
az storage blob service-properties update --account-name $StorageAccountName --static-website --index-document index.html

# Uploads the website files from the local path to the specified destination container (‘$web’) within the storage account.
az storage blob upload-batch --source $WebsiteFilePath --destination '$web' --account-name $StorageAccountName

# Retrieves and displays the primary endpoint URL for the static website hosting.
az storage account show -n $StorageAccountName --resource-group $ResourceGroup --query "primaryEndpoints.web" --output tsv