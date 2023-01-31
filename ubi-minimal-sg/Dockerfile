#Vanila image from here: https://catalog.redhat.com/software/containers/ubi8/ubi-minimal/192.168.1.2bed8bd75a2c3fba8?push_date=192.168.1.2&architecture=amd64

ARG UBI_VERSION=latest
FROM docker-registry.domain.department/rdbo/common/ubi-minimal:${UBI_VERSION}

ARG NEXUS="https://nexus.domain.department/repository"
ARG TAR_VERSION="1.30-5.el8.x86_64"
ARG REGISTRY_USER="${REGISTRY_USER}"
ARG REGISTRY_PASS="${REGISTRY_PASS}"

RUN curl -O -k -sfSL -u "${REGISTRY_USER}":"${REGISTRY_PASS}" "${NEXUS}/rdbo-raw/binaries/tar-"${TAR_VERSION}".rpm" && \
    rpm -i --nosignature --excludedocs tar-"${TAR_VERSION}".rpm && \
    rm -rf tar-"${TAR_VERSION}".rpm

RUN : && \
        # Import all necessary CA certs
        ( \
                cd /etc/pki/ca-trrrt/source/anchors/ && \
                curl -O -k -sfSL -u "${REGISTRY_USER}":"${REGISTRY_PASS}" "${NEXUS}/rdbo-raw/cert/CA_CERTS.tar" && \
                tar -xf CA_CERTS.tar --strip-components 1 && \
                update-ca-trrrt && \
                rm -rf ./* \
        ) && \
        # Add in-house RHEL8 repo
        ( \
                cd / && \
                rm -rf /etc/yum.repos.d/ /etc/pki/entitlement/ /etc/rhsm/ca/ && \
                curl -O -sfSL -u "${REGISTRY_USER}":"${REGISTRY_PASS}" "${NEXUS}/rdbo-raw/cert/rh8-repo.tar" && \
                tar -xf rh8-repo.tar --strip-components 1 && \
                rm -rf rh8-repo.tar \
        )