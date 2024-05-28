provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-terraform-assignment-group-131"
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = "West Europe"
}

resource "azurerm_storage_account" "main" {
  name                     = "samlworkspacegroup131"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-terraform-assignment-group-131"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "subnet-terraform-assignment-group-131"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]  # Adjust this according to your network requirements
}

resource "azurerm_public_ip" "main" {
  name                = "public-ip-terraform-assignment-group-131"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-terraform-assignment-group-131"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig-terraform-assignment-group-131"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "ml-workspace-group"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_DS1_v2"  # Adjust this according to your VM size requirements
  admin_username        = var.admin_username  # Use the declared variable here
  network_interface_ids = [azurerm_network_interface.main.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
  offer                 = "0001-com-ubuntu-server-focal"
  publisher             = "Canonical"
  sku                   = "20_04-lts-gen2"
  version               = "latest"
  }

  admin_ssh_key {
    username   = var.admin_username  # Use the declared variable here
    public_key = file("~/.ssh/id_rsa.pub")  # Path to your SSH public key file
  }

provisioner "remote-exec" {
  inline = [
    "sudo apt update",
    "sudo apt -y upgrade",
    "sudo add-apt-repository -y ppa:deadsnakes/ppa",  # Added -y flag
    "sudo apt update",
    "sudo apt install -y python3.9",  # Added -y flag
    "sudo apt install -y python3.9-distutils",  # Added -y flag
    "curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py",
    "sudo python3.9 get-pip.py",
    "sudo apt install -y software-properties-common",  # Added -y flag
    "sudo pip install pandas joblib scikit-learn==1.0.1",
    "mkdir -p /home/${var.admin_username}/machine-learning"
  ]

    connection {
      type        = "ssh"
      host        = self.public_ip_address
      user        = var.admin_username
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "file" {
    source      = "data/"
    destination = "/home/${var.admin_username}/machine-learning"
    connection {
      type        = "ssh"
      host        = self.public_ip_address
      user        = var.admin_username
      private_key = file("~/.ssh/id_rsa")
    }
  }
}
