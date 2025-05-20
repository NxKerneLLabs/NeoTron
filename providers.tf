terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "377604913138-29iibpphmcnvg4464jmfg2heu9kcluf9.apps.googleusercontent.com"
  region  = "us-central1" # Ajuste conforme sua preferência de região
}

