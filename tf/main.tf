terraform {
  required_version = ">= 0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "< 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "< 5.0"
    }
  }
}

provider "google" {
  credentials = var.service_account_file 
  project     = var.project_id
}

provider "google-beta" {
  credentials = var.service_account_file 
  project     = var.project_id
}

# set up vpc with this - will have to build from scratch for this
# https://cloud.google.com/run/docs/triggering/trigger-with-events trigger cloud run 
# https://cloud.google.com/run/docs/configuring/connecting-vpc#yaml_1
/*
resource "google_project_service" "vpcaccess_api" {
  service            = "vpcaccess.googleapis.com"
  provider           = google-beta
  disable_on_destroy = false
}

# VPC
resource "google_compute_network" "default" {
  name                    = "cloudrun-network"
  provider                = google-beta
  auto_create_subnetworks = false
}

# VPC access connector
resource "google_vpc_access_connector" "connector" {
  name           = "vpcconn"
  provider       = google-beta
  region         = var.location
  ip_cidr_range  = "10.8.0.0/28"
  max_throughput = 300
  network        = google_compute_network.default.name
  depends_on     = [google_project_service.vpcaccess_api]
}

# Cloud Router
resource "google_compute_router" "router" {
  name     = "router"
  provider = google-beta
  region   = var.location
  network  = google_compute_network.default.id
}

# NAT configuration
resource "google_compute_router_nat" "router_nat" {
  name                               = "nat"
  provider                           = google-beta
  region                             = var.location
  router                             = google_compute_router.router.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
}
*/
resource "google_cloud_run_service" "gcr_service" {
  name     = "mygcrservice"
  #count    = var.cloud_run ? 1 : 0
  location = var.location

  template {
    spec {
      containers {
        image = format("gcr.io/%s/test-app:%s", var.project_id, var.app_version)
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512M"
          }
        }
      }
      # the service uses this SA to call other Google Cloud APIs
      # service_account_name = myservice_runtime_sa
    }

    metadata {
      annotations = {
        # Limit scale up to prevent any cost blow outs!
        "autoscaling.knative.dev/maxScale" = var.auto_scale
        # Use the VPC Connector
       # "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.name
        # all egress from the service should go through the VPC Connector
        #"run.googleapis.com/vpc-access-egress" = "all-traffic"
      }
    }
  }
  autogenerate_revision_name = true

}