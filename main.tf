module "aws_egress" {
  source                = "github.com/lonegunmanb/ShadowSocksROnAws-Terraform"
  aws_access_key        = var.aws_access_key
  aws_secret_key        = var.aws_secret_key
  region                = var.aws_region
  myip                  = "0.0.0.0/0"
  ami                   = var.aws_ami
  instance_key          = var.instance_pub_key
  private_key_file_path = var.private_key_file_path
  sspassword            = var.sspassword
  cryptor_method        = var.cryptor_method
  auth_method           = var.auth_method
  obfs_method           = var.obfs_method
  port                  = var.port
}

locals {
  aws_ip = module.aws_egress.address
}


provider "tencentcloud" {
  secret_key = var.tencent_secret_key
  secret_id  = var.tencent_secret_id
  region     = var.tencent_region
}

resource "tencentcloud_key_pair" "my_ssh_key" {
  key_name   = "haproxy_ssh_key"
  public_key = var.instance_pub_key
}

resource "tencentcloud_security_group" "haproxy" {
  name = "haproxy"
}

resource "tencentcloud_security_group_rule" "ingress_rule" {
  security_group_id = tencentcloud_security_group.haproxy.id
  type              = "ingress"
  ip_protocol       = "tcp"
  cidr_ip           = "0.0.0.0/0"
  port_range        = "22,443"
  policy            = "accept"
}

resource "tencentcloud_security_group_rule" "egress_rule" {
  security_group_id = tencentcloud_security_group.haproxy.id
  type              = "egress"
  ip_protocol       = "tcp"
  cidr_ip           = "0.0.0.0/0"
  port_range        = "1-65535"
  policy            = "accept"
}

resource "tencentcloud_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"
  name       = "haproxy_vpc"
}

resource "tencentcloud_subnet" "subnet" {
  cidr_block        = "10.0.0.0/24"
  name              = "haproxy_subnet"
  availability_zone = var.tencent_az
  vpc_id            = tencentcloud_vpc.vpc.id
}

data "tencentcloud_image" "centos" {
  os_name = "centos"

  filter {
    name   = "image-type"
    values = [
      "PUBLIC_IMAGE"]
  }
}

resource "tencentcloud_instance" "haproxy" {
  instance_name                       = "haproxy"
  availability_zone                   = var.tencent_az
  image_id                            = data.tencentcloud_image.centos.image_id
  instance_type                       = "${var.tencent_instance_type}"
  key_name                            = tencentcloud_key_pair.my_ssh_key.id
  security_groups                     = [
    tencentcloud_security_group.haproxy.id]
  vpc_id                              = tencentcloud_vpc.vpc.id
  subnet_id                           = tencentcloud_subnet.subnet.id
  instance_charge_type                = var.tencent_charge_type
  instance_charge_type_prepaid_period = var.instance_charge_type_prepaid_period
  internet_max_bandwidth_out          = var.internet_max_bandwidth_out
}

variable "internet_max_bandwidth_out" {
  default = 100
}
resource "tencentcloud_eip" "eip" {
  name                       = "haproxy"
  internet_charge_type       = var.tencent_internet_charge_type
  internet_max_bandwidth_out = var.internet_max_bandwidth_out
}

resource "tencentcloud_eip_association" "eip_association" {
  eip_id      = tencentcloud_eip.eip.id
  instance_id = tencentcloud_instance.haproxy.id
}

data "template_file" "setup" {
  template = file("${path.module}/setup.sh")
  vars     = {
    dest_ip = local.aws_ip
    port    = var.port
  }
}

resource "null_resource" "setup" {
  depends_on = [
    tencentcloud_eip_association.eip_association,
    module.aws_egress.address
  ]
  connection {
    host        = tencentcloud_eip.eip.public_ip
    user        = "root"
    private_key = file(var.private_key_file_path)
  }
  provisioner "remote-exec" {
    inline = [
      data.template_file.setup.rendered]
  }
}

output "ip" {
  value = tencentcloud_eip.eip.public_ip
}
