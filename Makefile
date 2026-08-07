PROJECT = concourse-helm3-resource
ID = apptweak/${PROJECT}
ECR_REPO = ghcr.io
TAG_VERSION := v$(shell cat VERSION)
# Set to stable if the current git-branch is main-apptweak, otherwise set to latest
CURRENT_BRANCH := $(shell git branch --show-current)
EXTRA_TAG := $(if $(filter main-apptweak,$(CURRENT_BRANCH)),stable,latest)

all: build push

build:
	docker build \
		--platform linux/x86_64 \
		--tag ${ECR_REPO}/${ID}:${TAG_VERSION} \
		--tag ${ECR_REPO}/${ID}:${EXTRA_TAG} \
		.

push:
	# read --local --silent --prompt "Docker account's password: " passwd
	# echo "$passwd" | docker login --username apptweakci --password-stdin
	read --local --silent --prompt "Docker account's password: " gh_pat
	echo "${gh_pat}"
	# echo "${gh_pat}" | docker login "${ECR_REPO}" --username apptweakci --password-stdin
	# docker push ${ECR_REPO}/${ID}:${TAG_VERSION}

run:
	docker run \
		--volume $(pwd):/opt/helm-3 \
		--workdir /opt/helm-3 \
		--interactive \
		--tty \
		${ID}:latest \
		bash
