locals {
  #----------------------------------------------------------------------------#
  #                               VNET Details                                 #
  #----------------------------------------------------------------------------#

  # List of VNETs to be created
  vnet_list = {
    OF-AUC-VN-01 = "10.10.0.0/22"
    OP-AUC-VN-01 = "10.10.4.0/22"
    TS-AUS-VN-01 = "10.10.8.0/22"
    SS-AUS-VN-01 = "10.10.12.0/22"
    TS-AUE-VN-01 = "10.10.16.0/22"
    SS-AUE-VN-01 = "10.10.20.0/22"
  }

  vnet_map = {
    TS-AUS = "TS-AUS-VN-01"
    SS-AUS = "SS-AUS-VN-01"
    TS-AUE = "TS-AUE-VN-01"
    SS-AUE = "SS-AUE-VN-01"
    OF-AUC = "OF-AUC-VN-01"
    OP-AUC = "OP-AUC-VN-01"
    AzureB = "OF-AUC-VN-01"
  }

  vnet_rgroup_map = {
    TS-AUS = local.rgroup_map["aus"]
    SS-AUS = local.rgroup_map["aus"]
    TS-AUE = local.rgroup_map["aue"]
    SS-AUE = local.rgroup_map["aue"]
    OF-AUC = local.rgroup_map["auc"]
    OP-AUC = local.rgroup_map["auc"]
    AzureB = local.rgroup_map["auc"]
  }

  #----------------------------------------------------------------------------#
  #                              Subnet Details                                #
  #----------------------------------------------------------------------------#

  # List of OFFICE Subnets to be created
  list_of_subnets = {
    OF-AUC-USR-SN-01   = "10.10.0.0/24"
    AzureBastionSubnet = "10.10.1.0/24"
    OP-AUC-FRT-SN-01   = "10.10.4.0/24"
    OP-AUC-BCK-SN-01   = "10.10.5.0/24"
    TS-AUS-FRT-SN-01   = "10.10.8.0/24"
    TS-AUS-BCK-SN-01   = "10.10.9.0/24"
    TS-AUS-KEY-SN-01   = "10.10.10.0/24"
    SS-AUS-PEP-SN-01   = "10.10.12.0/24"
    TS-AUE-FRT-SN-01   = "10.10.16.0/24"
    TS-AUE-BCK-SN-01   = "10.10.17.0/24"
    TS-AUE-KEY-SN-01   = "10.10.18.0/24"
    SS-AUE-PEP-SN-01   = "10.10.20.0/24"
  }

  subnet_location_map = {
    TS-AUS = "australiasoutheast"
    SS-AUS = "australiasoutheast"
    TS-AUE = "australiaeast"
    SS-AUE = "australiaeast"
    OF-AUC = "australiacentral"
    OP-AUC = "australiacentral"
    AzureB = "australiacentral"
  }

  #----------------------------------------------------------------------------#
  #                                 GM Details                                 #
  #----------------------------------------------------------------------------#

  gm_aus_nic_map = {
    0 = "${local.vm_name_map["aus"]}-gm1"
    1 = "${local.vm_name_map["aus"]}-gm2"
  }

  gm_aue_nic_map = {
    0 = "${local.vm_name_map["aue"]}-gm1"
    1 = "${local.vm_name_map["aue"]}-gm2"
  }

  gm_auc_nic_map = {
    0 = "${local.vm_name_map["auc"]}-gm1"
    1 = "${local.vm_name_map["auc"]}-gm2"
  }

  gm_pri_ip_map = {
    0 = 5
    1 = 6
  }

  gm_sec_ip_map = {
    0 = 5
    1 = 6
  }

  #----------------------------------------------------------------------------#
  #                              Peering Details                               #
  #----------------------------------------------------------------------------#

  peering_list = {
    # ON PREM AUC to OFFICE AUC VNET Peering
    OF-AUC-VN-01 = "OP-AUC-VN-01"
    OP-AUC-VN-01 = "OF-AUC-VN-01"
    # ON PREM AUC to Transit Services AUS VNET Peering
    OP-AUC-VN-01 = "TS-AUS-VN-01"
    TS-AUS-VN-01 = "OP-AUC-VN-01"
    # ON PREM AUC to Transit Services AUE VNET Peering
    OP-AUC-VN-01 = "TS-AUE-VN-01"
    TS-AUE-VN-01 = "OP-AUC-VN-01"
    # Transit Services AUS to Shared Services AUS VNET Peering
    TS-AUS-VN-01 = "SS-AUS-VN-01"
    SS-AUS-VN-01 = "TS-AUS-VN-01"
    # Transit Services AUE to Shared Services AUE VNET Peering    
    TS-AUE-VN-01 = "SS-AUE-VN-01"
    SS-AUE-VN-01 = "TS-AUE-VN-01"
  }

  #----------------------------------------------------------------------------#
  #                              Resource Details                              #
  #----------------------------------------------------------------------------#

  # Resource Group Name
  rgroup_map = {
    aus = "getvpn-${lower(var.region_ref[var.dep_region_aus])}-${var.environment_map[lower(var.environment)]}-rg"
    aue = "getvpn-${lower(var.region_ref[var.dep_region_aue])}-${var.environment_map[lower(var.environment)]}-rg"
    auc = "getvpn-${lower(var.region_ref[var.dep_region_auc])}-${var.environment_map[lower(var.environment)]}-rg"
  }

  # VM Details
  vm_name_map = {
    aus = "${var.region_ref[var.dep_region_aus]}${var.environment_map[lower(var.environment)]}gvpn"
    aue = "${var.region_ref[var.dep_region_aue]}${var.environment_map[lower(var.environment)]}gvpn"
    auc = "${var.region_ref[var.dep_region_auc]}${var.environment_map[lower(var.environment)]}gvpn"
  }

  # Tag Details
  tags = {
    App              = "Landing Zone"
    ApplicationOwner = "Test User"
    Description      = "Cisco GETVPN Based Landing Zone Using CSR 1000v"
    Environment      = "Test"
    Product          = "Cisco GETVPN"
  }

  #----------------------------------------------------------------------------#
  #                     Template File related Local Values                     #
  #----------------------------------------------------------------------------#

  ####################      VPN VRF Identitiy Maps        ######################

  # AUS Secret Map
  gm_aus_sec_map = {
    0 = data.azurerm_key_vault_secret.gm_aus_rtr1_password.value
    1 = data.azurerm_key_vault_secret.gm_aus_rtr2_password.value
  }

  # AUE Secret Map
  gm_aue_sec_map = {
    0 = data.azurerm_key_vault_secret.gm_aue_rtr1_password.value
    1 = data.azurerm_key_vault_secret.gm_aue_rtr2_password.value
  }

  # AUC Secret Map
  gm_auc_sec_map = {
    0 = data.azurerm_key_vault_secret.gm_auc_rtr1_password.value
    1 = data.azurerm_key_vault_secret.gm_auc_rtr2_password.value
  }

  # ####################             VRF Key Maps           ######################

  # # Router 1 VRF1 key Map
  # rtr1_vrf1_key_map = {
  #   UKS = data.azurerm_key_vault_secret.uks_rtr1_vrf1_preshared_key.value
  #   UKW = data.azurerm_key_vault_secret.ukw_rtr1_vrf1_preshared_key.value
  #   AUS = data.azurerm_key_vault_secret.aus_rtr1_vrf1_preshared_key.value
  # }

  # # Router 1 VRF2 key Map - Need to fix up keys
  # rtr1_vrf2_key_map = {
  #   UKS = data.azurerm_key_vault_secret.uks_rtr1_vrf2_preshared_key.value
  #   UKW = data.azurerm_key_vault_secret.ukw_rtr1_vrf2_preshared_key.value
  #   AUS = data.azurerm_key_vault_secret.aus_rtr1_vrf2_preshared_key.value
  # }
}