# Module docs: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws

data "aws_eks_cluster_auth" "eks_cluster" {
  name = var.eks_cluster_name
}

module "eks_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.5"
  cluster_name    = var.eks_cluster_name
  cluster_version = "1.29"
  subnet_ids      = module.cs_vpc.vpc_private_subnets
  vpc_id          = module.cs_vpc.vpc_id
  
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.xlarge"]
      capacity_type  = "SPOT"

      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy            = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }

  cluster_security_group_additional_rules = {
    # open up access to higher ports from control plane
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    # open up traffic from control pkane
    control_plane_all = {
      description = "Control plane all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      source_cluster_security_group = true
    }
    # open up node-to-node traffic
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    # allow wide internet access
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  tags = {
    Terraform   = "true"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
  }
}

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}

# bootstrap with Caddy Ingress
resource "helm_release" "caddy" {
  name       = "caddy-ingress"
  namespace  = "caddy-system"
  create_namespace = true
  repository = "https://caddyserver.github.io/ingress/"
  chart      = "caddy-ingress-controller"
  version    = "1.1.0"

  set {
    name  = "ingressController.config.email"
    value = var.caddy_acme_email
  }

}

data "kubernetes_service" "caddy" {
  metadata {
    name = "caddy-ingress-caddy-ingress-controller"
    namespace  = "caddy-system"
  }
  depends_on = [
    helm_release.caddy,
  ]
}
