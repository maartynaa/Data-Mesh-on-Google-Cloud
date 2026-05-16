resource "google_storage_bucket" "crm_bucket" {
  name     = "${var.project_id}-crm-data"
  location = var.region

  storage_class = var.storage_class

  uniform_bucket_level_access = true

  labels = {
    domain = "crm"
    layer  = "curated"
  }
}


resource "google_storage_transfer_job" "wheelie_to_crm" {
  description = "Cykliczna kopia danych Wheelie → CRM"
  project     = var.project_id

  transfer_spec {
    gcs_data_source {
      bucket_name = "mm-bigdata-2026-data-mesh-wheelie"
    }

    gcs_data_sink {
      bucket_name = google_storage_bucket.crm_bucket.name
    }

    transfer_options {
      overwrite_when = "DIFFERENT"
    }
  }

  schedule {
    schedule_start_date {
      year  = 2026
      month = 5
      day   = 15
    }

    repeat_interval = "604800s"  # 86400s daily; teraz raz w tygodniu
  }
}