provider "digitalocean" {
    token = var.digitalocean_token
}

provider "kubernetes" {
    config_path = local_file.kubeconfig.filename
}

provider "helm" {
    kubernetes {
    config_path = local_file.kubeconfig.filename
    }
}
