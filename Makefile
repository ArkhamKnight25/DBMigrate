.PHONY: build test

build:
	go build -buildvcs=false -o dist/dbmigrate .

test:
	go test -buildvcs=false ./...
