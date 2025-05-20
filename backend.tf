terraform {
  backend "gcs" {
    bucket  = "neotron-data-bucket" # Use o bucket já criado
    prefix  = "terraform/state"
  }
}

