FROM docker-registry.domain.department/rdbo/common/ubi-minimal-sg:latest

ARG NEXUS="https://nexus.domain.department/repository"

RUN INSTALL_PKGS="ansible" && \
    microdnf install --setopt=tsflags=nodocs "${INSTALL_PKGS}" && \
	microdnf install --setopt=tsflags=nodocs git && \
	microdnf install --setopt=tsflags=nodocs vi && \
    microdnf clean all

RUN curl -O -k -sfSL "${NEXUS}/rdbo-raw/binaries/ansible/community-aws-3.2.1.tar.gz" && \
	ansible-galaxy collection install community-aws-3.2.1.tar.gz && \
	rm -rf community-aws-3.2.1.tar.gz
	
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "trap : TERM INT; (while true; do sleep 1000; done) & wait"]
