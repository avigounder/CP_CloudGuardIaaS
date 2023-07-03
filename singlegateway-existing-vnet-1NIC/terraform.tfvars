#PLEASE reffer to the README.md for accepted values FOR THE VARIABELS BELOW
client_secret         = "HAp8Q~2aZGZHwkprvjU2c5pZg5ExXIFsGonrBaU1"
client_id             = "99579f82-19d9-42a8-9ece-5a9e41b1c956"
tenant_id             = "2fa2ec5a-717a-4157-8e6c-f3ec61fed660"
subscription_id       = "688c2d9c-91bf-4474-98b4-a452b3ab0fd3"
source_image_vhd_uri  = "noCustomUri"
resource_group_name   = "checkpoint-rg"
frontend_subnet       = "Frontend"
vnet_resource_group   = "checkpoint-rg"
sg_name               = "sg-machine"
location              = "Switzerland North"
admin_password        = "AzureP0C@2023"
vm_size               = "Standard_D3_v2"
disk_size             = "110"
vm_os_sku             = "sg-byol"
vm_os_offer           = "check-point-cg-r8110"
os_version            = "R81.10"
bootstrap_script      = ""
allow_upload_download = true
authentication_type   = "Password"
enable_custom_metrics = false
sic_key               = "123456789101112"

############------Networking-------###################
vnet_name                     = "checkpoint-vnet"
address_space                 = "10.0.0.0/16"
subnet_prefixes               = ["10.0.1.0/24"]
management_GUI_client_network = "0.0.0.0/0"
