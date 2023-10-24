resource "google_cloud_run_service" "mixpanel_proxy" {
  name     = var.service_name
  location = var.gcp_region

  autogenerate_revision_name = true

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "50"
      }
    }
    spec {
      # https://cloud.google.com/run/docs/securing/service-identity
      service_account_name = google_service_account.mixpanel_proxy.email

      containers {
        image = var.container_image
        ports {
          name           = "http1"
          container_port = 80
        }        
      }
    }
  }
}

data "google_iam_policy" "noauth_mixpanel_proxy" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth_mixpanel_proxy" {
  location = google_cloud_run_service.mixpanel_proxy.location
  project  = google_cloud_run_service.mixpanel_proxy.project
  service  = google_cloud_run_service.mixpanel_proxy.name

  policy_data = data.google_iam_policy.noauth_mixpanel_proxy.policy_data
}
