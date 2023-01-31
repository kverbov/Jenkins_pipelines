SHELL:=/bin/bash

.EXPORT_ALL_VARIABLES:
.ONESHELL:

docker_login:
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] login to docker registry $(CI_REGISTRY)"
	docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASS} ${CI_REGISTRY}

docker_image: docker_login
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] build docker image for $(SVC_NAME)"
	docker build --force-rm=true --pull=true --build-arg CI_REGISTRY_USER=${CI_REGISTRY_USER} --build-arg CI_REGISTRY_PASS=${CI_REGISTRY_PASS} \
		-t ${CI_REGISTRY_IMAGE}:${TAG} \
		-f Dockerfile .

docker_push: docker_image
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] push docker image for $(SVC_NAME)"
	docker push ${CI_REGISTRY_IMAGE}:${TAG}