#----------------------------------------------------------------------------#
#                         Create Storage Resources                           #
#----------------------------------------------------------------------------#

# Create Resource Group for AUS
resource "azurerm_resource_group" "gvg_aus_group" {
  name     = local.rgroup_map["aus"]
  location = var.location_map[var.dep_region_aus]

  tags = local.tags
}

# Create Storage Account
resource "azurerm_storage_account" "gvgsaccount_aus" {
  name                      = "${local.vm_name_map["aus"]}storage"
  resource_group_name       = local.rgroup_map["aus"]
  location                  = var.location_map[var.dep_region_aus]
  account_kind              = var.account_kind
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  enable_https_traffic_only = true
  depends_on                = [azurerm_resource_group.gvg_aus_group]

  tags = local.tags
}

#----------------------------------------------------------------------------#
#                   Create Group Member Network Resources                    #
#----------------------------------------------------------------------------#

# Create AvailabilitySets
resource "azurerm_availability_set" "gvg_aus_aset" {
  name                         = "${local.vm_name_map["aus"]}-aset"
  location                     = azurerm_resource_group.gvg_aus_group.location
  resource_group_name          = azurerm_resource_group.gvg_aus_group.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  depends_on                   = [azurerm_resource_group.gvg_aus_group]

  tags = local.tags
}

# Create NICs
## Create NIC01 to be used as primary NIC
resource "azurerm_network_interface" "gm_aus_nic1" {
  count                         = 2
  name                          = "${local.gm_aus_nic_map[count.index]}-nic01"
  location                      = azurerm_resource_group.gvg_aus_group.location
  resource_group_name           = azurerm_resource_group.gvg_aus_group.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  depends_on                    = [azurerm_resource_group.gvg_aus_group, azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]

  ## Create primary IP configuration for the NIC. Used for Outbound connectivity to Zscaler and inbound management of the device.
  ip_configuration {
    name                          = "${local.gm_aus_nic_map[count.index]}-nic01-primary"
    subnet_id                     = azurerm_subnet.list_of_subnets["TS-AUS-FRT-SN-01"].id
    private_ip_address_allocation = "Static"
    primary                       = true
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["TS-AUS-FRT-SN-01"].address_prefix, local.gm_pri_ip_map[count.index])
  }

  tags = local.tags
}

## Create NIC02 to be used as secondary NIC
resource "azurerm_network_interface" "gm_aus_nic2" {
  count                         = 2
  name                          = "${local.gm_aus_nic_map[count.index]}-nic02"
  location                      = azurerm_resource_group.gvg_aus_group.location
  resource_group_name           = azurerm_resource_group.gvg_aus_group.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  depends_on                    = [azurerm_resource_group.gvg_aus_group, azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]

  ## Create primary IP configuration for the NIC. Used for Outbound connectivity to Zscaler and inbound management of the device.
  ip_configuration {
    name                          = "${local.gm_aus_nic_map[count.index]}-nic02-primary"
    subnet_id                     = azurerm_subnet.list_of_subnets["TS-AUS-BCK-SN-01"].id
    private_ip_address_allocation = "Static"
    primary                       = true
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["TS-AUS-BCK-SN-01"].address_prefix, local.gm_pri_ip_map[count.index])
  }

  tags = local.tags
}

#----------------------------------------------------------------------------#
#                   Create Key Server Network Resources                      #
#----------------------------------------------------------------------------#

# Create NICs
## Create NIC01 to be used as primary NIC
resource "azurerm_network_interface" "ks_aus_nic1" {
  name                          = "${local.vm_name_map["aus"]}-ks-nic01"
  location                      = azurerm_resource_group.gvg_aus_group.location
  resource_group_name           = azurerm_resource_group.gvg_aus_group.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  depends_on                    = [azurerm_resource_group.gvg_aus_group, azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]

  ## Create primary IP configuration for the NIC. Used for Outbound connectivity to Zscaler and inbound management of the device.
  ip_configuration {
    name                          = "${local.vm_name_map["aus"]}-ks-nic01-primary"
    subnet_id                     = azurerm_subnet.list_of_subnets["TS-AUS-KEY-SN-01"].id
    private_ip_address_allocation = "Static"
    primary                       = true
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["TS-AUS-KEY-SN-01"].address_prefix, 5)
  }

  tags = local.tags
}

#----------------------------------------------------------------------------#
#                       Create LoadBalancer Resources                        #
#----------------------------------------------------------------------------#

# Create Internal LoadBalancer
resource "azurerm_lb" "gm_aus_lb" {
  name                = "${local.vm_name_map["aus"]}-ilb"
  location            = azurerm_resource_group.gvg_aus_group.location
  resource_group_name = azurerm_resource_group.gvg_aus_group.name
  sku                 = "Standard"
  depends_on          = [azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]
  tags                = local.tags

  frontend_ip_configuration {
    name                          = "gvpnfrontend"
    subnet_id                     = azurerm_subnet.list_of_subnets["TS-AUS-FRT-SN-01"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["TS-AUS-FRT-SN-01"].address_prefix, 4)
  }
}

# Create Backend Pool
resource "azurerm_lb_backend_address_pool" "gm_aus_lb_backend" {
  resource_group_name = azurerm_resource_group.gvg_aus_group.name
  loadbalancer_id     = azurerm_lb.gm_aus_lb.id
  name                = "${local.vm_name_map["aus"]}-backend-pool"
}

