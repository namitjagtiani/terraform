#----------------------------------------------------------------------------#
#                         Create Storage Resources                           #
#----------------------------------------------------------------------------#

# Create Resource Group for AUE
resource "azurerm_resource_group" "gvg_aue_group" {
  name     = local.rgroup_map["aue"]
  location = var.location_map[var.dep_region_aue]

  tags = local.tags
}

# Create Storage Account
resource "azurerm_storage_account" "gvgsaccount_aue" {
  name                      = "${local.vm_name_map["aue"]}storage"
  resource_group_name       = local.rgroup_map["aue"]
  location                  = var.location_map[var.dep_region_aue]
  account_kind              = var.account_kind
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  enable_https_traffic_only = true
  depends_on                = [azurerm_resource_group.gvg_aue_group]

  tags = local.tags
}

#----------------------------------------------------------------------------#
#                   Create Group Member Network Resources                    #
#----------------------------------------------------------------------------#

# Create AvailabilitySets
resource "azurerm_availability_set" "gvg_aue_aset" {
  name                         = "${local.vm_name_map["aue"]}-aset"
  location                     = var.location_map["aue"]
  resource_group_name          = local.rgroup_map["aue"]
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  depends_on                   = [azurerm_resource_group.gvg_aue_group]

  tags = local.tags
}

# Create NICs
## Create NIC01 to be used as primary NIC
resource "azurerm_network_interface" "gm_aue_nic1" {
  count                         = 2
  name                          = "${local.gm_aue_nic_map[count.index]}-nic01"
  location                      = var.location_map["aue"]
  resource_group_name           = local.rgroup_map["aue"]
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  depends_on                    = [azurerm_resource_group.gvg_aue_group, azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]

  ## Create primary IP configuration for the NIC. Used for Outbound connectivity to Zscaler and inbound management of the device.
  ip_configuration {
    name                          = "${local.gm_aue_nic_map[count.index]}-nic01-primary"
    subnet_id                     = azurerm_subnet.list_of_subnets["TS-AUE-FRT-SN-01"].id
    private_ip_address_allocation = "Static"
    primary                       = true
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["TS-AUE-FRT-SN-01"].address_prefix, local.gm_pri_ip_map[count.index])
  }

  tags = local.tags
}

## Create NIC02 to be used as secondary NIC
resource "azurerm_network_interface" "gm_aue_nic2" {
  count                         = 2
  name                          = "${local.gm_aue_nic_map[count.index]}-nic02"
  location                      = var.location_map["aue"]
  resource_group_name           = local.rgroup_map["aue"]
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  depends_on                    = [azurerm_resource_group.gvg_aue_group, azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]

  ## Create primary IP configuration for the NIC. Used for Outbound connectivity to Zscaler and inbound management of the device.
  ip_configuration {
    name                          = "${local.gm_aue_nic_map[count.index]}-nic02-primary"
    subnet_id                     = azurerm_subnet.list_of_subnets["TS-AUE-BCK-SN-01"].id
    private_ip_address_allocation = "Static"
    primary                       = true
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["TS-AUE-BCK-SN-01"].address_prefix, local.gm_pri_ip_map[count.index])
  }

  tags = local.tags
}

#----------------------------------------------------------------------------#
#                   Create Key Server Network Resources                      #
#----------------------------------------------------------------------------#

# Create NICs
## Create NIC01 to be used as primary NIC
resource "azurerm_network_interface" "ks_aue_nic1" {
  name                          = "${local.vm_name_map["aue"]}-ks-nic01"
  location                      = var.location_map["aue"]
  resource_group_name           = local.rgroup_map["aue"]
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  depends_on                    = [azurerm_resource_group.gvg_aue_group, azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]

  ## Create primary IP configuration for the NIC. Used for Outbound connectivity to Zscaler and inbound management of the device.
  ip_configuration {
    name                          = "${local.vm_name_map["aue"]}-ks-nic01-primary"
    subnet_id                     = azurerm_subnet.list_of_subnets["TS-AUE-KEY-SN-01"].id
    private_ip_address_allocation = "Static"
    primary                       = true
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["TS-AUE-KEY-SN-01"].address_prefix, 5)
  }

  tags = local.tags
}

