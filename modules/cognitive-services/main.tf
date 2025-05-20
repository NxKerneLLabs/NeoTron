# Cognitive Services Module - main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_project_service" "cognitive_apis" {
  for_each = toset(var.enabled_apis)
  project  = var.project_id
  service  = each.value
}

# Example: Add a resource for a GCP AI service, such as Vertex AI
# Uncomment and edit this block based on your actual use case
# resource "google_vertex_ai_featurestore" "example" {
#   name     = var.featurestore_name
#   project  = var.project_id
#   location = var.region
# }
