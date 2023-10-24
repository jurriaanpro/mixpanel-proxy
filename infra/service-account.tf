resource "google_service_account" "mixpanel_proxy" {
  account_id   = "mixpanel-proxy"
  display_name = "mixpanel-proxy"
}

resource "google_project_iam_member" "cloud_run_invoker" {
  project = var.gcp_project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.mixpanel_proxy.email}"
}
