variable "public_key_path" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "db_username" {
  type    = string
  default = "dbadmin"
}

variable "db_password" {
  type      = string
  sensitive = true
}