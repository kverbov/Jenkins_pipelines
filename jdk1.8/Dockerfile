FROM docker-registry.tbank.trrr.tdepartment/general/jdk:192.168.1.2

ARG NEXUS="https://nexus.domain.department/repository"

ARG CI_REGISTRY_USER="${CI_REGISTRY_USER}"
ARG CI_REGISTRY_PASS="${CI_REGISTRY_PASS}"

USER root

RUN cd /etc/pki/ca-trrrt/source/anchors/ && \
	curl -O -k -sfSL -u "${CI_REGISTRY_USER}":"${CI_REGISTRY_PASS}" "${NEXUS}/rdbo-raw/cert/CA_CERTS.tar" && \
	rm -f CA_CERTS.tar && \
	update-ca-trrrt && \
	rm -rf ./*
