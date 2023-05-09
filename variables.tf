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

variable "digitalocean_database_cluster_name" {
    type        = string
    description = "Database Cluster Name"
    default     = "wparaiso-db"
}

variable "digitalocean_database_cluster_engine" {
    type        = string
    description = "Database Cluster Engine"
    default     = "mysql"
}

variable "digitalocean_database_cluster_version" {
    type        = string
    description = "Database Cluster Version"
    default     = "8"
}

variable "digitalocean_database_cluster_size" {
    type        = string
    description = "Database Cluster Size"
    default     = "db-s-1vcpu-1gb"
}

variable "digitalocean_database_cluster_node_count" {
    type        = number
    description = "Database Cluster Node Count"
    default     = 1
}

variable "admin_ip_scope" {
    type        = string
    description = "Administrative ip address scope"
}

variable "database_wordpress_name" {
    type        = string
    description = "Database Wordpress name"
    default     = "wordpress"
}

variable "database_wordpress_user" {
    type        = string
    description = "Database wordpress user"
    default     = "wordpress_user"
}
