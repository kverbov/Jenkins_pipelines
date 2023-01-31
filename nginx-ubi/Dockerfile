FROM docker-registry.domain.department/rdbo/common/ubi-minimal-sg:latest

RUN microdnf install --setopt=tsflags=nodocs nginx && \
    microdnf clean all && \
    mkdir -p /usr/share/nginx/app/ && \
    # fix me. added for kaniko. images build in openshift and there is not enough permission
    chmod -R 777 /usr/share/nginx/

RUN chgrp -R root /run /var/run && \
    chmod -R 770 /run /var/run

COPY ./nginx.conf /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 8080
