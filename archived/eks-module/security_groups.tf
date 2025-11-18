resource "aws_security_group" "cluster" {
  description = "SG for EKS Control Plane"
  name        = "${var.project_name}-eks-cluster-sg"
  vpc_id      = var.vpc_id

  tags = {
    Name      = "${var.project_name}-EKS-Cluster-SG"
    ManagedBy = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "nodes" {
  description = "SG for EKS Worker Nodes"
  name        = "${var.project_name}-EKS-Nodes-SG"
  vpc_id      = var.vpc_id

  tags = {
    Name                                        = "${var.project_name}-EKS-Nodes-SG"
    ManagedBy                                   = "Terraform"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_vpc_security_group_ingress_rule" "cluster_to_nodes_kubelet" {
  description                  = "Control Plane to Kubelet (kubectl, logs, exec etc.)"
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.cluster.id
  ip_protocol                  = "tcp"
  from_port                    = 10250
  to_port                      = 10250
}

resource "aws_vpc_security_group_ingress_rule" "cluster_to_nodes_443" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.cluster.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_ingress_rule" "nodes_to_nodes_all" {
  description                  = "Node-to-Node and Pod-to-Pod communicaion"
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.nodes.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "nodes_to_cluster_443" {
  description                  = "Worker Nodes to Control Plane API"
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.cluster.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "nodes_to_internet_https" {
  description       = "Pull container image"
  security_group_id = aws_security_group.nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "nodes_to_internet_dns" {
  description       = "DNS resolution for external domains"
  security_group_id = aws_security_group.nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
}

resource "aws_vpc_security_group_ingress_rule" "nodes_to_cluster" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.nodes.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "cluster_to_nodes_kubelet" {
  description                  = "Control Plane to Kubelet for logs, metrics etc."
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.nodes.id
  ip_protocol                  = "tcp"
  from_port                    = 10250
  to_port                      = 10250
}

resource "aws_vpc_security_group_egress_rule" "cluster_to_nodes_https" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.nodes.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}
