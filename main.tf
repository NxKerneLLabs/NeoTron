provider "azurerm" {
  features {}
}

module "cognitive_services" {
  source              = "./modules/cognitive-services"
  resource_group_name = var.resource_group_name
  location            = var.location
  cognitive_service_name = var.cognitive_service_name
}

module "app_service" {
  source              = "./modules/app-service"
  resource_group_name = var.resource_group_name
  location            = var.location
  app_service_name    = var.app_service_name
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = var.resource_group_name
  location            = var.location
  app_service_id      = module.app_service.app_service_id
}

