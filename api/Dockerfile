FROM --platform=linux/amd64 golang:1.20.2-alpine

WORKDIR /app

COPY /go.* ./

RUN go mod download

COPY *.go ./

RUN go build -o /server

EXPOSE 8080

CMD [ "/server" ]