terraform {
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"
      version = "4.80.0"
    }
  }
}

variable "projectId" {
  type        = string
  description = "Project id"
}

variable "backupBucketName" {
  type        = string
  description = "Name of the bucket where the backups are stored (must be globally unique)"
}

provider "google-beta" {
  project     = var.projectId
  region      = "europe-north1"
}

variable "gcp_service_list" {
  description ="The list of apis necessary for the project"
  type = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "sqladmin.googleapis.com",
    "run.googleapis.com",
    "compute.googleapis.com",
    "cloudscheduler.googleapis.com",
    "artifactregistry.googleapis.com",
    "logging.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}

resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project = var.projectId
  service = each.key
}

resource "google_artifact_registry_repository" "konttihalli" {
  location      = "europe-north1"
  repository_id = "konttihalli"
  description   = "konttihalli"
  format        = "DOCKER"
  depends_on = [google_project_service.gcp_services]
  project = var.projectId
}

#gcloud storage buckets create gs://tietokanta-backups \
#--enable-autoclass \
#--location europe-north1 \
#--public-access-prevention
resource "google_storage_bucket" "tietokanta-backups" {
  location = "europe-north1"
  name     = var.backupBucketName
  depends_on = [google_project_service.gcp_services]
  project = var.projectId
  
  public_access_prevention = "enforced"
  # ENABLE AUTOCLASS
  versioning {
    enabled = true
  }
  autoclass {
    enabled = true
  }
  
  
  lifecycle_rule {
    action {
      type = "Delete"
    }
    
    condition {
      num_newer_versions = 365
      with_state = "ARCHIVED"
    }
  }
  
  lifecycle_rule {
    action {
      type = "Delete"
    }
    
    condition {
      age = 365
    }
  }
}

resource "google_cloud_scheduler_job" "cloudsqlbackup" {
  name = "cloudsqlbackup-schedule"
  schedule = "0 0 * * *"
  depends_on = [google_project_service.gcp_services]
  project = var.projectId
  region = "europe-west3" ## europe-north1 does not support scheduler
  
  http_target {
    uri = "https://europe-north1-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.projectId}/jobs/cloudsqlbackup:run"
    
    oauth_token {
      service_account_email = google_service_account.sa.email
      scope = "https://www.googleapis.com/auth/cloud-platform"
    }
  }
}
