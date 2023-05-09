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

  inbound_rule {
    protocol         = "tcp"
    port_range       = "1-65535"
    source_addresses = [var.admin_ip_scope]
  }
  tags = ["k8s"]
}

resource "digitalocean_database_firewall" "wparaiso_db_firewall" {
  cluster_id = digitalocean_database_cluster.wparaiso_db.id

  rule {
    type  = "k8s"
    value = digitalocean_kubernetes_cluster.wparaiso_cluster.id
  }
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
  depends_on = [digitalocean_kubernetes_cluster.wparaiso_cluster]
}

resource "digitalocean_database_cluster" "wparaiso_db" {
  name       = var.digitalocean_database_cluster_name
  engine     = var.digitalocean_database_cluster_engine
  version    = var.digitalocean_database_cluster_version
  size       = var.digitalocean_database_cluster_size
  region     = var.digitalocean_region
  node_count = var.digitalocean_database_cluster_node_count
  private_network_uuid = digitalocean_vpc.wparaiso_vpc.id
}

resource "digitalocean_database_user" "wordpress_user" {
  cluster_id = digitalocean_database_cluster.wparaiso_db.id
  name       = var.database_wordpress_user
  depends_on = [digitalocean_database_cluster.wparaiso_db]
}

resource "digitalocean_database_db" "wordpress" {
  cluster_id = digitalocean_database_cluster.wparaiso_db.id
  name       = var.database_wordpress_name
  depends_on = [digitalocean_database_cluster.wparaiso_db]
}


resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  depends_on = [digitalocean_kubernetes_cluster.wparaiso_cluster]
}

resource "digitalocean_domain" "wparaiso_domain" {
  name       = "wparaiso.com"
}

resource "digitalocean_record" "wordpress_dns" {
  domain = digitalocean_domain.wparaiso_domain.name
  type   = "A"
  name   = "www"
  value  = digitalocean_kubernetes_cluster.wparaiso_cluster.endpoint
  ttl    = 3600
  depends_on = [helm_release.nginx_ingress]
}

resource "digitalocean_certificate" "wordpress_cert" {
  name    = "le-wordpress-cert"
  type    = "lets_encrypt"
  domains = [digitalocean_domain.wparaiso_domain.name]
}

resource "helm_release" "wordpress" {
  name       = "wordpress"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "wordpress"
  depends_on = [helm_release.nginx_ingress,digitalocean_database_user.wordpress_user,digitalocean_database_db.wordpress]

  set {
    name  = "mariadb.enabled"
    value = "false"
  }

  set {
    name  = "externalDatabase.host"
    value = digitalocean_database_cluster.wparaiso_db.host
  }

  set {
    name  = "externalDatabase.user"
    value = digitalocean_database_user.wordpress_user.name
  }

  set {
    name  = "externalDatabase.password"
    value = digitalocean_database_user.wordpress_user.password
  }

  set {
    name  = "externalDatabase.database"
    value = digitalocean_database_db.wordpress.name
  }

  set {
    name  = "externalDatabase.port"
    value = digitalocean_database_cluster.wparaiso_db.port
  }

  set { 
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }

  set {
    name  = "ingress.hostname"
    value = "wparaiso.com"
  }
}

