variable "aws_access_key" {
  type = string
}
variable "aws_secret_key" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "aws_ami" {
  type = string
}
variable "instance_pub_key" {
  default = ""
}
variable "private_key_file_path" {
  default = ""
}
variable "sspassword" {
  default = ""
}
variable "cryptor_method" {
  default = "aes-256-cfb"
}
variable "auth_method" {
  default = "auth_aes128_md5"
}
variable "obfs_method" {
  default = "tls1.2_ticket_auth"
}
variable "port" {
  type    = number
  default = 443
}
variable "tencent_secret_key" {
  type = string
}
variable "tencent_secret_id" {
  type = string
}

variable "tencent_region" {
  type    = string
  default = "ap-hongkong"
}

variable "tencent_az" {
  default = "ap-hongkong-1"
}
variable tencent_instance_type {
  type    = "string"
  default = "S2.SMALL1"
}
//POSTPAID_BY_HOUR
//PREPAID
variable "tencent_charge_type" {
  default = "POSTPAID_BY_HOUR"
}
variable "instance_charge_type_prepaid_period" {
  type    = number
  default = 1
}
//BANDWIDTH_PACKAGE, BANDWIDTH_POSTPAID_BY_HOUR and TRAFFIC_POSTPAID_BY_HOUR
variable "tencent_internet_charge_type" {
  default = "TRAFFIC_POSTPAID_BY_HOUR"
}
