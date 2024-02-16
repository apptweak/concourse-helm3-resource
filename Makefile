PROJECT = helm3-resource
ID = apptweakci/${PROJECT}
TAG_VERSION := v$(shell cat VERSION)

all: build push

build:
	docker build --platform linux/x86_64 --tag ${ID}:${TAG_VERSION} .

push:
	# read --local --silent --prompt "Docker account's password: " passwd
	# echo "$passwd" | docker login --username apptweakci --password-stdin
	docker push ${ID}:${TAG_VERSION}

run:
	docker run \
		--volume $(pwd):/opt/helm-3 \
		--workdir /opt/helm-3 \
		--interactive \
		--tty \
		${ID}:latest \
		bash
