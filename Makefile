SHELL := /usr/bin/env bash
ENV ?= dev
.PHONY: fmt validate lint security plan apply kubeconfig install-platform verify destroy
fmt:
	terraform fmt -recursive terraform
validate:
	./scripts/validate.sh
lint:
	tflint --init && tflint --recursive
security:
	trivy config . && checkov -d .
plan:
	./scripts/plan.sh $(ENV)
apply:
	./scripts/apply.sh $(ENV)
kubeconfig:
	./scripts/configure-kubectl.sh $(ENV)
install-platform:
	./scripts/install-platform.sh $(ENV)
verify:
	./scripts/verify-cluster.sh $(ENV)
destroy:
	./scripts/destroy.sh $(ENV)
