# mixpanel-proxy

This repository contains the nginx config and Terraform deployment definitions to deploy an nginx container to Cloud Run that proxies requests to Mixpanel. It uses Terragrunt for easily deploying to multiple environments, e.g. test and prod.

See https://developer.mixpanel.com/docs/collection-via-a-proxy for reference.

Run `make help` to list available `make` targets and their function.
