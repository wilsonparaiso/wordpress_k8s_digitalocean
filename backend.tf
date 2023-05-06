terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.28.1"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.10.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.5.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
}

locals {
  kubeconfig = yamldecode(digitalocean_kubernetes_cluster.wparaiso_cluster.kube_config[0].raw_config)
}
