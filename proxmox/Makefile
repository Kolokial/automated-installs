.DEFAULT_GOAL := help
TOFU_DIR := tofu
ANSIBLE_DIR := ansible

.PHONY: help discover fmt init validate plan lint check

help: ## Show targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "%-10s %s\n", $$1, $$2}'

discover: ## Read-only API dump into discovery/
	bash scripts/gather-api.sh

fmt: ## Format OpenTofu files
	tofu -chdir=$(TOFU_DIR) fmt -recursive

init: ## Download providers
	tofu -chdir=$(TOFU_DIR) init

validate: ## Validate OpenTofu config
	tofu -chdir=$(TOFU_DIR) validate

plan: ## Read-only plan
	tofu -chdir=$(TOFU_DIR) plan

lint: ## Lint Ansible
	cd $(ANSIBLE_DIR) && ansible-lint

check: ## Read-only playbook dry run
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/site.yml --check --diff
