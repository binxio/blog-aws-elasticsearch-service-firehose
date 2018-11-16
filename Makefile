.PHONY: help init clean validate mock create delete info deploy
.DEFAULT_GOAL := help
environment = "example"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

create: ## create env
	@sceptre launch-env $(environment)

delete: ## delete env
	@sceptre delete-env $(environment)

info: ## describe resources
	@sceptre describe-stack-outputs $(environment) elasticsearch

merge-lambda: ## merge lambda in api gateway
#	aws-cfn-update \
#		lambda-inline-code \
#		--resource ProcessorFunction \
#		--file lambdas/identity_processor.py \
#		templates/elasticsearch.yaml
	aws-cfn-update \
		lambda-inline-code \
		--resource ProcessorFunction \
		--file lambdas/map_message_processor.py \
		templates/elasticsearch.yaml

publish: ## publish messages to the firehose delivery stream
	@pipenv run python publish.py `sceptre describe-stack-outputs example elasticsearch | cfn-flip --json | jq -r '.[] | select(.OutputKey=="KinesisStreamName") | .OutputValue'` 500