#----------------------------------------------------------------------------#
#                       Create LoadBalancer Resources                        #
#----------------------------------------------------------------------------#

# Create Internal LoadBalancer
resource "azurerm_lb" "gm_aue_lb" {
  name                = "${local.vm_name_map["aue"]}-ilb"
  location            = azurerm_resource_group.gvg_aue_group.location
  resource_group_name = azurerm_resource_group.gvg_aue_group.name
  sku                 = "Standard"
  depends_on          = [azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]
  tags                = local.tags

  frontend_ip_configuration {
    name                          = "gvpnfrontend"
    subnet_id                     = azurerm_subnet.list_of_subnets["TS-AUE-FRT-SN-01"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["TS-AUE-FRT-SN-01"].address_prefix, 4)
  }
}

# Create Backend Pool
resource "azurerm_lb_backend_address_pool" "gm_aue_lb_backend" {
  resource_group_name = azurerm_resource_group.gvg_aue_group.name
  loadbalancer_id     = azurerm_lb.gm_aue_lb.id
  name                = "${local.vm_name_map["aue"]}-backend-pool"
}

# Create LB Probe
resource "azurerm_lb_probe" "gm_aue_lb_probe" {
  resource_group_name = azurerm_resource_group.gvg_aue_group.name
  loadbalancer_id     = azurerm_lb.gm_aue_lb.id
  name                = "gvpn-probe"
  port                = 80
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Create LB Rule
resource "azurerm_lb_rule" "gm_aue_lb_rule" {
  resource_group_name            = azurerm_resource_group.gvg_aue_group.name
  loadbalancer_id                = azurerm_lb.gm_aue_lb.id
  name                           = "gvpn-lb-rule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "gvpnfrontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.gm_aue_lb_backend.id
  probe_id                       = azurerm_lb_probe.gm_aue_lb_probe.id
  enable_floating_ip             = false
  load_distribution              = "Default"
  idle_timeout_in_minutes        = 4
  disable_outbound_snat          = false
}

# Create LB Backend Address Pool Association with VM NIC01
resource "azurerm_network_interface_backend_address_pool_association" "gm_aue_bck_nic01" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.gm_aue_nic1[count.index].id
  ip_configuration_name   = "${local.gm_aue_nic_map[count.index]}-nic01-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.gm_aue_lb_backend.id
}

# Create LB Backend Address Pool Association with VM NIC02
resource "azurerm_network_interface_backend_address_pool_association" "gm_aue_bck_nic02" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.gm_aue_nic2[count.index].id
  ip_configuration_name   = "${local.gm_aue_nic_map[count.index]}-nic02-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.gm_aue_lb_backend.id
}

#----------------------------------------------------------------------------#
#                       GM Virtual Machine Resources                         #
#----------------------------------------------------------------------------#

# Create VM configuration

