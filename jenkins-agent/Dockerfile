FROM docker-registry.domain.department/rdbo/common/jdk17-runtime:latest

ARG NEXUS="https://nexus.domain.department/repository"
ARG REGISTRY_USER="${REGISTRY_USER}"
ARG REGISTRY_PASS="${REGISTRY_PASS}"
ARG OCVERSION="oc-v4.8.0-linux-64bit.tar"
ARG DUMBVERSION="dumb-init_1.2.5_x86_64"

ENV HOME=/home/jenkins

USER root

RUN INSTALL_PKGS="awscli git jq make which" && \
	microdnf install --setopt=tsflags=nodocs --setopt=install_weak_deps=0 $INSTALL_PKGS && \
    microdnf clean all && \
	mkdir -p /home/jenkins && \
	curl -s -u "${REGISTRY_USER}":"${REGISTRY_PASS}" -o ooct.tar "${NEXUS}/rdbo-raw/openshift/${OCVERSION}" && \
	tar -xvf ooct.tar && \
	rm ooct.tar && \
	mv oc /usr/local/bin/ && \
	curl -s -u "${REGISTRY_USER}":"${REGISTRY_PASS}" -o /usr/bin/dumb-init "${NEXUS}/rdbo-raw/binaries/${DUMBVERSION}" && \
	chown -R 1001:0 /home/jenkins && \
	chmod -R g+w /home/jenkins && \
	chmod 664 /etc/passwd && \
	chmod -R 775 /etc/alternatives && \
	chmod -R 775 /var/lib/alternatives && \
	chmod -R 775 /usr/lib/jvm && \
	chmod 775 /usr/bin && \
	chmod 775 /usr/bin/dumb-init && \
	chmod 775 /usr/share/man/man1 && \
	mkdir -p /var/lib/origin && \
	chmod 775 /var/lib/origin && \
	unlink /usr/bin/java && \
	unlink /usr/bin/keytool && \
	unlink /usr/bin/rmiregistry && \
	unlink /usr/share/man/man1/java.1.gz && \
	unlink /usr/share/man/man1/keytool.1.gz && \
	unlink /usr/share/man/man1/rmiregistry.1.gz

# Copy the entrypoint
ADD contrib/bin/ /usr/local/bin/

# Run the Jenkins JNLP client
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/run-jnlp-client"]
