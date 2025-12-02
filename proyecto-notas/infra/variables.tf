variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "notes-eks-cluster"
}

variable "db_name" {
  type    = string
  default = "notesdb"
}

variable "db_user" {
  type    = string
  default = "notesuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}
