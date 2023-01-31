FROM docker-registry.domain.department/rdbo/common/ubi-minimal-sg:latest

RUN microdnf install --setopt=tsflags=nodocs nginx && \
    microdnf clean all

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./api.telegram.org* /etc/nginx/ssl/

RUN chgrp -R root /run /var/run && \
    chmod -R 770 /run /var/run

CMD ["nginx", "-g", "daemon off;"]
EXPOSE 8443
