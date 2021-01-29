PREFIX = nicolasvion
IMAGE = www
TAG = v0.1
URL="https://github.com/nicolasvion/website.git"

build:
	docker build --no-cache -t $(PREFIX)/$(IMAGE):$(TAG) .

run:
	docker run --rm -it -p 8080:80  -e WWW_URL=$(URL) $(PREFIX)/$(IMAGE):$(TAG)

push:
	docker push $(PREFIX)/$(IMAGE):$(TAG)
