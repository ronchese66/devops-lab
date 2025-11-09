resource "aws_iam_role" "eks_cluster_iam_role" {
  name = "${var.project_name}-EKS-Cluster-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "eks.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })

  tags = {
    Name = "${var.project_name}-EKS-Cluster-role"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSClusterPolicy" {
  role = aws_iam_role.eks_cluster_iam_role.name 
  policy_arn = "arn:aws:iam:aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSServicePolicy" {
  role = aws_iam_role.eks_cluster_iam_role.name 
  policy_arn = "arn:aws:iam:aws:policy/AmazonEKSServicePolicy"
}