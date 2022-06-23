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
