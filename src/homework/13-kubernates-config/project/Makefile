IMAGE_NAME=dannecron/netology-devops-k8s-app

build-backend:
	cd ./backend && docker build -t ${IMAGE_NAME}:backend-latest . \
		&& docker push ${IMAGE_NAME}:backend-latest

build-frontend:
	cd ./frontend && docker build -t ${IMAGE_NAME}:frontend-latest . \
		&& docker push ${IMAGE_NAME}:frontend-latest
