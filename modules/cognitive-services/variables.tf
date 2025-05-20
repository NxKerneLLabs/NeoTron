# Cognitive Services Module - variables.tf

variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "enabled_apis" {
  description = "List of Google APIs to enable for cognitive services."
  type        = list(string)
  default     = [
    "aiplatform.googleapis.com"
    # Add more APIs as needed
  ]
}

# Example variable for a resource
# variable "featurestore_name" {
#   description = "Name of the Vertex AI Featurestore."
#   type        = string
#   default     = "my-featurestore"
# }

# variable "region" {
#   description = "Region for cognitive services resources."
#   type        = string
#   default     = "us-central1"
# }
