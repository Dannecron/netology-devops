#!make
include .env

tf-init:
	cd ./terraform \
		&& env $(cat ../.env) terraform init \
			-backend-config="access_key=${YC_STORAGE_ACCESS_KEY}" \
			-backend-config="secret_key=${YC_STORAGE_SECRET_KEY}"

tf-plan:
	cd ./terraform \
	&& env $(cat ../.env) terraform plan

tf-ws-prod:
	cd ./terraform \
		&& terraform workspace select prod
tf-ws-stage:
	cd ./terraform \
		&& terraform workspace select stage
tf-ws-current:
	cd ./terraform \
		&& terraform workspace list
