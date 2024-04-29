# Module docs: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws

module "eks_fargate" {
  count           = ( var.deploy_fargate ? 1 : 0 )
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.5"
  cluster_name    = "${var.eks_cluster_name}-fargate"
  cluster_version = "1.29"
  subnet_ids      = module.cs_vpc.vpc_private_subnets
  vpc_id          = module.cs_vpc.vpc_id
  
  cluster_endpoint_public_access = true

  # Fargate Profile(s)
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "app-*"
        },
        {
          namespace = "sock-shop"
        }
      ]
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
