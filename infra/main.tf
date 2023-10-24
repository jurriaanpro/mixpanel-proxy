terraform {
  backend "http" {
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.3.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
}