resource "azurerm_linux_virtual_machine" "gm_aue_vm" {
  count                 = 2
  name                  = "${local.vm_name_map["aue"]}-gm${count.index + 1}"
  location              = azurerm_resource_group.gvg_aue_group.location
  resource_group_name   = azurerm_resource_group.gvg_aue_group.name
  network_interface_ids = [azurerm_network_interface.gm_aue_nic1[count.index].id, azurerm_network_interface.gm_aue_nic2[count.index].id]
  size                  = "Standard_DS2_v2"
  availability_set_id   = azurerm_availability_set.gvg_aue_aset.id

  admin_username = data.azurerm_key_vault_secret.rtr_username.value
  admin_password = local.gm_aue_sec_map[count.index]

  disable_password_authentication = false

  ## Pass in custom data to the Cisco CSR VM at bootup
  #custom_data = count.index == 0 ? base64encode(data.template_file.gm_aue_init_file_1.rendered) : base64encode(data.template_file.gm_aue_init_file_2.rendered)

  plan { ## run "az vm image show --urn <image urn>" to get these details
    name      = "16_12-payg-ax"
    publisher = "cisco"
    product   = "cisco-csr-1000v"
  }

  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-csr-1000v"
    sku       = "16_12-payg-ax"
    version   = "latest"
  }

  os_disk {
    name                 = "${local.vm_name_map["aue"]}-gm${count.index + 1}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.gvgsaccount_aue.primary_blob_endpoint
  }

  tags = local.tags

  # depends_on = [azurerm_marketplace_agreement.accept_terms]
}

#----------------------------------------------------------------------------#
#                       KS Virtual Machine Resources                         #
#----------------------------------------------------------------------------#

# Create VM configuration

resource "azurerm_linux_virtual_machine" "ks_aue_vm" {
  name                  = "${local.vm_name_map["aue"]}-ks"
  location              = azurerm_resource_group.gvg_aue_group.location
  resource_group_name   = azurerm_resource_group.gvg_aue_group.name
  network_interface_ids = [azurerm_network_interface.ks_aue_nic1.id, ]
  size                  = "Standard_DS2_v2"

  admin_username = data.azurerm_key_vault_secret.rtr_username.value
  admin_password = data.azurerm_key_vault_secret.ks_aue_rtr_password.value

  disable_password_authentication = false

  ## Pass in custom data to the Cisco CSR VM at bootup
  #custom_data = count.index == 0 ? base64encode(data.template_file.gm_aus_init_file_1.rendered) : base64encode(data.template_file.gm_aus_init_file_2.rendered)

  plan { ## run "az vm image show --urn <image urn>" to get these details
    name      = "16_12-payg-ax"
    publisher = "cisco"
    product   = "cisco-csr-1000v"
  }

  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-csr-1000v"
    sku       = "16_12-payg-ax"
    version   = "latest"
  }

  os_disk {
    name                 = "${local.vm_name_map["aue"]}-ks-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.gvgsaccount_aue.primary_blob_endpoint
  }

  tags = local.tags

  # depends_on = [azurerm_marketplace_agreement.accept_terms]
}

#----------------------------------------------------------------------------#
#                         Private Endpoint Resources                         #
#----------------------------------------------------------------------------#

resource "azurerm_private_endpoint" "aue_webapp_endpoint" {
  name                = "aue-webapp-pep"
  location            = azurerm_resource_group.gvg_aue_group.location
  resource_group_name = azurerm_resource_group.gvg_aue_group.name
  subnet_id           = azurerm_subnet.list_of_subnets["SS-AUE-PEP-SN-01"].id

  private_service_connection {
    name                           = "aue-webapp-connection"
    is_manual_connection           = false
    private_connection_resource_id = data.azurerm_app_service.njwebapp.id
    subresource_names              = ["sites"]
  }
  tags       = local.tags
  depends_on = [azurerm_private_dns_zone.aus_private_dns_zone, ]
}

#----------------------------------------------------------------------------#
#                            Private DNS Resources                           #
#----------------------------------------------------------------------------#

resource "azurerm_private_dns_zone" "aue_private_dns_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.gvg_aue_group.name

  tags       = local.tags
  depends_on = [azurerm_virtual_network.gvpn_vnets]
}

resource "azurerm_private_dns_zone_virtual_network_link" "aue_private_dns_vnet_link" {
  name                  = "aueprivatednslink"
  resource_group_name   = azurerm_resource_group.gvg_aue_group.name
  private_dns_zone_name = azurerm_private_dns_zone.aue_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.gvpn_vnets["SS-AUE-VN-01"].id

  tags = local.tags
}