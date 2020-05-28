#----------------------------------------------------------------------------#
#                          Create Virtual Networks                           #
#----------------------------------------------------------------------------#

# Create Virtual Networks
resource "azurerm_virtual_network" "gvpn_vnets" {
  for_each            = local.vnet_list
  name                = each.key
  resource_group_name = local.vnet_rgroup_map[substr(each.key, 0, 6)]
  location            = local.subnet_location_map[substr(each.key, 0, 6)]
  address_space       = [each.value, ]
  depends_on          = [azurerm_resource_group.gvg_aus_group, azurerm_resource_group.gvg_aue_group, azurerm_resource_group.gvg_auc_group]
}

#----------------------------------------------------------------------------#
#                               Create Subnets                               #
#----------------------------------------------------------------------------#

# Create Subnets in AUC OFFICE VNET
resource "azurerm_subnet" "list_of_subnets" {
  for_each                                       = local.list_of_subnets
  name                                           = each.key
  address_prefixes                               = [each.value, ]
  virtual_network_name                           = local.vnet_map[substr(each.key, 0, 6)]
  resource_group_name                            = local.vnet_rgroup_map[substr(each.key, 0, 6)]
  enforce_private_link_endpoint_network_policies = substr(each.key, 0, 2) == "SS" ? true : false
  depends_on                                     = [azurerm_resource_group.gvg_aus_group, azurerm_resource_group.gvg_aue_group, azurerm_resource_group.gvg_auc_group, azurerm_virtual_network.gvpn_vnets]
}

#----------------------------------------------------------------------------#
#                             Create Route Tables                            #
#----------------------------------------------------------------------------#

resource "azurerm_route_table" "gvg_route_tables" {
  for_each                      = local.list_of_subnets
  name                          = "RT-${each.key}"
  location                      = local.subnet_location_map[substr(each.key, 0, 6)]
  resource_group_name           = local.vnet_rgroup_map[substr(each.key, 0, 6)]
  disable_bgp_route_propagation = false
  depends_on                    = [azurerm_resource_group.gvg_aus_group, azurerm_resource_group.gvg_aue_group, azurerm_resource_group.gvg_auc_group, azurerm_virtual_network.gvpn_vnets, azurerm_subnet.list_of_subnets]
}

# resource "azurerm_route" "example" {
#   name                = "acceptanceTestRoute1"
#   resource_group_name = azurerm_resource_group.example.name
#   route_table_name    = azurerm_route_table.example.name
#   address_prefix      = "10.1.0.0/16"
#   next_hop_type       = "vnetlocal"
# }

#----------------------------------------------------------------------------#
#                             Create VNET Peerings                           #
#----------------------------------------------------------------------------#

resource "azurerm_virtual_network_peering" "vnet_peerings" {
  for_each                     = local.peering_list
  name                         = "${each.key}-to-${each.value}"
  resource_group_name          = local.vnet_rgroup_map[substr(each.key, 0, 6)]
  virtual_network_name         = each.key
  remote_virtual_network_id    = azurerm_virtual_network.gvpn_vnets[each.value].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  depends_on                   = [azurerm_resource_group.gvg_aus_group, azurerm_resource_group.gvg_aue_group, azurerm_resource_group.gvg_auc_group, azurerm_virtual_network.gvpn_vnets]
}

#----------------------------------------------------------------------------#
#                     Create Network Security Groups                         #
#----------------------------------------------------------------------------#

# resource "azurerm_network_security_group" "example" {
#   name                = "${var.prefix}-nsg"
#   resource_group_name = "${azurerm_resource_group.example.name}"
#   location            = "${azurerm_resource_group.example.location}"
# }

# # NOTE: this allows SSH from any network
# resource "azurerm_network_security_rule" "ssh" {
#   name                        = "ssh"
#   resource_group_name         = "${azurerm_resource_group.example.name}"
#   network_security_group_name = "${azurerm_network_security_group.example.name}"
#   priority                    = 102
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "22"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
# }