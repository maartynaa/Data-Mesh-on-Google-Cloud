resource "google_storage_bucket_object" "dag" {
  name = "dags/load_data.py"

  bucket = replace(
    replace(
      google_composer_environment.airflow_environment.config[0].dag_gcs_prefix,
      "gs://",
      ""
    ),
    "/dags",
    ""
  )

  source = "../airflow/load_data.py"

  depends_on = [
    google_composer_environment.airflow_environment
  ]
}