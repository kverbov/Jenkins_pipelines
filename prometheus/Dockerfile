FROM docker-registry.domain.department/rdbo/common/alpine:latest

ARG PROM_FILE_NAME="prometheus-2.22.0.linux-amd64"

RUN mkdir -p /opt/prometheus/ /data/ && \
    chown -R nobody:nogroup /opt/prometheus/ /data/ && \
    chmod 777 /data/ && \
    curl -sk --remote-name-all "https://nexus.domain.department/repository/rdbo-raw/binaries/for-monitoring/${PROM_FILE_NAME}.tar.gz" && \
    tar -xf "${PROM_FILE_NAME}.tar.gz" && \
    mv ./"${PROM_FILE_NAME}"/prometheus ./"${PROM_FILE_NAME}"/promtool /usr/local/bin/ && \
    mv ./"${PROM_FILE_NAME}"/consoles/ ./"${PROM_FILE_NAME}"/console_libraries/ /opt/prometheus/ && \
    rm -rf ./"${PROM_FILE_NAME}"* && \
    cd /opt/prometheus/

COPY [--chown=nobody:nogroup] ./prometheus.yml /opt/prometheus/prometheus.yml

USER       nobody
EXPOSE     9090
VOLUME     ["/data/"]
WORKDIR    /data/
ENTRYPOINT ["/usr/local/bin/prometheus"]
CMD        ["--config.file=/opt/prometheus/prometheus.yml", \
            "--storage.tsdb.path=/data/", \
            "--storage.tsdb.retention.time=3h", \
            "--web.console.templates=/opt/prometheus/consoles", \
            "--web.console.libraries=/opt/prometheus/console_libraries", \
            "--web.listen-address=:9090"]
