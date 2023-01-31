FROM docker-registry.domain.department/rdbo/common/adoptopenjdk/openjdk11:centos-slim

ARG NEXUS="https://nexus.domain.department/repository"
ARG CI_REGISTRY_USER="${CI_REGISTRY_USER}"
ARG CI_REGISTRY_PASS="${CI_REGISTRY_PASS}"

USER root

RUN cd /etc/pki/ca-trrrt/source/anchors/ && \
	curl -O -k -sfSL -u "${CI_REGISTRY_USER}":"${CI_REGISTRY_PASS}" "${NEXUS}/rdbo-raw/cert/CA_CERTS.tar" && \
	tar -xf CA_CERTS.tar && \
	update-ca-trrrt && \
	update-ca-trrrt extract && \
	curl -k -s -u "${CI_REGISTRY_USER}":"${CI_REGISTRY_PASS}" -o /opt/java/openjdk/lib/security/cacerts https://nexus.domain.department/repository/raw-distribs/cacerts && \
	curl -sO -u "${CI_REGISTRY_USER}":"${CI_REGISTRY_PASS}"  https://nexus.domain.department/repository/rdbo-raw/binaries/docker-ce-cli-192.168.1.2.el8.x86_64.rpm && \
	rpm -ivh docker-ce-cli-192.168.1.2.el8.x86_64.rpm && \
	rm -f docker-ce-cli-192.168.1.2.el8.x86_64.rpm && \
	groupdel docker

COPY entrypoint.sh /usr/local/bin/

RUN useradd --uid 1001 java && \
	chmod a+x /usr/local/bin/entrypoint.sh

WORKDIR /home/java/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
