# How to get the local environment up and running

minikube start
cd infra/environments/local
terraform apply

add the following entries to the hosts file
127.0.0.1 devops-tour.com
127.0.0.1 api.devops-tour.com
 
minikube tunnel