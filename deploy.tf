# Configure the Azure Provider
provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.20.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "terraformDeployment" {
  name     = "chrismiller-fidalgo-rg"
  location = "East US 2"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "terraformDeployment" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.terraformDeployment.name
  location            = azurerm_resource_group.terraformDeployment.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "terraformDeployment" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.terraformDeployment.name
  virtual_network_name = azurerm_virtual_network.terraformDeployment.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "terraformDeployment" {
  name                = "example-nic"
  location            = azurerm_resource_group.terraformDeployment.location
  resource_group_name = azurerm_resource_group.terraformDeployment.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terraformDeployment.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "terraformDeployment" {
  name                = "chrismiller-fidalgo-machine"
  disable_password_authentication = "false"
  resource_group_name = azurerm_resource_group.terraformDeployment.name
  location            = azurerm_resource_group.terraformDeployment.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "TestPassword123!"
  network_interface_ids = [
    azurerm_network_interface.terraformDeployment.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}