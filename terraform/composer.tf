resource "google_project_service" "composer_api" {
  project = var.project_id
  service = "composer.googleapis.com"
}

resource "google_project_service" "compute_api" {
  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "container_api" {
  project = var.project_id
  service = "container.googleapis.com"
}

resource "google_project_service" "iam_api" {
  project = var.project_id
  service = "iam.googleapis.com"
}

# Service Account
resource "google_service_account" "composer_sa" {
  account_id   = "composer-sa"
  display_name = "Cloud Composer Service Account"
  project      = var.project_id
}

# Required IAM roles
resource "google_project_iam_member" "composer_worker" {
  project = var.project_id
  role    = "roles/composer.worker"
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

# Allows running BigQuery jobs (REQUIRED for load_table_from_uri)
resource "google_project_iam_member" "bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

# Allows writing data to tables
resource "google_project_iam_member" "bigquery_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

# Optional but recommended (metadata access, debugging, UI visibility)
resource "google_project_iam_member" "bigquery_metadata_viewer" {
  project = var.project_id
  role    = "roles/bigquery.metadataViewer"
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

# Composer Environment
resource "google_composer_environment" "airflow_environment" {
  name    = "wheelie-airflow"
  region  = var.region
  project = var.project_id

  depends_on = [
    google_project_service.composer_api,
    google_project_service.compute_api,
    google_project_service.container_api,
    google_project_service.iam_api,
    google_project_iam_member.composer_worker,
    google_project_iam_member.storage_admin
  ]

  config {

    software_config {
      image_version = "composer-3-airflow-3.1.7"
      env_variables = {
        GCP_PROJECT_ID = var.project_id
      }
    }

    node_config {
      service_account = google_service_account.composer_sa.email
    }

    workloads_config {
      scheduler {
        count      = 1
        cpu        = 1
        memory_gb  = 2
        storage_gb = 1
      }

      web_server {
        cpu        = 1
        memory_gb  = 2
        storage_gb = 1
      }

      worker {
        cpu        = 1
        memory_gb  = 2
        storage_gb = 1
        min_count  = 1
        max_count  = 2
      }
    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"
  }
}