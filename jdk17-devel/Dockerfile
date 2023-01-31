FROM docker-registry.domain.department/rdbo/common/ubi-minimal-sg:latest

RUN INSTALL_PKGS="java-17-openjdk-devel podman shadow-utils util-linux git vi" && \
	microdnf install --setopt=tsflags=nodocs --setopt=install_weak_deps=0 $INSTALL_PKGS && \
    microdnf clean all

ENV JAVA_HOME="/usr/lib/jvm/jre-17"

ENTRYPOINT ["/bin/bash", "-c"]
