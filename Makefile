Dockerfile: Dockerfile.in ./include/*.docker
	git submodule update --init --recursive
	git submodule foreach git pull origin master
	cpp -P -o Dockerfile Dockerfile.in

build: Dockerfile
	docker build --no-cache -t 9zilla-nginx-python:latest .
