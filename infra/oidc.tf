resource "azurerm_virtual_network" "velero" {
  name                = "virtnetname"
  address_space       = ["10.0.0.0/16"]
  location            = "canada central"
  resource_group_name = azurerm_resource_group.velero.name
}

resource "azurerm_subnet" "velero" {
  name                 = "subnetname"
  resource_group_name  = azurerm_resource_group.velero.name
  virtual_network_name = azurerm_virtual_network.velero.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on           = [azurerm_resource_group.velero]

  # delegation {
  #   name = "delegationname"
  #   service_delegation {
  #     name    = "Microsoft.Web/serverFarms"
  #     actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  #   }
  # }

}
# resource "azurerm_service_plan" "example" {
#   name                = "example-appserviceplan"
#   location            = azurerm_resource_group.velero.location
#   resource_group_name = azurerm_resource_group.velero.name
#   os_type  = "Linux"
#   sku_name = "P1v2"
# }

# data "azurerm_client_config" "example" {
# }

# resource "azurerm_role_assignment" "api" {
#   scope                = azurerm_resource_group.velero.id
#   role_definition_name = "AcrPul"
# #  principal_id =  azurerm_app_service_plan.example.identity[0].principal_id 
#   principal_id =  data.azurerm_client_config.example.object_id
#   depends_on = [ azurerm_linux_web_app.example, azurerm_subnet.example ]

# }

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_virtual_machine.example.identity[0].principal_id

  depends_on = [azurerm_linux_virtual_machine.example]
}

resource "azurerm_container_registry" "acr" {
  name                = "teeworksacr"
  location            = azurerm_resource_group.velero.location
  resource_group_name = azurerm_resource_group.velero.name
  sku                 = "Premium"
  admin_enabled       = false

  identity {
    type = "SystemAssigned"
  }

  # georeplications {
  #   location = "canada central"
  # }
}

resource "azurerm_public_ip" "api" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.velero.name
  location            = azurerm_resource_group.velero.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-linux-vm"
  resource_group_name = azurerm_resource_group.velero.name
  location            = azurerm_resource_group.velero.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  # admin_password      = "P@ssw0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azure_vm_key.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.velero.location
  resource_group_name = azurerm_resource_group.velero.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.velero.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.api.id
  }
}

resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.velero.location
  resource_group_name = azurerm_resource_group.velero.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix      = "75.158.89.94/32"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-8080"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8080"]
    source_address_prefix      = "75.158.89.94/32"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-grafana"
    priority                   = 3000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3000"]
    source_address_prefix      = "75.158.89.94/32"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-prometheus"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["9090"]
    source_address_prefix      = "75.158.89.94/32"
    destination_address_prefix = "*"
  }

}
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.velero.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# resource "azurerm_network_security_rule" "allow_prometheus" {
#   name                        = "Allow-Prometheus"
#   resource_group_name = azurerm_resource_group.velero
#   priority                    = 1001
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_ranges     = ["9090"]
#   source_address_prefixes     = ["YOUR_IP_ADDRESS"]
#   destination_address_prefix  = "*"
# }

# resource "azurerm_network_security_rule" "allow_grafana" {
#   name                        = "Allow-Grafana"
#   priority                    = 1002
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_ranges     = ["3000"]
#   source_address_prefixes     = ["YOUR_IP_ADDRESS"]
#   destination_address_prefix  = "*"
# }
