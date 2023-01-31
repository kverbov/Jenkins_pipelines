FROM docker-registry.domain.department/rdbo/common/ubi-minimal-sg:latest

ARG NEXUS="https://nexus.domain.department/repository"
ARG REGISTRY_USER="${REGISTRY_USER}"
ARG REGISTRY_PASS="${REGISTRY_PASS}"

RUN INSTALL_PKGS="java-17-openjdk-headless" && \
	microdnf install --setopt=tsflags=nodocs --setopt=install_weak_deps=0 $INSTALL_PKGS && \
    microdnf clean all  && \
	curl -k -s -u "${REGISTRY_USER}":"${REGISTRY_PASS}" -o /usr/bin/dumb-init "${NEXUS}/rdbo-raw/binaries/dumb-init_1.2.5_x86_64" && \
	chmod 775 /usr/bin/dumb-init

ENV JAVA_HOME="/usr/lib/jvm/jre-17"
