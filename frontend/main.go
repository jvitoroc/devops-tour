package main

import (
	"os"
	"path"
	"strings"
	"text/template"
)

const (
	templatesPath = "./templates"
	publicPath    = "./public"
	argPrefix     = "DEVOPS_"
)

func main() {
	args := make(map[string]string)
	for _, arg := range os.Environ() {
		r := strings.SplitN(arg, "=", 2)
		if strings.HasPrefix(r[0], argPrefix) {
			args[r[0]] = r[1]
		}
	}

	files, err := os.ReadDir(templatesPath)
	if err != nil {
		panic(err)
	}

	for _, f := range files {
		if f.IsDir() {
			continue
		}

		templateName := f.Name()

		finalFileName, _ := strings.CutSuffix(templateName, ".tmpl")
		finalFilePath := path.Join(publicPath, finalFileName)
		finalFile, err := os.OpenFile(finalFilePath, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, os.ModeAppend)
		if err != nil {
			panic(err)
		}
		defer finalFile.Close()

		templatePath := path.Join(templatesPath, templateName)
		tpl, err := template.New(templatePath).ParseFiles(templatePath)
		if err != nil {
			panic(err)
		}

		err = tpl.ExecuteTemplate(finalFile, templateName, args)
		if err != nil {
			panic(err)
		}
	}
}
