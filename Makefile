WORKING_DIR := $(shell pwd)
PLAN ?= plan.cache
PLAN_JSON ?= plan.json

ifndef VERSION
	VERSION := $(shell git describe --tags --always)
endif

ifndef GOOGLE_PROJECT_NAME
	GOOGLE_PROJECT_NAME = example
endif

IMAGE = eu.gcr.io/$(GOOGLE_PROJECT_NAME)/mixpanel-proxy

.PHONY: build-container
build-container: ## Build container
ifeq ($(shell uname -m), arm64)
	docker build --platform linux/x86_64 . -t $(IMAGE):$(VERSION) -t $(IMAGE):latest
else
ifdef CI
	docker pull $(IMAGE):latest || true
endif
	docker build . -t $(IMAGE):$(VERSION) -t $(IMAGE):latest --cache-from $(IMAGE):latest
endif

.PHONY: push-container
push-container: ## Push container to remote repository
	docker push $(IMAGE):$(VERSION)
ifeq ($(CI_COMMIT_BRANCH), main)
# Only push :latest tag when on 'main'
	docker push $(IMAGE):latest
endif

.PHONY: plan
plan: ## Generates Terraform plan and writes it to plan.cache
ifndef ENVIRONMENT
	@echo ENVIRONMENT not defined, exiting; exit 1;
endif
	cd infra/environments/$(ENVIRONMENT) && \
	IMAGE=$(IMAGE):$(VERSION) \
	IMAGE_STORYBOOK=$(IMAGE_STORYBOOK):$(VERSION) \
	terragrunt plan -out=$(WORKING_DIR)/$(PLAN)
ifdef CI
	cd infra/environments/$(ENVIRONMENT) && \
	IMAGE=$(IMAGE):$(VERSION) \
	IMAGE_STORYBOOK=$(IMAGE_STORYBOOK):$(VERSION) \
	terragrunt show --json $(WORKING_DIR)/$(PLAN) | convert_tf_report > $(WORKING_DIR)/$(PLAN_JSON)
endif

.PHONY: apply
apply: ## Applies latest Terragrunt based on available plan.cache file
ifndef ENVIRONMENT
	@echo ENVIRONMENT not defined, exiting; exit 1;
endif
	cd infra/environments/$(ENVIRONMENT) && \
	IMAGE=$(IMAGE):$(VERSION) \
	IMAGE_STORYBOOK=$(IMAGE_STORYBOOK):$(VERSION) \
	terragrunt apply -auto-approve

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
