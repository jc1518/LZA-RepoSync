SHELL := /bin/bash
help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

lint-ignore := W3005
lint:	## Validate Cloudformation templates
	cfn-lint --info --ignore-checks $(lint-ignore) -- ./cloudformation/*.yaml

scan:   ## Scan Cloudformation templates
	cfn_nag ./cloudformation/*.yaml --allow-suppression

$(eval include $(ENV))
$(eval export sed 's/=.*//' ${ENV})

deploy-pipeline: ## Deploy pipeline stack
	@echo "Deploying $(PipelineStackName) stack..."
	aws cloudformation deploy \
        --stack-name $(PipelineStackName) \
        --template-file $(PipelineStackFile) \
        --capabilities CAPABILITY_NAMED_IAM \
        --no-fail-on-empty-changeset \
        --parameter-overrides \
        ExternalRepositoryOwner=$(ExternalRepositoryOwner) \
        ExternalRepository=$(ExternalRepository) \
        ExternalBranch=$(ExternalBranch) \
        CodeConnection=$(CodeConnection) \
        CodecommitRepository=$(CodecommitRepository) \
        CodecommitBranch=$(CodecommitBranch) \
        ForceGitPush=$(ForceGitPush)

remove-pipeline: ## Remove pipeline stack
	@echo "Removing $(PipelineStackName) stack..."
	aws cloudformation delete-stack \
        --stack-name $(PipelineStackName)
