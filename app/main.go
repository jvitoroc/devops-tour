package main

import (
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"text/template"
)

const (
	templatesPath   = "templates"
	defaultTemplate = "index.html.tmpl"

	argPrefix = "DEVOPS_"
)

var args map[string]string

func main() {
	args = make(map[string]string)
	for _, arg := range os.Environ() {
		r := strings.SplitN(arg, "=", 2)
		key := r[0]
		value := ""
		if len(r) > 1 {
			value = r[1]
		}

		if strings.HasPrefix(key, argPrefix) {
			args[key] = value
		}
	}

	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/", serveTemplates)

	log.Print("listening")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}
}

func serveTemplates(w http.ResponseWriter, r *http.Request) {
	file := filepath.Clean(r.URL.Path)
	file = strings.Trim(file, "/")
	if file == "" {
		file = defaultTemplate
	}

	fp := filepath.Join(templatesPath, file)

	tmpl, err := template.ParseFiles(fp)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			w.WriteHeader(404)
			return
		}

		w.WriteHeader(500)
		return
	}

	err = tmpl.ExecuteTemplate(w, file, args)
	if err != nil {
		fmt.Fprint(w, err.Error())
		w.WriteHeader(500)
	}
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(200)
}
