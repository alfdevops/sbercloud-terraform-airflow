variable "accesskey" {
  type = string
}
variable "secretkey" {
  type = string
}
variable "nodepassword" {
  type = string
}


terraform {
  required_providers {
    sbercloud = {
      source  = "tf.repo.sbc.space/sbercloud-terraform/sbercloud" # Initialize Advanced provider
    }
  }
}

# Configure Advanced provider
provider "sbercloud" {
  auth_url = "https://iam.ru-moscow-1.hc.sbercloud.ru/v3" # Authorization address
  region   = "ru-moscow-1" # The region where the cloud infrastructure will be deployed

  # Authorization keys
  access_key = "${var.accesskey}"
  secret_key = "${var.secretkey}"
}

resource "sbercloud_vpc" "cce_vpc" {
   name = "cce_vpc"
   cidr = "192.168.0.0/16"
}

resource "sbercloud_vpc_subnet" "cce_vpc_subnet" {
   name          = "cce_vpc_subnet_1"
   cidr          = "192.168.0.0/24"
   gateway_ip    = "192.168.0.1"
   primary_dns   = "100.125.13.59"
   secondary_dns = "100.125.65.14"
   vpc_id        = sbercloud_vpc.cce_vpc.id
}

resource "sbercloud_vpc_eip" "cluster_eip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "cluster_eip"
    size        = 8
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "sbercloud_cce_cluster" "cce_cluster" {
   name                   = "cce-cluster"
   flavor_id              = "cce.s1.small"
   container_network_type = "vpc-router"
   vpc_id                 = sbercloud_vpc. cce_vpc.id
   subnet_id              = sbercloud_vpc_subnet. cce_vpc_subnet.id
   container_network_cidr = "10.0.0.0/16"
   service_network_cidr   = "10.247.0.0/16"
   eip                    = sbercloud_vpc_eip.cluster_eip.address
}

resource "sbercloud_cce_node_pool" "cce_cluster_node_pool" {
   cluster_id               = sbercloud_cce_cluster.cce_cluster.id
   name                     = "cce-cluster-node-pool"
   os                       = "CentOS 7.6"
   initial_node_count       = 1
   flavor_id                = "c3.large.4"
   password                 = "${var.nodepassword}"
   scall_enable             = true
   min_node_count           = 1
   max_node_count           = 2
   scale_down_cooldown_time = 100
   priority                 = 1
   root_volume {
      size       = 40
      volumetype = "SSD"
   }
   data_volumes {
      size       = 100
      volumetype = "SSD"
   }
}

resource "sbercloud_vpc_eip" "lb_ext_ip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "lb_ext_ip"
    size        = 8
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

 resource "sbercloud_vpc_eip" "nat_ext_ip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
  name        = "nat_ext_ip"
  size        = 8
  share_type  = "PER"
  charge_mode = "traffic"
  }
}

resource "sbercloud_lb_loadbalancer" "lb_k8s" {
  name          = "lb_k8s"
  vip_subnet_id = sbercloud_vpc_subnet.cce_vpc_subnet.subnet_id
}

resource "sbercloud_networking_eip_associate" "lb_eip_associate" {
  public_ip = sbercloud_vpc_eip.lb_ext_ip.address
  port_id   = sbercloud_lb_loadbalancer.lb_k8s.vip_port_id
}

resource "sbercloud_nat_gateway" "nat_gw" {
  name        = "nat_gw"
  description = "nat gateway"
  spec        = "1"
  vpc_id      = sbercloud_vpc.cce_vpc.id
  subnet_id   = sbercloud_vpc_subnet.cce_vpc_subnet.id
}

resource "sbercloud_nat_snat_rule" "snat_gw" {
  nat_gateway_id = sbercloud_nat_gateway.nat_gw.id
  subnet_id      = sbercloud_vpc_subnet.cce_vpc_subnet.id
  floating_ip_id = sbercloud_vpc_eip.nat_ext_ip.id
}

output "nat_gw_ip" {
  value = sbercloud_vpc_eip.nat_ext_ip.address
}

output "vb_k8s_ip" {
  value = sbercloud_vpc_eip.lb_ext_ip.address
}

output "cluster_eip" {
  value = sbercloud_vpc_eip.cluster_eip.address
}

output "cluster_info" {
  value = sbercloud_cce_cluster.cce_cluster.status
}
