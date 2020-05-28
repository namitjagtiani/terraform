data "azurerm_client_config" "current" {}

#----------------------------------------------------------------------------#
#                     AUS GM Template File Parameters                        #
#----------------------------------------------------------------------------#

data "template_file" "gm_aus_init_file_1" {
  template = "${file("${path.module}/gm_init.tpl")}"

  vars = {
    region_subnet_second_octet = 10
    region_subnet_third_octet  = 8
    router_nic1_primary_ip     = 5
    router_nic2_primary_ip     = 6
  }
}

data "template_file" "gm_aus_init_file_2" {
  template = "${file("./gm_init.tpl")}"

  vars = {
    region_subnet_second_octet = 10
    region_subnet_third_octet  = 9
    router_nic1_primary_ip     = 5
    router_nic2_primary_ip     = 6
  }
}


#----------------------------------------------------------------------------#
#                     AUE GM Template File Parameters                        #
#----------------------------------------------------------------------------#

data "template_file" "gm_aue_init_file_1" {
  template = "${file("${path.module}/gm_init.tpl")}"

  vars = {
    region_subnet_second_octet = 10
    region_subnet_third_octet  = 8
    router_nic1_primary_ip     = 5
    router_nic2_primary_ip     = 6
  }
}

data "template_file" "gm_aue_init_file_2" {
  template = "${file("./gm_init.tpl")}"

  vars = {
    region_subnet_second_octet = 10
    region_subnet_third_octet  = 9
    router_nic1_primary_ip     = 5
    router_nic2_primary_ip     = 6
  }
}

#----------------------------------------------------------------------------#
#                     AUC GM Template File Parameters                        #
#----------------------------------------------------------------------------#

data "template_file" "gm_auc_init_file_1" {
  template = "${file("${path.module}/gm_init.tpl")}"

  vars = {
    region_subnet_second_octet = 10
    region_subnet_third_octet  = 8
    router_nic1_primary_ip     = 5
    router_nic2_primary_ip     = 6
  }
}

data "template_file" "gm_auc_init_file_2" {
  template = "${file("./gm_init.tpl")}"

  vars = {
    region_subnet_second_octet = 10
    region_subnet_third_octet  = 9
    router_nic1_primary_ip     = 5
    router_nic2_primary_ip     = 6
  }
}

#----------------------------------------------------------------------------#
#                 Keyvault Related Information and Secrets                   #
#----------------------------------------------------------------------------#

data "azurerm_key_vault" "gvpn_keyvault" {
  name                = "network-kv"
  resource_group_name = "network-kv-rg"
}

####################        Router Credentials          ######################

# Generic Router Username
data "azurerm_key_vault_secret" "rtr_username" {
  name         = "rtr-username"
  key_vault_id = data.azurerm_key_vault.gvpn_keyvault.id
}
# AUS GM1 Router Psssword
data "azurerm_key_vault_secret" "gm_aus_rtr1_password" {
  name         = "aus-gm-rtr1-secret"
  key_vault_id = data.azurerm_key_vault.gvpn_keyvault.id
}

# AUS GM2 Router Psssword
data "azurerm_key_vault_secret" "gm_aus_rtr2_password" {
  name         = "aus-gm-rtr2-secret"
  key_vault_id = data.azurerm_key_vault.gvpn_keyvault.id
}

# AUE GM1 Router Psssword
data "azurerm_key_vault_secret" "gm_aue_rtr1_password" {
  name         = "aue-gm-rtr1-secret"
  key_vault_id = data.azurerm_key_vault.gvpn_keyvault.id
}

# AUE GM2 Router Psssword
data "azurerm_key_vault_secret" "gm_aue_rtr2_password" {
  name         = "aue-gm-rtr1-secret"
  key_vault_id = data.azurerm_key_vault.gvpn_keyvault.id
}

# AUC GM1 Router Psssword
data "azurerm_key_vault_secret" "gm_auc_rtr1_password" {
  name         = "auc-gm-rtr1-secret"
  key_vault_id = data.azurerm_key_vault.gvpn_keyvault.id
}

