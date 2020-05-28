#----------------------------------------------------------------------------#
#                         Create Storage Resources                           #
#----------------------------------------------------------------------------#

# Create Resource Group for AUC
resource "azurerm_resource_group" "gvg_auc_group" {
  name     = local.rgroup_map["auc"]
  location = var.location_map[var.dep_region_auc]

  tags = local.tags
}

# Create Storage Account
resource "azurerm_storage_account" "gvgsaccount_auc" {
  name                      = "${local.vm_name_map["auc"]}storage"
  location                  = azurerm_resource_group.gvg_auc_group.location
  resource_group_name       = azurerm_resource_group.gvg_auc_group.name
  account_kind              = var.account_kind
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  enable_https_traffic_only = true

  tags = local.tags
}

#----------------------------------------------------------------------------#
#                   Create Group Member Network Resources                    #
#----------------------------------------------------------------------------#

# Create AvailabilitySets
resource "azurerm_availability_set" "gvg_auc_aset" {
  name                         = "${local.vm_name_map["auc"]}-aset"
  location                     = azurerm_resource_group.gvg_auc_group.location
  resource_group_name          = azurerm_resource_group.gvg_auc_group.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true

  tags = local.tags
}


# Create NICs
## Create NIC01 to be used as primary NIC
resource "azurerm_network_interface" "gm_auc_nic1" {
  count                         = 2
  name                          = "${local.gm_auc_nic_map[count.index]}-nic01"
  location                      = azurerm_resource_group.gvg_auc_group.location
  resource_group_name           = azurerm_resource_group.gvg_auc_group.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  depends_on                    = [azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]

  ## Create primary IP configuration for the NIC. Used for Outbound connectivity to Zscaler and inbound management of the device.
  ip_configuration {
    name                          = "${local.gm_auc_nic_map[count.index]}-nic01-primary"
    subnet_id                     = azurerm_subnet.list_of_subnets["OP-AUC-FRT-SN-01"].id
    private_ip_address_allocation = "Static"
    primary                       = true
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["OP-AUC-FRT-SN-01"].address_prefix, local.gm_pri_ip_map[count.index])
  }

  tags = local.tags
}

## Create NIC02 to be used as secondary NIC
resource "azurerm_network_interface" "gm_auc_nic2" {
  count                         = 2
  name                          = "${local.gm_auc_nic_map[count.index]}-nic02"
  location                      = azurerm_resource_group.gvg_auc_group.location
  resource_group_name           = azurerm_resource_group.gvg_auc_group.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  depends_on                    = [azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]

  ## Create primary IP configuration for the NIC. Used for Outbound connectivity to Zscaler and inbound management of the device.
  ip_configuration {
    name                          = "${local.gm_auc_nic_map[count.index]}-nic02-primary"
    subnet_id                     = azurerm_subnet.list_of_subnets["OP-AUC-BCK-SN-01"].id
    private_ip_address_allocation = "Static"
    primary                       = true
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["OP-AUC-BCK-SN-01"].address_prefix, local.gm_pri_ip_map[count.index])
  }

  tags = local.tags
}

#----------------------------------------------------------------------------#
#                       Create Jumphost Network Resources                    #
#----------------------------------------------------------------------------#

# Create NICs
## Create NIC01 to be used as primary NIC
resource "azurerm_network_interface" "jmp_auc_nic1" {
  name                          = "aucprdjmp-nic01"
  location                      = azurerm_resource_group.gvg_auc_group.location
  resource_group_name           = azurerm_resource_group.gvg_auc_group.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  depends_on                    = [azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]

  ## Create primary IP configuration for the NIC. Used for Outbound connectivity to Zscaler and inbound management of the device.
  ip_configuration {
    name                          = "aucprdjmp-nic01-primary"
    subnet_id                     = azurerm_subnet.list_of_subnets["OF-AUC-USR-SN-01"].id
    private_ip_address_allocation = "Static"
    primary                       = true
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["OF-AUC-USR-SN-01"].address_prefix, 5)
  }

  tags = local.tags
}

