#----------------------------------------------------------------------------#
#                            Count Variables                                 #
#----------------------------------------------------------------------------#

# This variable defines the number of routers to be deployed
variable "instance_count" {
  description = "Enter the numbers of instances required '1' / '2'"
}

#----------------------------------------------------------------------------#
#                          Environment Variables                             #
#----------------------------------------------------------------------------#

# Module dependency variables to be provied in the repo that consumes this module
# variable "sub_id" {}
# variable "clnt_id" {}
# variable "clnt_sec" {}
# variable "tnt_id" {}

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

#This variable defines which region the resources will be created in
variable "region_ref" {
  description = "Enter the region 'aus' / 'aue' / 'auc' "
  default = {
    aus = "aus"
    aue = "aue"
    auc = "auc"
  }
}

variable "location_map" {
  description = "The location map to match the cloud service region"
  type        = map
  default = {
    aus = "australiasoutheast"
    aue = "australiaeast"
    auc = "australiacentral"
  }
}

# This variable defines the environment as Production / Pre-Production
variable "environment" {
  description = "Enter the environment 'prod' / 'preprod'"
}

variable "environment_map" {
  description = "The location map to match the cloud service region"
  type        = map
  default = {
    prod    = "prd"
    preprod = "ppd"
  }
}

#----------------------------------------------------------------------------#
#                            Storage Variables                               #
#----------------------------------------------------------------------------#

# This variable specifies whether older or newer Storage technology should be used
variable "account_kind" {
  description = "Input 'StorageV1' or 'StorageV2'"
  default     = "StorageV2"
}

# This variable defines the Account Tier to be used
variable "account_tier" {
  description = "Input 'Standard' or 'Premium'"
  default     = "Standard"
}

# This variable defines the Storage Replication Type
variable "account_replication_type" {
  description = "Input 'LRS' or 'GRS'"
  default     = "LRS"
}

#----------------------------------------------------------------------------#
#                             Network Variables                              #
#----------------------------------------------------------------------------#

# Vnet mapping to Internet Services or North Services subnet depending on region
variable "vnet_map" {
  description = "Region to Vnet mapping"
  type        = map
  default = {
    AUS = "IS"
    AUE = "IS"
    AUP = "IS"
  }
}

# Subnet mapping to Services for BackEnd subnets depending on region
variable "backend_subnet_map" {
  description = "Region to Subnet mapping"
  type        = map
  default = {
    AUS = "SVC"
    AUE = "SVC"
    AUP = "SVC"
  }
}

# Public IP SKU
variable "pip_sku" {
  description = "Use Standard SKU for Public IP"
  default     = "Standard"
}

#----------------------------------------------------------------------------#
#                         Virtual Machine Variables                          #
#----------------------------------------------------------------------------#

# This variable specifies the type of MarketPlace plan to use when deploying the VMs
variable "plan" {
  description = "Select plan for deployment, 'byol' or 'payg'"
}

# This variable selects the appropriate plan based on the associated input value
variable "plan_map" {
  description = "Set the plan for the deployment, 'byol' or 'payg'"
  type        = map
  default = {
    payg = "16_12-payg-ax"
    byol = "16_12-byol"
  }
}

#----------------------------------------------------------------------------#
#                CSR Template File Non-Sensitive Variables                   #
#----------------------------------------------------------------------------#

# This variable defines the first region the resources will be created in
variable "dep_region_aus" {
  description = "Enter the region 'AUS' / 'AUE' "
  default     = "aus"
}

# This variable defines the second region the resources will be created in
variable "dep_region_aue" {
  description = "Enter the region 'AUS' / 'AUE' "
  default     = "aue"
}

# This variable defines the ON PREM region the resources will be created in
variable "dep_region_auc" {
  description = "No value needs to be entered"
  default     = "auc"
}

# Region Primary Zen Map
variable "region_pri_zen_map" {
  type = map
  default = {
    aus = "165.225.80.33"
    aue = "165.225.80.33"
    auc = "165.225.226.18"
  }
}

# Region Secondary Zen Map
variable "region_sec_zen_map" {
  type = map
  default = {
    aus = "185.46.212.33"
    aue = "185.46.212.33"
    auc = "165.225.114.12"
  }
}

# Region Second Octet Map
variable "region_second_oct_map" {
  type = map
  default = {
    aus = "186"
    aue = "187"
    auc = "180"
  }
}

# Region Third Octet Map
variable "region_third_oct_map" {
  type = map
  default = {
    aus = "228"
    aue = "228"
    auc = "228"
  }
}

# Primary ZEN Name
variable "primary_zen_name_map" {
  type = map
  default = {
    aus = "London3"
    aue = "London3"
    auc = "Melbourne2"
  }
}

# Secondary ZEN Name
variable "secondary_zen_name_map" {
  type = map
  default = {
    aus = "Amsterdam"
    aue = "Amsterdam"
    auc = "Sydney3"
  }
}

# Primary ZEN Location
variable "primary_zen_location_map" {
  type = map
  default = {
    aus = "London"
    aue = "London"
    auc = "Melbourne"
  }
}

# Secondary ZEN Location
variable "secondary_zen_location_map" {
  type = map
  default = {
    aus = "Amsterdam"
    aue = "Amsterdam"
    auc = "Sydney"
  }
}