provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  credentials = file("/tmp/tmp.Yzg1wUwm6c/application_default_credentials.json")
}