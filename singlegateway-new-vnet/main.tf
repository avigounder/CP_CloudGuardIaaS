//********************** Providers **************************//
provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

//********************** Basic Configuration **************************//
module "common" {
  source              = "./modules/common"
  resource_group_name = var.resource_group_name
  location            = var.location
  admin_password      = var.admin_password
  installation_type   = var.installation_type
  template_name       = var.template_name
  template_version    = var.template_version
  # number_of_vm_instances = 1
  allow_upload_download = var.allow_upload_download
  vm_size               = var.vm_size
  disk_size             = var.disk_size
  is_blink              = true
  os_version            = var.os_version
  vm_os_sku             = var.vm_os_sku
  vm_os_offer           = var.vm_os_offer
  authentication_type   = var.authentication_type
}

//********************** Networking **************************//
module "vnet" {
  source = "./modules/vnet"

  vnet_name           = var.vnet_name
  resource_group_name = module.common.resource_group_name
  location            = module.common.resource_group_location
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
}


resource "azurerm_network_interface" "nic1" {
  name                          = "eth0"
  location                      = module.common.resource_group_location
  resource_group_name           = module.common.resource_group_name
  enable_ip_forwarding          = false
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = var.vnet_allocation_method
    private_ip_address            = cidrhost(var.subnet_prefixes[0], 4)
  }
}
resource "azurerm_network_interface" "nic2" {
  name                          = "eth1"
  location                      = module.common.resource_group_location
  resource_group_name           = module.common.resource_group_name
  enable_ip_forwarding          = false
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = module.vnet.vnet_subnets[1]
    private_ip_address_allocation = var.vnet_allocation_method
    private_ip_address            = cidrhost(var.subnet_prefixes[1], 4)
  }
}


//********************** Virtual Machines **************************//
locals {
  SSH_authentication_type_condition = var.authentication_type == "SSH Public Key" ? true : false
  custom_image_condition            = var.source_image_vhd_uri == "noCustomUri" ? false : true
}

resource "azurerm_image" "custom-image" {
  count               = local.custom_image_condition ? 1 : 0
  name                = "custom-image"
  location            = var.location
  resource_group_name = module.common.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.source_image_vhd_uri
  }
}

resource "azurerm_virtual_machine" "sg-vm-instance" {
  depends_on = [
    azurerm_network_interface.nic1,
    azurerm_network_interface.nic2
  ]

  location = module.common.resource_group_location
  name     = var.sg_name
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
    azurerm_network_interface.nic2.id
  ]
  resource_group_name           = module.common.resource_group_name
  vm_size                       = module.common.vm_size
  delete_os_disk_on_termination = module.common.delete_os_disk_on_termination
  primary_network_interface_id  = azurerm_network_interface.nic1.id

  identity {
    type = module.common.vm_instance_identity
  }

  dynamic "plan" {
    for_each = local.custom_image_condition ? [
    ] : [1]
    content {
      name      = module.common.vm_os_sku
      publisher = module.common.publisher
      product   = module.common.vm_os_offer
    }
  }

  os_profile {
    computer_name  = var.sg_name
    admin_username = module.common.admin_username
    admin_password = module.common.admin_password
    custom_data = templatefile("${path.module}/cloud-init.sh", {
      installation_type             = module.common.installation_type
      allow_upload_download         = module.common.allow_upload_download
      os_version                    = module.common.os_version
      template_name                 = module.common.template_name
      template_version              = module.common.template_version
      is_blink                      = module.common.is_blink
      bootstrap_script64            = base64encode(var.bootstrap_script)
      location                      = module.common.resource_group_location
      sic_key                       = var.sic_key
      management_GUI_client_network = var.management_GUI_client_network
      enable_custom_metrics         = var.enable_custom_metrics ? "yes" : "no"
    })
  }
  os_profile_linux_config {
    disable_password_authentication = local.SSH_authentication_type_condition

    dynamic "ssh_keys" {
      for_each = local.SSH_authentication_type_condition ? [
      1] : []
      content {
        path     = "/home/notused/.ssh/authorized_keys"
        key_data = file("${path.module}/azure_public_key")
      }
    }
  }

  storage_image_reference {
    id        = local.custom_image_condition ? azurerm_image.custom-image[0].id : null
    publisher = local.custom_image_condition ? null : module.common.publisher
    offer     = module.common.vm_os_offer
    sku       = module.common.vm_os_sku
    version   = module.common.vm_os_version
  }

  storage_os_disk {
    name              = var.sg_name
    create_option     = module.common.storage_os_disk_create_option
    caching           = module.common.storage_os_disk_caching
    managed_disk_type = module.common.storage_account_type
    disk_size_gb      = module.common.disk_size
  }
}

resource "azurerm_role_assignment" "custom_metrics_role_assignment" {
  depends_on         = [azurerm_virtual_machine.sg-vm-instance]
  count              = var.enable_custom_metrics ? 1 : 0
  role_definition_id = join("", ["/subscriptions/", var.subscription_id, "/providers/Microsoft.Authorization/roleDefinitions/", "3913510d-42f4-4e42-8a64-420c390055eb"])
  principal_id       = lookup(azurerm_virtual_machine.sg-vm-instance.identity[0], "principal_id")
  scope              = module.common.azurerm_resource_group_id
  lifecycle {
    ignore_changes = [
      role_definition_id, principal_id
    ]
  }
}


