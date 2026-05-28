resource "google_compute_instance" "airflow_vm" {
  name         = "airflow-dbt-vm"
  machine_type = "e2-standard-2"
  zone         = "europe-central2-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}