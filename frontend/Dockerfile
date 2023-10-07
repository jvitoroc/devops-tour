FROM --platform=linux/amd64 golang:1.20.2-alpine AS base

WORKDIR /app

COPY /go.* ./

RUN go mod download

COPY *.go ./
COPY /templates ./templates
COPY /public ./public

RUN ["go", "run", "main.go"]

FROM --platform=linux/amd64 nginx:alpine

WORKDIR /app

COPY --from=base ./app/public ./static

COPY ./nginx.conf /etc/nginx/nginx.conf