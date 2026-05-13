# Identity and Access Management (IAM)

resource "google_bigquery_dataset_iam_member" "crm_access_to_wheelie" {
      project = var.project_id
    dataset_id = "wheelie_raw"
    role = "roles/bigquery.dataViewer"
    member = "serviceAccount:crm-sa@bw-bigdata-2026-data-mesh.iam.gserviceaccount.com"
}

resource "google_bigquery_dataset_iam_member" "sales_access_to_wheelie" {
      project = var.project_id
    dataset_id = "wheelie_raw"
    role = "roles/bigquery.dataViewer"
    member = "serviceAccount:getter@data-mesh-pk.iam.gserviceaccount.com"
}

resource "google_bigquery_dataset_iam_member" "fleet_access_to_wheelie" {
      project = var.project_id
    dataset_id = "wheelie_raw"
    role = "roles/bigquery.dataViewer"
    member = "serviceAccount:fleet-domain@pr-bigdata-2026-data-mesh.iam.gserviceaccount.com"
}