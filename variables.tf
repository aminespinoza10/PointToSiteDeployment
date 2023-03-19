###Common data
variable "app_name" {
  type        = string
  description = "This variable defines the application name used to build resources"
}

variable "company" {
  type        = string
  description = "This variable defines the company name used to build resources"
}

variable "prefix" {
  type        = string
  description = "This variable defines the company name prefix used to build resources"
}

variable "location" {
  type        = string
  description = "Azure region where the resource group will be created"
  default     = "UK South"
}

variable "region" {
  type        = string
  description = "Azure region code where the resource group will be created"
  default     = "uks"
}

variable "environment" {
  type        = string
  description = "This variable defines the environment to be built"
}

###Network
variable "vnet-cidr" {
  type        = string
  description = "The CIDR of the VNET"
}

variable "gateway-subnet-cidr" {
  type        = string
  description = "The CIDR for the Gateway subnet"
}

variable "default-subnet-cidr" {
  type        = string
  description = "The CIDR for the Gateway subnet"
}

###KeyVault
variable "kv-sku-name" {
  type        = string
  description = "Select Standard or Premium SKU"
  default     = "standard"
}

variable "kv-enabled-for-deployment" {
  type        = string
  description = "Allow Azure Virtual Machines to retrieve certificates stored as secrets from the Azure Key Vault"
  default     = "true"
}

variable "kv-enabled-for-disk-encryption" {
  type        = string
  description = "Allow Azure Disk Encryption to retrieve secrets from the Azure Key Vault and unwrap keys" 
  default     = "true"
}

variable "kv-enabled-for-template-deployment" {
  type        = string
  description = "Allow Azure Resource Manager to retrieve secrets from the Azure Key Vault"
  default     = "true"
}

variable "kv-key-permissions-full" {
  type        = list(string)
  description = "List of full key permissions, must be one or more from the following: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify and wrapKey."
  default     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
}

variable "kv-secret-permissions-full" {
  type        = list(string)
  description = "List of full secret permissions, must be one or more from the following: backup, delete, get, list, purge, recover, restore and set"
  default     = [ "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set" ]
} 

variable "kv-certificate-permissions-full" {
  type        = list(string)
  description = "List of full certificate permissions, must be one or more from the following: backup, create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers and update"
  default     = [ "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", 
                  "ManageContacts", "ManageIssuers", "Purge", "Recover", "Setissuers", "Update",  "Restore" ]
}

variable "kv-storage-permissions-full" {
  type        = list(string)
  description = "List of full storage permissions, must be one or more from the following: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas and update"
  default     = [ "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", 
                  "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update" ]
}