# Create LB Probe
resource "azurerm_lb_probe" "gm_aus_lb_probe" {
  resource_group_name = azurerm_resource_group.gvg_aus_group.name
  loadbalancer_id     = azurerm_lb.gm_aus_lb.id
  name                = "gvpn-probe"
  port                = 80
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Create LB Rule
resource "azurerm_lb_rule" "gm_aus_lb_rule" {
  resource_group_name            = azurerm_resource_group.gvg_aus_group.name
  loadbalancer_id                = azurerm_lb.gm_aus_lb.id
  name                           = "gvpn-lb-rule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "gvpnfrontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.gm_aus_lb_backend.id
  probe_id                       = azurerm_lb_probe.gm_aus_lb_probe.id
  enable_floating_ip             = false
  load_distribution              = "Default"
  idle_timeout_in_minutes        = 4
  disable_outbound_snat          = false
}



# Create LB Backend Address Pool Association with VM NIC01
resource "azurerm_network_interface_backend_address_pool_association" "gm_aus_bck_nic01" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.gm_aus_nic1[count.index].id
  ip_configuration_name   = "${local.gm_aus_nic_map[count.index]}-nic01-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.gm_aus_lb_backend.id
}

# Create LB Backend Address Pool Association with VM NIC02
resource "azurerm_network_interface_backend_address_pool_association" "gm_aus_bck_nic02" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.gm_aus_nic2[count.index].id
  ip_configuration_name   = "${local.gm_aus_nic_map[count.index]}-nic02-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.gm_aus_lb_backend.id
}

#----------------------------------------------------------------------------#
#                          Azure Marketplace Terms                           #
#----------------------------------------------------------------------------#

# Accept MarketPlace Terms and Conditions

# resource "azurerm_marketplace_agreement" "accept_terms" {
#   publisher = "cisco"
#   offer     = "cisco-csr-1000v"
#   plan      = "payg"
# }

#----------------------------------------------------------------------------#
#                       GM Virtual Machine Resources                         #
#----------------------------------------------------------------------------#

# Create VM configuration

resource "azurerm_linux_virtual_machine" "gm_aus_vm" {
  count                 = 2
  name                  = "${local.vm_name_map["aus"]}-gm${count.index + 1}"
  location              = azurerm_resource_group.gvg_aus_group.location
  resource_group_name   = azurerm_resource_group.gvg_aus_group.name
  network_interface_ids = [azurerm_network_interface.gm_aus_nic1[count.index].id, azurerm_network_interface.gm_aus_nic2[count.index].id]
  size                  = "Standard_DS2_v2"
  availability_set_id   = azurerm_availability_set.gvg_aus_aset.id

  # admin_username                  = data.azurerm_key_vault_secret.rtr_username.value
  # admin_password                  = "${data.azurerm_key_vault_secret.aus-gm-rtr${count.index + 1}-secret.value}"

  admin_username = data.azurerm_key_vault_secret.rtr_username.value
  admin_password = local.gm_aus_sec_map[count.index]

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
    name                 = "${local.vm_name_map["aus"]}-gm${count.index + 1}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.gvgsaccount_aus.primary_blob_endpoint
  }

  tags = local.tags

  # depends_on = [azurerm_marketplace_agreement.accept_terms]
}

#----------------------------------------------------------------------------#
#                       KS Virtual Machine Resources                         #
#----------------------------------------------------------------------------#

# Create VM configuration

resource "azurerm_linux_virtual_machine" "ks_aus_vm" {
  name                  = "${local.vm_name_map["aus"]}-ks"
  location              = azurerm_resource_group.gvg_aus_group.location
  resource_group_name   = azurerm_resource_group.gvg_aus_group.name
  network_interface_ids = [azurerm_network_interface.ks_aus_nic1.id, ]
  size                  = "Standard_DS2_v2"

  admin_username = data.azurerm_key_vault_secret.rtr_username.value
  admin_password = data.azurerm_key_vault_secret.ks_aus_rtr_password.value

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
    name                 = "${local.vm_name_map["aus"]}-ks-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.gvgsaccount_aus.primary_blob_endpoint
  }

  tags = local.tags

  # depends_on = [azurerm_marketplace_agreement.accept_terms]
}

#----------------------------------------------------------------------------#
#                         Private Endpoint Resources                         #
#----------------------------------------------------------------------------#

resource "azurerm_private_endpoint" "aus_webapp_endpoint" {
  name                = "aus-webapp-pep"
  location            = azurerm_resource_group.gvg_aus_group.location
  resource_group_name = azurerm_resource_group.gvg_aus_group.name
  subnet_id           = azurerm_subnet.list_of_subnets["SS-AUS-PEP-SN-01"].id

  private_service_connection {
    name                           = "aus-webapp-connection"
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

resource "azurerm_private_dns_zone" "aus_private_dns_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.gvg_aus_group.name

  tags       = local.tags
  depends_on = [azurerm_virtual_network.gvpn_vnets]
}

resource "azurerm_private_dns_zone_virtual_network_link" "aus_private_dns_vnet_link" {
  name                  = "ausprivatednslink"
  resource_group_name   = azurerm_resource_group.gvg_aus_group.name
  private_dns_zone_name = azurerm_private_dns_zone.aus_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.gvpn_vnets["SS-AUS-VN-01"].id

  tags = local.tags
}