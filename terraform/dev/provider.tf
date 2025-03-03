provider "google" {
  region      = var.region
  project     = var.project_name
  credentials = file(var.credentials_file)
  zone        = var.zone
}
