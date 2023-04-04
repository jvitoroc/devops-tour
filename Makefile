build-backend:
	docker build ./backend -t jvitoroc17/local:backend

push-backend:
	docker push jvitoroc17/local:backend

build-frontend:
	docker build ./frontend -t jvitoroc17/local:frontend

push-frontend:
	docker push jvitoroc17/local:frontend

build-push-backend: build-backend push-backend

build-push-frontend: build-frontend push-frontend

build-push-all: build-push-backend build-push-frontend

deploy-backend:
	kubectl apply -f ./backend/deployment.yml,./backend/service.yml,./backend/ingress.yml

deploy-frontend:
	kubectl apply -f ./frontend/deployment.yml,./frontend/service.yml