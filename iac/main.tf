# Configure the Terraform Google Provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Set the project and region for the provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Define the VPC network for our VM
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = true
}

# Define the Virtual Machine instance
resource "google_compute_instance" "vm_instance" {
  name         = "my-test-instance"
  machine_type = "e2-micro" # A small, cost-effective machine type
  zone         = "${var.region}-a" # Deploy to a specific zone within the region

  # Define the boot disk using a Debian image
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Connect the VM to our VPC and assign a public IP
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }

  # Add metadata to run a startup script
  metadata_startup_script = "sudo apt-get update && sudo apt-get install -y nginx"

  # Add a tag to allow HTTP traffic
  tags = ["http-server"]
}

# Define a firewall rule to allow HTTP traffic to our VM
resource "google_compute_firewall" "http_firewall" {
  name    = "allow-http-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"] # Allow traffic from any IP
  target_tags   = ["http-server"]
}