FROM docker-registry.domain.department/rdbo/common/ubi-minimal-sg:latest

RUN microdnf install --setopt=tsflags=nodocs maven && \
    microdnf clean all

COPY ./settings.xml /usr/share/maven/conf/settings.xml

CMD ["bin/sh", "-c"]
