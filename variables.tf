variable "appname" {
  type = string
  description = "The logical name for the application the Application Gateway serves"
}

variable "env" {
  type = string
  description = "values: prod|nonprod"

  # need to force values into slots to prevent Chaos™
  validation {
    condition = can( regex( "^(prod|nonprod)", var.env ) )
    error_message = "$env must be set to 'prod' or 'nonprod'."
  }
}

variable "region" {
  type = string
  description = "values: eastus2|centralus"

  # need to force values into slots to prevent Chaos™
  validation {
    condition = can( regex( "^(eastus2|centralus)", var.region ) )
    error_message = "$region must be set to 'eastus2' or 'centralus'."
  }
}

# dragons are below - user will provide these
# --------------------------------------
variable "backend_subnet_name" {
  type = string
  description = "name for the backend subnet for the appgw.  where are your hosts?"
}

variable "backend_subnet_parent_rg" {
  type = string
  description = "name for the backend subnet's parent resource group"
}

variable "backend_subnet_parent_vnet" {
  type = string
  description = "name for the backend subnet's parent vnet"
}

