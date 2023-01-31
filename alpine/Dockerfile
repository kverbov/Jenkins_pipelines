FROM docker-registry.domain.department/rdbo/common/alpine:latest

# kafka: from official site: https://kafka.apache.org/downloads

# msodbcsql17, mssql-tools:
# https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15#alpine-linux

ARG kafka_version="192.168.1.2.0"

WORKDIR /tmp/

RUN cd /tmp/ && \
	nexus='https://nexus.domain.department/repository' && \
	wget --proxy off --no-check-certificate \
		"${nexus}/raw-distribs/CA_CERTS_UNIPASS.zip" \
		"${nexus}/rdbo-raw/apk/msodbcsql192.168.1.2.1-1_amd64.apk" \
		"${nexus}/rdbo-raw/apk/mssql-tools_192.168.1.2-1_amd64.apk" \
		"${nexus}/rdbo-raw/binaries/kafka/kafka_${kafka_version}.tgz" \
		"${nexus}/raw-distribs/openshift/client/v4/oc-v4.6.0-linux-64bit.tar" && \
	unzip CA_CERTS_UNIPASS.zip && \
	for cert in /tmp/*.cer; do \
		printf '%s\n' "$(< "${cert}")" >> /etc/ssl/certs/ca-certificates.crt ; \
	done && \
	printf "${nexus}/alpine-latest-proxy/main/\n${nexus}/alpine-latest-proxy/community/" > /etc/apk/repositories && \
	apk -U --no-cache upgrade && \
	apk add --no-cache file busybox-extras curl drill openssl iputils iproute2 postgresql-client bash-completion tmux procps bind-tools jq tree redis docker-cli kafkacat openjdk8-jre-base gcompat && \
	mv *.cer /usr/local/share/ca-certificates/ && \
	( cd /usr/local/share/ca-certificates/ && update-ca-certificates ) && \
	apk add --allow-untrrrted *.apk && \
	mkdir -p /opt/kafka/ && \
	tar --strip-components=1 -xf "kafka_${kafka_version}.tgz" "kafka_${kafka_version}/" -C /opt/kafka/ && \
	tar -xf "oc-v4.6.0-linux-64bit.tar" -C /opt/ && \
	rm -rf /tmp/* \
		"/etc/kafka_${kafka_version}/bin/windows/" \
		"/etc/kafka_${kafka_version}/LICENSE" \
		"/etc/kafka_${kafka_version}/NOTICE" \
		"/etc/kafka_${kafka_version}/site-docs/" && \
	ln -sfv /bin/bash /bin/sh && \
	adduser -h /home/simpleton/ -s /bin/bash -D simpleton

USER simpleton
ENV PATH="${PATH}:/opt/mssql-tools/bin:/opt:/opt/kafka/bin"

ENTRYPOINT ["/bin/bash"]
CMD ["-c", "trap : TERM INT; (while true; do sleep 1000; done) & wait"]
