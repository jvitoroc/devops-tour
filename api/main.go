package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/hello", helloHandler)
	http.HandleFunc("/health", healthHandler)

	log.Print("listening")
	err := http.ListenAndServe("0.0.0.0:8080", nil)
	panic(err)
}

type Response struct {
	Message string `json:"message"`
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	w.Header().Set("content-type", "application/json")

	name := r.URL.Query().Get("name")
	response := Response{
		Message: hello(name),
	}

	jsonResponse, err := json.Marshal(response)
	if err != nil {
		w.WriteHeader(500)
		fmt.Fprint(w, err)
	}

	_, _ = w.Write(jsonResponse)
}

func hello(name string) string {
	if name == "" {
		return "Hello darkness, my old friend"
	}

	return "Hello " + name
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(200)
}
