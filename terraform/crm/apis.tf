resource "google_project_service" "cloudresourcemanager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "storagetransfer" {
  project = var.project_id
  service = "storagetransfer.googleapis.com"

  depends_on = [google_project_service.cloudresourcemanager]
}