# Create Public IP
resource "azurerm_public_ip" "auc_jmp_pip" {
  name                = "bastionpublicip"
  location            = azurerm_resource_group.gvg_auc_group.location
  resource_group_name = azurerm_resource_group.gvg_auc_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create Bastion Host
resource "azurerm_bastion_host" "auc_jmp_bastion" {
  name                = "aucprdbastion"
  location            = azurerm_resource_group.gvg_auc_group.location
  resource_group_name = azurerm_resource_group.gvg_auc_group.name

  ip_configuration {
    name                 = "bastionconfig"
    subnet_id            = azurerm_subnet.list_of_subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.auc_jmp_pip.id
  }
}

#----------------------------------------------------------------------------#
#                       Create LoadBalancer Resources                        #
#----------------------------------------------------------------------------#

# Create Internal LoadBalancer
resource "azurerm_lb" "gm_auc_lb" {
  name                = "${local.vm_name_map["auc"]}-ilb"
  location            = azurerm_resource_group.gvg_auc_group.location
  resource_group_name = azurerm_resource_group.gvg_auc_group.name
  sku                 = "Standard"
  depends_on          = [azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]
  tags                = local.tags

  frontend_ip_configuration {
    name                          = "gvpnfrontend"
    subnet_id                     = azurerm_subnet.list_of_subnets["OP-AUC-FRT-SN-01"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.list_of_subnets["OP-AUC-FRT-SN-01"].address_prefix, 4)
  }
}

# Create Backend Pool
resource "azurerm_lb_backend_address_pool" "gm_auc_lb_backend" {
  resource_group_name = azurerm_resource_group.gvg_auc_group.name
  loadbalancer_id     = azurerm_lb.gm_auc_lb.id
  name                = "${local.vm_name_map["auc"]}-backend-pool"
}

# Create LB Probe
resource "azurerm_lb_probe" "gm_auc_lb_probe" {
  resource_group_name = azurerm_resource_group.gvg_auc_group.name
  loadbalancer_id     = azurerm_lb.gm_auc_lb.id
  name                = "gvpn-probe"
  port                = 80
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Create LB Rule
resource "azurerm_lb_rule" "gm_auc_lb_rule" {
  resource_group_name            = azurerm_resource_group.gvg_auc_group.name
  loadbalancer_id                = azurerm_lb.gm_auc_lb.id
  name                           = "gvpn-lb-rule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "gvpnfrontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.gm_auc_lb_backend.id
  probe_id                       = azurerm_lb_probe.gm_auc_lb_probe.id
  enable_floating_ip             = false
  load_distribution              = "Default"
  idle_timeout_in_minutes        = 4
  disable_outbound_snat          = false
}

# Create LB Backend Address Pool Association with VM NIC01
resource "azurerm_network_interface_backend_address_pool_association" "gm_auc_bck_nic01" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.gm_auc_nic1[count.index].id
  ip_configuration_name   = "${local.gm_auc_nic_map[count.index]}-nic01-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.gm_auc_lb_backend.id
}

# Create LB Backend Address Pool Association with VM NIC02
resource "azurerm_network_interface_backend_address_pool_association" "gm_auc_bck_nic02" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.gm_auc_nic2[count.index].id
  ip_configuration_name   = "${local.gm_auc_nic_map[count.index]}-nic02-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.gm_auc_lb_backend.id
}

#----------------------------------------------------------------------------#
#                       GM Virtual Machine Resources                         #
#----------------------------------------------------------------------------#

# Create VM configuration

resource "azurerm_linux_virtual_machine" "gm_auc_vm" {
  count                 = 2
  name                  = "${local.vm_name_map["auc"]}-gm${count.index + 1}"
  location              = azurerm_resource_group.gvg_auc_group.location
  resource_group_name   = azurerm_resource_group.gvg_auc_group.name
  network_interface_ids = [azurerm_network_interface.gm_auc_nic1[count.index].id, azurerm_network_interface.gm_auc_nic2[count.index].id]
  size                  = "Standard_DS2_v2"
  availability_set_id   = azurerm_availability_set.gvg_auc_aset.id

  admin_username = data.azurerm_key_vault_secret.rtr_username.value
  admin_password = local.gm_auc_sec_map[count.index]

  disable_password_authentication = false

  ## Pass in custom data to the Cisco CSR VM at bootup
  #custom_data = count.index == 0 ? base64encode(data.template_file.gm_auc_init_file_1.rendered) : base64encode(data.template_file.gm_auc_init_file_2.rendered)

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
    name                 = "${local.vm_name_map["auc"]}-gm${count.index + 1}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.gvgsaccount_auc.primary_blob_endpoint
  }

  tags = local.tags

  # depends_on = [azurerm_marketplace_agreement.accept_terms]
}

#----------------------------------------------------------------------------#
#                   Jumphost Virtual Machine Resources                       #
#----------------------------------------------------------------------------#

resource "azurerm_windows_virtual_machine" "auc_jmp_vm" {
  name                  = "aucprdjumphost"
  location              = azurerm_resource_group.gvg_auc_group.location
  resource_group_name   = azurerm_resource_group.gvg_auc_group.name
  size                  = "Standard_F2"
  admin_username        = data.azurerm_key_vault_secret.auc_jmp_username.value
  admin_password        = data.azurerm_key_vault_secret.auc_jmp_password.value
  network_interface_ids = [azurerm_network_interface.jmp_auc_nic1.id, ]
  tags                  = local.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}