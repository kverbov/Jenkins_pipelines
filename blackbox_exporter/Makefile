SHELL:=/bin/bash

.EXPORT_ALL_VARIABLES:
.ONESHELL:

TAG ?= latest
CI_PROJECT_NAMESPACE ?= rdbo/tools
CI_REGISTRY_IMAGE ?= ${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${DOCKER_IMAGE_NAME}

docker_login:
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] login to docker registry $(CI_REGISTRY)"
	@if [ "$${CI_REGISTRY}" = "local" ]; then
		echo 'Environment variable CI_REGISTRY is not defined, skip login';
	else
		docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASS} ${CI_REGISTRY};
	fi

docker_image: docker_login
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] build docker image for $(DOCKER_IMAGE_NAME)"
	docker build --rm \
		-t ${CI_REGISTRY_IMAGE}:${TAG} \
		-f Dockerfile .

docker_push: docker_image
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] push docker image for $(DOCKER_IMAGE_NAME)"
	docker push ${CI_REGISTRY_IMAGE}:${TAG}
