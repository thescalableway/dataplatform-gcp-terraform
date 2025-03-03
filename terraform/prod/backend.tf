terraform {
  backend "gcs" {
    bucket = "test-project-tfstate"
    prefix = "terraform/state/prod"
  }
}
