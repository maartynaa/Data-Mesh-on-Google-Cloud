variable "project_id" {
  description = "ID projektu w GCP"
  type        = string
}

variable "region" {
  description = "Region dla zasobów"
  type        = string
  default     = "europe-central2" # Warszawa
}

variable "zone" {
  description = "Strefa dla VM"
  type        = string
  default     = "europe-central2-a"
}

variable "instance_type" {
  description = "Typ maszyny wirtualnej"
  type        = string
  default     = "e2-standard-2" # e2-small (2GB RAM) okazał się niewystarczający
}

variable "storage_class" {
  description = "Storage Class"
  type        = string
  default     = "STANDARD"
}

variable "wheelie_csv_files" {
  type    = list(string)
  default = [
    "address.csv",
    "car.csv",
    "city.csv",
    "country.csv",
    "customer.csv",
    "equipment.csv",
    "inventory_equipment.csv",
    "inventory.csv",
    "payment.csv",
    "rental.csv",
    "service.csv",
    "staff.csv",
    "store.csv",
  ]
}

variable "sales_resources" {
  type    = list(string)
  default = [
    "payment.csv",
    "rental.csv"
  ]
}
