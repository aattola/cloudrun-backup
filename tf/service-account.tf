
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
