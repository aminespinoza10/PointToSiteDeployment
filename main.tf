data "azurerm_client_config" "current_config" {}

locals {
  certificate-name = "${var.company}-RootCert.crt"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.region}-${var.environment}-${var.app_name}-rg"
  location = var.location
  tags = {
    environment = var.environment
  }
}

resource "azurerm_key_vault" "keyvault" {
  name                = "${var.region}-${var.environment}-${var.app_name}-kv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  enabled_for_deployment          = var.kv-enabled-for-deployment
  enabled_for_disk_encryption     = var.kv-enabled-for-disk-encryption
  enabled_for_template_deployment = var.kv-enabled-for-template-deployment
  tenant_id                       = data.azurerm_client_config.current_config.tenant_id

  sku_name = var.kv-sku-name
  
  tags = { 
    environment = var.environment
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current_config.tenant_id
    object_id = data.azurerm_client_config.current_config.object_id

    certificate_permissions = ["Backup", "Delete"]
    key_permissions         = var.kv-key-permissions-full
    secret_permissions      = var.kv-secret-permissions-full
    storage_permissions     = var.kv-storage-permissions-full
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

resource "azurerm_key_vault_secret" "vpn-root-certificate" {
  depends_on=[azurerm_key_vault.keyvault]

  name         = "vpn-root-certificate"
  value        = filebase64(local.certificate-name)
  key_vault_id = azurerm_key_vault.keyvault.id

  tags = {
    environment = var.environment
  }
}

data "azurerm_key_vault_secret" "vpn-root-certificate" {
  depends_on=[
    azurerm_key_vault.keyvault,
    azurerm_key_vault_secret.vpn-root-certificate
  ]
  
  name         = "vpn-root-certificate"
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.region}-${var.environment}-${var.app_name}-vnet"
  address_space       = [var.vnet-cidr]
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  tags = {
    environment = var.environment
  }
}

# Create a Gateway Subnet
resource "azurerm_subnet" "gateway-subnet" {
  name                 = "GatewaySubnet" 
  address_prefixes     = [var.gateway-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "default-subnet" {
  name                 = "default" 
  address_prefixes     = [var.default-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "gateway-ip" {
  name                = "${var.region}-${var.environment}-${var.app_name}-gw-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create VPN Gateway
resource "azurerm_virtual_network_gateway" "vpn-gateway" {
  name                = "${var.region}-${var.environment}-${var.app_name}-gw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "${var.region}-${var.environment}-${var.app_name}-vnet"
    public_ip_address_id          = azurerm_public_ip.gateway-ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway-subnet.id
  }

  vpn_client_configuration {
    address_space = ["10.2.0.0/24"]

    root_certificate {
      name = "VPNROOT"

      public_cert_data = data.azurerm_key_vault_secret.vpn-root-certificate.value
    }

  }
}

/*
resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                = "windowsServerTest12"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
*/
