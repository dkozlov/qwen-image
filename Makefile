SHELL          := /bin/bash
REGISTRY       := dfkozlov
NAME           := $$(basename -s .git `git config --get remote.origin.url`)
GIT_BRANCH     := $$(if [ -n "$$CI_COMMIT_REF_NAME" ]; then echo "$$CI_COMMIT_REF_NAME"; else git rev-parse --abbrev-ref HEAD; fi)
GIT_BRANCH     := $$(echo "${GIT_BRANCH}" | tr '[:upper:]' '[:lower:]')
GIT_SHA1       := $$(git rev-parse HEAD)
CONTAINER_NAME := ${NAME}-${GIT_BRANCH}
IMAGE_NAME     := ${REGISTRY}/${NAME}
TAG_GIT_SHA1   := ${IMAGE_NAME}:${GIT_BRANCH}-${GIT_SHA1}
TAG_LATEST     := ${IMAGE_NAME}:${GIT_BRANCH}-latest
DOCKER_CMD     := docker

.PHONY: info
info:
	@echo REGISTRY=${REGISTRY}
	@echo NAME=${NAME}
	@echo GIT_BRANCH=${GIT_BRANCH}
	@echo GIT_SHA1=${GIT_SHA1}
	@echo CONTAINER_NAME=${CONTAINER_NAME}
	@echo IMAGE_NAME=${IMAGE_NAME}
	@echo TAG_GIT_SHA1=${TAG_GIT_SHA1}
	@echo TAG_LATEST=${TAG_LATEST}
	@echo DOCKER_CMD=${DOCKER_CMD}

.PHONY: build
build:
	@${DOCKER_CMD} build --pull -t ${TAG_LATEST} -t ${TAG_GIT_SHA1} .

.PHONY: build-local
build-local:
	@${DOCKER_CMD} build --pull -t ${TAG_LATEST} .

.PHONY: run
run:
	@set -x ; \
	(${DOCKER_CMD} rm -f ${CONTAINER_NAME} || true) && \
	${DOCKER_CMD} run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -v /raid/tmp/hugginface:/root/.cache/huggingface --gpus device=0 --network=host --pull always --name ${CONTAINER_NAME} -v $$(pwd):/root --workdir /root ${TAG_LATEST} bash

.PHONY: run-local
run-local:
	${DOCKER_CMD} rm -f ${CONTAINER_NAME} || true
	${DOCKER_CMD} run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -v /raid/tmp/hugginface:/root/.cache/huggingface --gpus device=0 --network=host --pull never --name ${CONTAINER_NAME} -v $$(pwd):/root --workdir /root ${TAG_LATEST} bash

.PHONY: exec
exec:
	${DOCKER_CMD} exec -it ${CONTAINER_NAME} bash

.PHONY: exec-user
exec-user:
	${DOCKER_CMD} exec -it -u $$(id -u):$$(id -g) ${CONTAINER_NAME} bash


.PHONY: push
push:
	${DOCKER_CMD} push ${TAG_LATEST}
	${DOCKER_CMD} push ${TAG_GIT_SHA1}
ifeq ($(GIT_BRANCH), $(CI_DEFAULT_BRANCH))
	${DOCKER_CMD} tag ${TAG_LATEST} ${DEFAULT_LATEST}
	${DOCKER_CMD} push ${DEFAULT_LATEST}
endif
