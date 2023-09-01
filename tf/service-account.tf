
resource "google_service_account" "sa" {
  account_id   = "scheduler-service-account"
  display_name = "Service account for Cloud Run, Scheduler, and Storage"
  description  = "This service account has access to run tasks, manage scheduling, and manage storage in the project"
  project = var.projectId
}

resource "google_project_iam_member" "run_invoker" {
  project = var.projectId
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "scheduler_admin" {
  project = var.projectId
  role    = "roles/cloudscheduler.admin"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.projectId
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.sa.email}"
}





resource "google_service_account" "cloud-run-sa" {
  account_id   = "sqlbackup-crun-job-sa"
  display_name = "Service account for Cloud Run"
  description  = "This service account has access to manage sql and cloud stoarage in the project"
  project = var.projectId
}

resource "google_project_iam_member" "serviceAccountUser" {
  project = var.projectId
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloud-run-sa.email}"
}

resource "google_project_iam_member" "run_builder" {
  project = var.projectId
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.cloud-run-sa.email}"
}

resource "google_project_iam_member" "sql_admin" {
  project = var.projectId
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${google_service_account.cloud-run-sa.email}"
}

resource "google_project_iam_member" "storage_admin2" {
  project = var.projectId
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cloud-run-sa.email}"
}
