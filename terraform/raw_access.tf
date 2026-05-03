resource "google_bigquery_dataset_iam_member" "crm_access_to_wheelie" {
      project = var.project_id
    dataset_id = "wheelie_raw"
    role = "roles/bigquery.dataViewer"
    member = "serviceAccount:crm-sa@bw-bigdata-2026-data-mesh.iam.gserviceaccount.com"
}