#!make
tf-init:
	cd ./terraform \
		&& env $(cat ../.env) terraform init
tf-init-upgrade:
	cd ./terraform \
		&& env $(cat ../.env) terraform init -upgrade
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
