#PLEASE refer to the README.md for accepted values FOR THE VARIABELS BELOW
client_secret         = "PLEASE ENTER CLIENT SECRET"                                     # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
client_id             = "PLEASE ENTER CLIENT ID"                                         # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
tenant_id             = "PLEASE ENTER TENANT ID"                                         # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
subscription_id       = "PLEASE ENTER SUBSCRIPTION ID"                                   # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
source_image_vhd_uri  = "noCustomUri"
resource_group_name   = "PLEASE ENTER RESOURCE GROUP NAME"                               # "checkpoint-vmss-terraform"
frontend_subnet       = "Frontend"
backend_subnet        = "Backend"
vnet_resource_group   = "PLEASE ENTER VNET RESOURCE GROUP NAME"                          # "checkpoint-vmss-terraform"
sg_name               = "PLEASE ENTER VM NAME"                                           # "sg-machine"
location              = "Switzerland North"
admin_password        = "PLEASE ENTER ADMIN PASSWORD"                                    # "xxxxxxxxxxxx"
vm_size               = "Standard_D3_v2"
disk_size             = "110"
vm_os_sku             = "sg-byol"
vm_os_offer           = "check-point-cg-r8110"
os_version            = "R81.10"
bootstrap_script      = ""
allow_upload_download = true
authentication_type   = "Password"
enable_custom_metrics = false
sic_key               = "PLEASE ENTER SIC KEY"                                           # "xxxxxxxxxxxx"

############------Networking-------###################
vnet_name                     = "PLEASE ENTER VIRTUAL NETWORK NAME"                      # "checkpoint-vmss-vnet"
address_space                 = "PLEASE ENTER VIRTUAL NETWORK ADDRESS SPACE"             # "10.0.0.0/16"
subnet_prefixes               = "PLEASE ENTER ADDRESS PREFIXES FOR SUBNETS"              # ["10.0.1.0/24","10.0.2.0/24"]
management_GUI_client_network = "0.0.0.0/0"
