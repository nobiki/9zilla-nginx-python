Dockerfile: Dockerfile.in ./include/*.docker
	cpp -P -o Dockerfile Dockerfile.in

update:
	git submodule update --init --recursive
	git submodule foreach git pull origin master

build: Dockerfile
	docker build --no-cache -t 9zilla-nginx-python:latest .
