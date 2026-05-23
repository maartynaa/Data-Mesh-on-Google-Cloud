variable "dataplex_required_apis" {
  type        = list(string)
  description = "Lista API niezbędnych do uruchomienia Dataplex i Data Catalog"
  default = [
    "dataplex.googleapis.com",    # Główne API Dataplex (zawiera nowoczesny Data Catalog)
    "datacatalog.googleapis.com"  # API dla szablonów tagów i metadanych biznesowych
  ]
}

resource "google_project_service" "dataplex_services" {
  for_each           = toset(var.dataplex_required_apis)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_dataplex_lake" "wheelie_lake" {
  name         = "wheelie-data-mesh-lake"
  project      = var.project_id
  location     = var.region
  description  = "Centralne Jezioro Zarządzania Data Mesh dla Wheelie Car Rental"
  display_name = "Wheelie Data Mesh Governance Center"

  # Zapewnia, że jezioro stworzy się dopiero PO aktywacji API
  depends_on = [google_project_service.dataplex_services]
}


resource "google_dataplex_zone" "curated_zone" {
  name         = "curated-data-zone"
  lake         = google_dataplex_lake.wheelie_lake.name
  project      = var.project_id
  location     = var.region
  type         = "CURATED"
  description  = "Zone containing official domain data products"
  display_name = "Domain Shared Egress Zone"

  # FIX: The provider expects resource_spec to exist at the zone tier
  # to determine the primary location type of the assets (BIGQUERY_DATASET vs STORAGE_BUCKET)
  resource_spec {
    location_type = "SINGLE_REGION"
  }

  # Turning on discovery safely alongside the resource spec
  discovery_spec {
    enabled = true
  }

  depends_on = [google_dataplex_lake.wheelie_lake]
}