terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "neotron-460405 "
  region  = "us-central1" # Ajuste conforme sua preferência de região
  credentials = file("~/.gcp/neotron-460405-1f9de633812b.json") # Caminho para o arquivo JSON
}

