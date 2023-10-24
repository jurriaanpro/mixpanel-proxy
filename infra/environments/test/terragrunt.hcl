include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../"
}

remote_state {
  backend = "http"

  config = {
    # Adjust to match your terraform remote state backend
    # address = ""
    # lock_address = ""
    # unlock_address = ""
    # lock_method = "POST"
    # unlock_method = "DELETE"
    retry_wait_min = 5
    username = get_env("TF_HTTP_USERNAME")
    password = get_env("TF_HTTP_PASSWORD")
  }
}

inputs = {
  environment = "test"
  gcp_project_id = "example-test"
  gcp_region = "europe-west4"

  service_name = "mixpanel-proxy"
}
