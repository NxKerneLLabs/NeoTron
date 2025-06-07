  # backend.tf
  # Configuração do backend remoto para armazenar o estado do Terraform no Google Cloud Storage (GCS)

  terraform {
    backend "gcs" {
      bucket  = "neotron-data-bucket"  # Bucket GCS para armazenar o estado
      prefix  = "terraform/state"      # Prefixo/diretório dentro do bucket para organização
    }
  }

  # Recurso para criar o bucket GCS, caso ainda não exista
  # Se o bucket já existe, comente ou remova este bloco
  resource "google_storage_bucket" "state_bucket" {
    name          = "neotron-data-bucket"
    location      = var.region
    force_destroy = false

    versioning {
      enabled = true
    }

    lifecycle_rule {
      condition {
        age = 90
      }
      action {
        type = "Delete"
      }
    }
  }

  # Política IAM para garantir que a conta de serviço do Terraform tenha acesso ao bucket
  resource "google_storage_bucket_iam_member" "state_bucket_access" {
    bucket = google_storage_bucket.state_bucket.name
    role   = "roles/storage.objectAdmin"
    member = "serviceAccount:your-terraform-sa@your-project.iam.gserviceaccount.com"  # Substitua pela sua conta de serviço
  }

