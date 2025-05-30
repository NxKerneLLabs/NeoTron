# Habilitar Cloud Resource Manager API (necessária para gerenciar outras APIs)
resource "google_project_service" "cloudresourcemanager" {
  project = "neotron-460405" # Substitua pelo ID correto do projeto
  service = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = true
}

# Habilitar APIs necessárias no GCP
resource "google_project_service" "aiplatform" {
  project = "neotron-460405"
  service = "aiplatform.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "vision" {
  project = "neotron-460405"
  service = "vision.googleapis.com"
  disable_dependent_services = true
}

# Configurar um bucket no Google Cloud Storage (opcional, para armazenar modelos ou dados)
resource "google_storage_bucket" "neotron_bucket" {
  project       = "neotron-460405"
  name          = "neotron-data-bucket"
  location      = "US-CENTRAL1"
  force_destroy = true
}
