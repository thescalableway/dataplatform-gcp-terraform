variable "credentials_file" {
  default = "test-project-7a895ad12eed.json"
}

variable "environment" {
  default = "dev"
}

variable "filesystem" {
  default = "ext4"
}

variable "image" {
  default = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20241115"
}

variable "ip_cidr_range" {
  default = "10.201.0.0/24"
}

variable "machine_type" {
  default = "c3d-standard-8-lssd"
}

variable "project_name" {
  default = "test-project"
}

variable "region" {
  default = "us-central1"
}

variable "service_account" {
  default = "serviceAccount:test-project-service-account@test-project.iam.gserviceaccount.com"
}

variable "zone" {
  default = "us-central1-c"
}
