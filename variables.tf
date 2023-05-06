variable "digitalocean_token" {
    type        = string
}

variable "digitalocean_region" {
    type        = string
    description = "Region where the resources will be created"
    default     = "nyc1"
}

variable "digitalocean_kubernetes_cluster_name" {
    type        = string
    description = "Kubernetes Cluster Name"
    default     = "wparaiso-cluster"
}

variable "digitalocean_kubernetes_cluster_version" {
    type        = string
    description = "Kubernetes Cluster Version"
    default     = "1.24.12-do.0"
}

variable "digitalocean_kubernetes_cluster_node_pool_name" {
    type        = string
    description = "Kubernetes Cluster Node Pool Name"
    default     = "worker-pool"
}

variable "digitalocean_kubernetes_cluster_node_pool_size" {
    type        = string
    description = "Kubernetes Cluster Node Pool Size"
    default     = "s-2vcpu-4gb"
}

variable "digitalocean_kubernetes_cluster_node_pool_count" {
    type        = number
    description = "Kubernetes Cluster Node Pool Count"
    default     = 1
}

