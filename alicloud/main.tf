# Alicloud Providerの設定
provider "alicloud" {
  access_key = var.alicloud_access_key
  secret_key = var.alicloud_secret_key
  region     = var.alicloud_region
}

# 有効なゾーンを問い合わせ、local.all_zonesで参照する
data "alicloud_zones" "available" {
}
locals {
  all_zones = data.alicloud_zones.available.ids
}

# VPCの作成
resource "alicloud_vpc" "vpc" {
  name       = "${var.base_name}-vpc"
  cidr_block = var.vpc_cidr
}

# vswitch(subnet)の作成
resource "alicloud_vswitch" "vsw" {
  count             = length(local.all_zones)
  name              = "${var.base_name}-${local.all_zones[count.index]}"
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_netmask_bits, var.subnet_offset + count.index)
  availability_zone = local.all_zones[count.index]
}
