# Habilitar APIs necessárias no GCP
resource "google_project_service" "aiplatform" {
  project = "377604913138-29iibpphmcnvg4464jmfg2heu9kcluf9.apps.googleusercontent.com"
  service = "aiplatform.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "vision" {
  project = "377604913138-29iibpphmcnvg4464jmfg2heu9kcluf9.apps.googleusercontent.com"
  service = "vision.googleapis.com"
  disable_dependent_services = true
}

# Configurar um bucket no Google Cloud Storage (opcional, para armazenar modelos ou dados)
resource "google_storage_bucket" "neotron_bucket" {
  name          = "neotron-data-bucket"
  location      = "US-CENTRAL1"
  force_destroy = true
}
