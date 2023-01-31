SHELL:=/bin/bash

.EXPORT_ALL_VARIABLES:
.ONESHELL:

CI_REGISTRY = docker-registry.domain.department
CI_REGISTRY_QUAY = quay.paas.bank.rrr.department:5000
CI_PROJECT_NAMESPACE = rdbo/common
SVC_NAME ?= kafka-connect
CI_REGISTRY_IMAGE = ${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${SVC_NAME}
IMAGE_IN_QUAY = ${CI_REGISTRY_QUAY}/rdbo/${SVC_NAME}

TEST_DOMAIN = tbank.trrr.tdepartment
PROD_DOMAIN = bank.rrr.department
OPENSHIFT_API_URL_TEST = https://api.tpaas.${TEST_DOMAIN}:6443
OPENSHIFT_API_URL_PROD = https://api.ocp.${PROD_DOMAIN}:6443

K8S_TEMPLATE_YAML = k8s.app.template.yaml

docker_login:
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] login to docker registry $(CI_REGISTRY)"
	docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASS} ${CI_REGISTRY}

docker_image: docker_login
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] build docker image for $(SVC_NAME)"
	docker build --force-rm=true --pull=true \
		--build-arg CI_REGISTRY_USER=${CI_REGISTRY_USER} --build-arg CI_REGISTRY_PASS=${CI_REGISTRY_PASS} \
		-t ${CI_REGISTRY_IMAGE}:${TAG} \
		-f Dockerfile .

docker_push: docker_image
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] push docker image for $(SVC_NAME)"
	docker push ${CI_REGISTRY_IMAGE}:${TAG}

prepare_deploy:
ifeq (${STAND}, $(filter ${STAND}, dev test))
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] login to ${STAND} Openshift"
	oc login ${OPENSHIFT_API_URL_TEST} -u=${OPENSHIFT_USERNAME}@${TEST_DOMAIN} -p=${OPENSHIFT_PASSWORD} -n=${PROJECT}-${STAND} --insecure-skip-tls-verify=true
	oc whoami
	@echo "Deploy ${CONNECTOR_TYPE}-${CONNECTOR_NAME} to ${STAND} stand, using image ${CI_REGISTRY_IMAGE}:${TAG} by ${K8S_TEMPLATE_YAML}"
	sed -i 's|%IMAGE%|${CI_REGISTRY_IMAGE}|g' ${K8S_TEMPLATE_YAML}
endif
ifeq (${STAND}, cert)
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] Mirror image from Nexus to Quay"
	oc image mirror ${CI_REGISTRY_IMAGE}:${TAG} ${IMAGE_IN_QUAY}:${TAG} --insecure=true --skip-mount=true
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] login to ${STAND} Openshift"
	oc login ${OPENSHIFT_API_URL_PROD} -u=${OPENSHIFT_USERNAME}@${PROD_DOMAIN} -p=${OPENSHIFT_PASSWORD} -n=${PROJECT}-${STAND} --insecure-skip-tls-verify=true
	oc whoami
	@echo "Deploy ${CONNECTOR_TYPE}-${CONNECTOR_NAME} to ${STAND} stand, using image ${CI_REGISTRY_IMAGE}:${TAG} by ${K8S_TEMPLATE_YAML}"
	sed -i 's|%IMAGE%|${IMAGE_IN_QUAY}|g' ${K8S_TEMPLATE_YAML}
endif
ifeq (${STAND}, prod)
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] login to ${STAND} Openshift"
	oc login ${OPENSHIFT_API_URL_PROD} -u=${OPENSHIFT_USERNAME}@${PROD_DOMAIN} -p=${OPENSHIFT_PASSWORD} -n=${PROJECT}-${STAND} --insecure-skip-tls-verify=true
	oc whoami
	@echo "Deploy ${CONNECTOR_TYPE}-${CONNECTOR_NAME} to ${STAND} stand, using image ${CI_REGISTRY_IMAGE}:${TAG} by ${K8S_TEMPLATE_YAML}"
	sed -i 's|%IMAGE%|${IMAGE_IN_QUAY}|g' ${K8S_TEMPLATE_YAML}
endif

deploy: prepare_deploy
	@echo "*** $(shell date +"%F %T (%Z)") [Makefile] do deploy"
	sed -i 's|%CONNECTOR_TYPE%|${CONNECTOR_TYPE}|g' ${K8S_TEMPLATE_YAML}
	sed -i 's|%CONNECTOR_NAME%|${CONNECTOR_NAME}|g' ${K8S_TEMPLATE_YAML}
	sed -i 's|%TAG%|${TAG}|g' ${K8S_TEMPLATE_YAML}
	oc process -f ${K8S_TEMPLATE_YAML} | oc apply -f -