# AUC GM2 Router Psssword
data "azurerm_key_vault_secret" "gm_auc_rtr2_password" {
  name         = "auc-gm-rtr1-secret"
  key_vault_id = data.azurerm_key_vault.gvpn_keyvault.id
}

# AUS KS Router Psssword
data "azurerm_key_vault_secret" "ks_aus_rtr_password" {
  name         = "aus-ks-rtr-secret"
  key_vault_id = data.azurerm_key_vault.gvpn_keyvault.id
}

# AUE KS Router Psssword
data "azurerm_key_vault_secret" "ks_aue_rtr_password" {
  name         = "aue-ks-rtr-secret"
  key_vault_id = data.azurerm_key_vault.gvpn_keyvault.id
}

# AUC Jumphost Username
data "azurerm_key_vault_secret" "auc_jmp_username" {
  name         = "jmp-adm-username"
  key_vault_id = data.azurerm_key_vault.gvpn_keyvault.id
}

# AUE Jumphost Password
data "azurerm_key_vault_secret" "auc_jmp_password" {
  name         = "jmp-password"
  key_vault_id = data.azurerm_key_vault.gvpn_keyvault.id
}

# ####################        VPN VRF Identities          ######################

# # Router 1 VRF1 Identities
# data "azurerm_key_vault_secret" "uks_rtr1_vrf1_identity" {
#   name         = "zsg-uks-rtr1-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ukw_rtr1_vrf1_identity" {
#   name         = "zsg-ukw-rtr1-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aus_rtr1_vrf1_identity" {
#   name         = "zsg-aus-rtr1-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aue_rtr1_vrf1_identity" {
#   name         = "zsg-aue-rtr1-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aup_rtr1_vrf1_identity" {
#   name         = "zsg-aup-rtr1-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "usc_rtr1_vrf1_identity" {
#   name         = "zsg-usc-rtr1-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ue2_rtr1_vrf1_identity" {
#   name         = "zsg-ue2-rtr1-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }

# # Router 1 VRF2 Identities
# data "azurerm_key_vault_secret" "uks_rtr1_vrf2_identity" {
#   name         = "zsg-uks-rtr1-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ukw_rtr1_vrf2_identity" {
#   name         = "zsg-ukw-rtr1-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aus_rtr1_vrf2_identity" {
#   name         = "zsg-aus-rtr1-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aue_rtr1_vrf2_identity" {
#   name         = "zsg-aue-rtr1-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aup_rtr1_vrf2_identity" {
#   name         = "zsg-aup-rtr1-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "usc_rtr1_vrf2_identity" {
#   name         = "zsg-usc-rtr1-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ue2_rtr1_vrf2_identity" {
#   name         = "zsg-ue2-rtr1-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }

# # Router 2 VRF1 Identities
# data "azurerm_key_vault_secret" "uks_rtr2_vrf1_identity" {
#   name         = "zsg-uks-rtr2-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ukw_rtr2_vrf1_identity" {
#   name         = "zsg-ukw-rtr2-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aus_rtr2_vrf1_identity" {
#   name         = "zsg-aus-rtr2-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aue_rtr2_vrf1_identity" {
#   name         = "zsg-aue-rtr2-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aup_rtr2_vrf1_identity" {
#   name         = "zsg-aup-rtr2-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "usc_rtr2_vrf1_identity" {
#   name         = "zsg-usc-rtr2-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ue2_rtr2_vrf1_identity" {
#   name         = "zsg-ue2-rtr2-vrf1-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }

# # Router 2 VRF2 Identities
# data "azurerm_key_vault_secret" "uks_rtr2_vrf2_identity" {
#   name         = "zsg-uks-rtr2-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ukw_rtr2_vrf2_identity" {
#   name         = "zsg-ukw-rtr2-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aus_rtr2_vrf2_identity" {
#   name         = "zsg-aus-rtr2-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aue_rtr2_vrf2_identity" {
#   name         = "zsg-aue-rtr2-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aup_rtr2_vrf2_identity" {
#   name         = "zsg-aup-rtr2-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "usc_rtr2_vrf2_identity" {
#   name         = "zsg-usc-rtr2-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ue2_rtr2_vrf2_identity" {
#   name         = "zsg-ue2-rtr2-vrf2-identity"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }

