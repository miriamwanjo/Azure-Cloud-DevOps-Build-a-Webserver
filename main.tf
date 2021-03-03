provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources-group"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags     = var.tags
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_loadbalancer" "main" {
  name     = "LoadBalancerRG"
  location = azurerm_resource_group.main.location
}

resource "azurerm_public_ip" "main" {
  name                = ${var.prefix}-PublicIPaddress"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  tags = {
   tags = var.tags
   }
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-mainLB"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "loadbalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.main.id
  }
  tags = {
   tags = var.tags
   }
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "lbbackendpool"
}

resource "azurerm_lb_probe" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "tcp-probe"
  protocol            = "tcp"
  port                = var.application_port
}

resource "azurerm_lb_rule" "main" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  frontend_ip_configuration_name = "loadbalancerFrontEnd"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
  probe_id                       = azurerm_lb_probe.main.id
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
   tags = var.tags
   }
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count = var.vm_count
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = azurerm_subnet.internal.name #"internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main[count.index].id}"
}

data "azurerm_resource_group" "image" {
  name = "packer-project-rg"
}

data "azurerm_image" "image" {
  name                = "myPackerImage"
  resource_group_name = data.azurerm_resource_group.image.name
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D2s_v3"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name_prefix = "vm_server"
    admin_username       = var.username
    admin_password       = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  os_disk {
    name                 = "myosdisk"
    managed_disk_type    = "Standard_LRS"
    caching              = "ReadWrite"
    create_option        = "FromImage"
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.main.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.main.id]
      primary = true
    }
  }

  tags = {
   tags = var.tags
   }
}
