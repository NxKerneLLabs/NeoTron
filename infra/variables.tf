# variables.tf (trecho)
variable "project_id" {
  description = "neotron-460405"
  type        = string
  default     = "your-project-id"  # Substitua pelo ID real do seu projeto
}

variable "region" {
  description = "Região padrão para recursos GCP"
  type        = string
  default     = "us-central1"  # Ajuste conforme sua localização preferida
}

