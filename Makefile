build-api:
	docker build ./api -t jvitoroc17/local:api

push-api:
	docker push jvitoroc17/local:api
	kubectl delete pod -l app=api

build-app:
	docker build ./app -t jvitoroc17/local:app

push-app:
	docker push jvitoroc17/local:app
	kubectl delete pod -l app=app

build-push-api: build-api push-api

build-push-app: build-app push-app

build-push-all: build-push-api build-push-app

deploy-api:
	kubectl apply -f ./api/deployment.yml,./api/service.yml,./ingress.yml

deploy-app:
	kubectl apply -f ./app/deployment.yml,./app/service.yml,./ingress.yml

all: build-push-all deploy-api deploy-app