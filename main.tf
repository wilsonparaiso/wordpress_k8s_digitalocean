terraform {
  required_version = ">= 1.0" 
}

resource "digitalocean_vpc" "wparaiso_vpc" {
  name     = "wparaiso-vpc"
  region   = var.digitalocean_region
  ip_range = "192.168.0.0/16"
}

resource "digitalocean_firewall" "wparaiso_firewall" {
  name = "wparaiso-firewall"

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "1-65535"
    source_addresses = ["192.168.0.0/16"]
  }
  tags = ["k8s"]
}


resource "digitalocean_kubernetes_cluster" "wparaiso_cluster" {
  name     = var.digitalocean_kubernetes_cluster_name
  region   = var.digitalocean_region
  version  = var.digitalocean_kubernetes_cluster_version
  vpc_uuid = digitalocean_vpc.wparaiso_vpc.id

  node_pool {
    name       = var.digitalocean_kubernetes_cluster_node_pool_name
    size       = var.digitalocean_kubernetes_cluster_node_pool_size
    node_count = var.digitalocean_kubernetes_cluster_node_pool_count
    tags = ["k8s"]
  }

  tags = ["k8s"]
}

resource "local_file" "kubeconfig" {
  content  = digitalocean_kubernetes_cluster.wparaiso_cluster.kube_config[0].raw_config
  filename = "kubeconfig.yaml"
}

resource "helm_release" "wordpress" {
  name       = "wordpress"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "wordpress"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

}