# ####################      VPN VRF PreShared Keys        ######################

# # Router 1 VRF1 PreShared Keys
# data "azurerm_key_vault_secret" "uks_rtr1_vrf1_preshared_key" {
#   name         = "zsg-uks-rtr1-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ukw_rtr1_vrf1_preshared_key" {
#   name         = "zsg-ukw-rtr1-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aus_rtr1_vrf1_preshared_key" {
#   name         = "zsg-aus-rtr1-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aue_rtr1_vrf1_preshared_key" {
#   name         = "zsg-aue-rtr1-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aup_rtr1_vrf1_preshared_key" {
#   name         = "zsg-aup-rtr1-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "usc_rtr1_vrf1_preshared_key" {
#   name         = "zsg-usc-rtr1-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ue2_rtr1_vrf1_preshared_key" {
#   name         = "zsg-ue2-rtr1-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }

# # Router 1 VRF2 PreShared Keys
# data "azurerm_key_vault_secret" "uks_rtr1_vrf2_preshared_key" {
#   name         = "zsg-uks-rtr1-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ukw_rtr1_vrf2_preshared_key" {
#   name         = "zsg-ukw-rtr1-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aus_rtr1_vrf2_preshared_key" {
#   name         = "zsg-aus-rtr1-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aue_rtr1_vrf2_preshared_key" {
#   name         = "zsg-aue-rtr1-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aup_rtr1_vrf2_preshared_key" {
#   name         = "zsg-aup-rtr1-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "usc_rtr1_vrf2_preshared_key" {
#   name         = "zsg-usc-rtr1-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ue2_rtr1_vrf2_preshared_key" {
#   name         = "zsg-ue2-rtr1-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }

# # Router 2 VRF1 PreShared Keys
# data "azurerm_key_vault_secret" "uks_rtr2_vrf1_preshared_key" {
#   name         = "zsg-uks-rtr2-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ukw_rtr2_vrf1_preshared_key" {
#   name         = "zsg-ukw-rtr2-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aus_rtr2_vrf1_preshared_key" {
#   name         = "zsg-aus-rtr2-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aue_rtr2_vrf1_preshared_key" {
#   name         = "zsg-aue-rtr2-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aup_rtr2_vrf1_preshared_key" {
#   name         = "zsg-aup-rtr2-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "usc_rtr2_vrf1_preshared_key" {
#   name         = "zsg-usc-rtr2-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ue2_rtr2_vrf1_preshared_key" {
#   name         = "zsg-ue2-rtr2-vrf1-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }

# # Router 2 VRF2 PreShared Keys
# data "azurerm_key_vault_secret" "uks_rtr2_vrf2_preshared_key" {
#   name         = "zsg-uks-rtr2-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ukw_rtr2_vrf2_preshared_key" {
#   name         = "zsg-ukw-rtr2-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aus_rtr2_vrf2_preshared_key" {
#   name         = "zsg-aus-rtr2-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aue_rtr2_vrf2_preshared_key" {
#   name         = "zsg-aue-rtr2-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "aup_rtr2_vrf2_preshared_key" {
#   name         = "zsg-aup-rtr2-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "usc_rtr2_vrf2_preshared_key" {
#   name         = "zsg-usc-rtr2-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }
# data "azurerm_key_vault_secret" "ue2_rtr2_vrf2_preshared_key" {
#   name         = "zsg-ue2-rtr2-vrf2-preshared-key"
#   key_vault_id = data.azurerm_key_vault.network_keyvault.id
#   provider     = azurerm.au-shared
# }

# App Service Data Resource
data "azurerm_app_service" "njwebapp" {
  name                = "njtestwebapp01"
  resource_group_name = "nimiblz_rg_Windows_australiasoutheast"
}