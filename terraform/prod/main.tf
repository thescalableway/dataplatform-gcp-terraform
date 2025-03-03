resource "google_compute_network" "vpc_edp" {
  name                    = "vpc-${var.project_name}-${var.environment}"
  auto_create_subnetworks = "false"

}

resource "google_compute_subnetwork" "subnet_edp" {
  name          = "subnet-${var.project_name}-${var.environment}"
  ip_cidr_range = var.ip_cidr_range
  network       = google_compute_network.vpc_edp.name
  region        = var.region
  depends_on    = [google_compute_network.vpc_edp]
}

resource "google_compute_instance" "vm_edp" {
  project      = var.project_name
  zone         = var.zone
  name         = "${var.project_name}-${var.environment}-01"
  machine_type = var.machine_type
  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.image
      size  = 50
      type  = "pd-ssd"
    }
    mode = "READ_WRITE"
  }
  scratch_disk {
    interface = "NVME"
  }
  network_interface {
    network    = "vpc-${var.project_name}-${var.environment}"
    subnetwork = google_compute_subnetwork.subnet_edp.name
  }
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e
    sudo mkfs.ext4 -F /dev/disk/by-id/google-local-nvme-ssd-0
    sudo mkdir -p /mnt/disks/local-nvme-ssd
    sudo mount /dev/disk/by-id/google-local-nvme-ssd-0 /mnt/disks/local-nvme-ssd
    sudo chmod a+w /mnt/disks/local-nvme-ssd

    echo UUID=`sudo blkid -s UUID -o value /dev/disk/by-id/google-local-nvme-ssd-0` /mnt/disks/local-nvme-ssd ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
  EOT
  depends_on              = [google_compute_network.vpc_edp]
}

resource "google_compute_firewall" "rules" {
  project = var.project_name
  name    = "allow-ssh-${var.environment}"
  network = "vpc-${var.project_name}-${var.environment}"

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }
  source_ranges = ["35.235.240.0/20"]
  depends_on    = [google_compute_network.vpc_edp]
}

resource "google_project_iam_member" "project" {
  project = var.project_name
  role    = "roles/iap.tunnelResourceAccessor"
  member  = var.service_account
}

resource "google_compute_router" "router" {
  project    = var.project_name
  name       = "nat-router-${var.environment}"
  network    = "vpc-${var.project_name}-${var.environment}"
  region     = var.region
  depends_on = [google_compute_network.vpc_edp]
}

resource "google_compute_router_nat" "nat" {
  name                               = "router-nat-${var.project_name}-${var.environment}"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_storage_bucket" "private_bucket" {
  name          = "${var.project_name}-${var.environment}"
  location      = var.region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_binding" "bucket_reader" {
  bucket = google_storage_bucket.private_bucket.name

  role = "roles/storage.objectViewer"
  members = [
    "${var.service_account}"
  ]
}

resource "google_storage_bucket_iam_binding" "bucket_writer" {
  bucket = google_storage_bucket.private_bucket.name

  role = "roles/storage.objectCreator"
  members = [
    "${var.service_account}"
  ]
}

resource "google_storage_bucket_iam_binding" "bucket_admin" {
  bucket = google_storage_bucket.private_bucket.name

  role = "roles/storage.admin"
  members = [
    "${var.service_account}"
  ]
}
