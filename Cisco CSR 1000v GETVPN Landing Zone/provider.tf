#----------------------------------------------------------------------------#
#                            Provider Information                            #
#----------------------------------------------------------------------------#

# Provider for Prod subscription
provider "azurerm" {
  version         = ">2.0.0" ## This is important since the code is for AzureRM provider v2.x
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {} ## This blank block needs to be defined as part of provider v2.0's pre-requisite
}

provider "azuread" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}