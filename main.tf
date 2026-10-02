module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = var.vpc_cidr
  environment  = var.environment
  cluster_name = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  node_instance_types = var.node_instance_types
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size
  environment         = var.environment
}

module "kong" {
  source = "./modules/kong"

  depends_on = [module.eks]
}

module "kafka" {
  source = "./modules/kafka"

  depends_on = [module.eks]
}

module "monitoring" {
  source = "./modules/monitoring"

  cluster_name         = var.cluster_name
  newrelic_license_key = var.newrelic_license_key

  depends_on = [module.eks]
}

resource "kubernetes_namespace" "workshop" {
  metadata {
    name = "fiap-workshop"
    labels = {
      name = "fiap-workshop"
    }
  }

  depends_on = [module.eks]
}
