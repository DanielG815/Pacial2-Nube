output "eks_cluster_name" {
  description = "Nombre del cluster EKS"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint del cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.network.vpc_id
}

output "rds_endpoint" {
  description = "Endpoint de la base de datos RDS"
  value       = module.rds.rds_endpoint
}

output "rds_database_name" {
  description = "Nombre de la base de datos"
  value       = module.rds.rds_database_name
}
