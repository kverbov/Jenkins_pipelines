FROM docker-registry.domain.department/rdbo/common/ubi-minimal-sg:latest

#COPY blackbox_exporter  /bin/blackbox_exporter
COPY blackbox.yml       /etc/blackbox_exporter/config.yml
COPY blackbox_exporter  /bin/blackbox_exporter
RUN chmod 555 /bin/blackbox_exporter

EXPOSE      9115
ENTRYPOINT  [ "/bin/blackbox_exporter" ]
CMD [ "--config.file=/etc/blackbox_exporter/config.yml" ]
