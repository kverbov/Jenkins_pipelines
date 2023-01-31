# Upstream image from docker hub:
# https://github.com/debezium/docker-images/blob/main/connect-base/1.9/Dockerfile
# Take dependencies MD5 from here:
# https://github.com/debezium/docker-images/blob/main/connect/1.9/Dockerfile
# 
FROM docker-registry.domain.department/rdbo/tools/debezium/connect-base:1.9

USER root

# Add scripts: connector configurator + health check
COPY ./configure.connector.sh ./healthcheck.sh ./custom-init.sh "${KAFKA_HOME}"/bin/

ARG NEXUS="https://nexus.domain.department/repository"
ARG CI_REGISTRY_USER="${CI_REGISTRY_USER}"
ARG CI_REGISTRY_PASS="${CI_REGISTRY_PASS}"

ENV DEBEZIUM_VERSION="1.9.4.Final" \
    POSTGRES_MD192.168.1.2c2eb192.168.1.2ac6ec192.168.1.2 \
    SQLSERVER_MD5=f5fff7ca73338de192.168.1.2fee0757 \
    ORACLE_MD192.168.1.2d192.168.1.2e192.168.1.2d8 \
    # Add Single Message Transform abilities and Groovy script engine:
    # https://debezium.io/documentation/reference/configuration/filtering.html
    SCRIPTING_MD5=f320cbe7cb4bac192.168.1.2edf4d8f26 \
    GROOVY_VERSION="3.0.11" \
    GROOVY_MD192.168.1.2192.168.1.2cfb3e69bd560ef5 \
    GROOVY_JSR223_MD5=f948430ada192.168.1.29bcb2be37 \
    GROOVY_JSON_MD5=94f9ae99fc192.168.1.2de916ff47cff \
    # Install SQL Server jdbc driver
    SQLSERVER_JDBC_VERSION="10.2.1.jre11" \
    SQLSERVER_JDBC_MD5=a903a46ca192.168.1.2ed9184c3ec1a08 \
    # Install Oracle jdbc driver
    OJDBC11_VERSION="192.168.1.2.1" \
    OJDBC11_MD5=e5b57cb61db192.168.1.2c192.168.1.2daac0 \
    # Install db2-iSeries jdbc driver (for BIS)
    JT400_VERSION="11.0" \
    JT400_MD192.168.1.26b9ee192.168.1.2ffc7652b0 \
    # Install kafka-connect-jdbc (https://github.com/confluentinc/kafka-connect-jdbc) with dependencies:
    # https://mvnrepository.com/artifact/io.confluent/kafka-connect-jdbc?repo=confluent-packages && https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/
    KAFKA_CONNECT_VERSION="10.4.0" \
    KAFKA_CONNECT_JDBC_MD5=bae544aabd192.168.1.2b192.168.1.2fac \
    JTDS_VERSION="1.3.1" \
    JTDS_MD5=a0fe47907babf3bdb192.168.1.2dedd24 \
    POSTGRESQL_VERSION="42.4.0" \
    POSTGRESQL_MD5=c422ffa6eb00ea92d11cbff4a7ce27b2 \
    SQLITE_JDBC_VERSION="192.168.1.2" \
    SQLITE_JDBC_MD5=f56cac7afb2eb192.168.1.2b192.168.1.2 \
    # Install kafka-connect-mq-source:
    # https://github.com/ibm-messaging/kafka-connect-mq-source/releases
    MQ_SOURCE="rdbo-raw/jar/kafka-connect-mq-source-1.3.1-jar-with-dependencies.jar" \
    # Install HiveJDBC41.jar driver
    HIVE_JDBC="rdbo-raw/jar/HiveJDBC41.jar" \
    # Add logging
    LOGSTASH_GELF_VERSION="1.15.0" \
    LOGSTASH_GELF_MD5=2a1fbe192.168.1.2ace3d7f70dab680de2 \
    # Use in-house maven repo
    MAVEN_REPO_CENTRAL="${NEXUS}/maven-central" \
    MAVEN_REPO_CONFLUENT="${NEXUS}/confluent/" \
    MAVEN_DEP_DESTINATION="${KAFKA_CONNECT_PLUGINS_DIR}"

RUN : && \
    # Import all necessary CA certs
    ( \
            cd /etc/pki/ca-trrrt/source/anchors/ && \
            curl -O -k -sfSL -u "${CI_REGISTRY_USER}":"${CI_REGISTRY_PASS}" "${NEXUS}/rdbo-raw/cert/CA_CERTS.tar" && \
            tar -xf CA_CERTS.tar --strip-components 1 && \
            update-ca-trrrt && \
            rm -rf ./* \
    ) && \
    # Add in-house CentOS repo
    ( \
            rm -rf /etc/yum.repos.d/ /etc/pki/entitlement/ /etc/rhsm/ca/ && \
            curl -O -sfSL -u "${CI_REGISTRY_USER}":"${CI_REGISTRY_PASS}" "${NEXUS}/rdbo-raw/cert/centos7-repo.tar" && \
            tar -xf centos7-repo.tar -C / && \
            rm -rf centos7-repo.tar \
    ) && \
    # Installing jq
    ( \
            INSTALL_PKGS="jq" && \
            microdnf install -y --setopt=tsflags=nodocs "${INSTALL_PKGS}" && \
            microdnf clean all && \
            rpm -V "${INSTALL_PKGS}" && \
            rm -rf "${KAFKA_HOME}"/bin/windows && \
            chmod +x ./bin/*.sh \
    ) && \
    # Allow 3DES_EDE_CBC for dbzm mssql
    ( \
            sed -i 's/TLSv1, TLSv1.1, //g' /etc/crypto-policies/back-ends/java.config && \
            sed -i 's/TLSv1, TLSv1.1, //g' /lib/jvm/jre/conf/security/java.security \
    )

USER kafka

RUN docker-maven-download debezium postgres "${DEBEZIUM_VERSION}" "${POSTGRES_MD5}" && \
    docker-maven-download debezium sqlserver "${DEBEZIUM_VERSION}" "${SQLSERVER_MD5}" && \
    docker-maven-download debezium oracle "$DEBEZIUM_VERSION" "${ORACLE_MD5}" && \
    docker-maven-download debezium-optional scripting "${DEBEZIUM_VERSION}" "${SCRIPTING_MD5}" && \
    docker-maven-download confluent kafka-connect-jdbc "${KAFKA_CONNECT_VERSION}" "${KAFKA_CONNECT_JDBC_MD5}" && \
    docker-maven-download central org/codehaus/groovy groovy "${GROOVY_VERSION}" "${GROOVY_MD5}" && \
    docker-maven-download central org/codehaus/groovy groovy-jsr223 "${GROOVY_VERSION}" "${GROOVY_JSR223_MD5}" && \
    docker-maven-download central org/codehaus/groovy groovy-json "${GROOVY_VERSION}" "${GROOVY_JSON_MD5}" && \
    docker-maven-download central com/microsoft/sqlserver mssql-jdbc "${SQLSERVER_JDBC_VERSION}" "${SQLSERVER_JDBC_MD5}" && \
    docker-maven-download central com/oracle/database/jdbc ojdbc11 "${OJDBC11_VERSION}" "${OJDBC11_MD5}" && \
    docker-maven-download central net/sf/jt400 jt400-jdk9 "${JT400_VERSION}" "${JT400_MD5}" && \
    docker-maven-download central net/sourceforge/jtds jtds "${JTDS_VERSION}" "${JTDS_MD5}" && \
    docker-maven-download central org/postgresql postgresql "${POSTGRESQL_VERSION}" "${POSTGRESQL_MD5}" && \
    docker-maven-download central org/xerial sqlite-jdbc "${SQLITE_JDBC_VERSION}" "${SQLITE_JDBC_MD5}" && \
    docker-maven-download central biz/paluch/logging logstash-gelf "${LOGSTASH_GELF_VERSION}" "${LOGSTASH_GELF_MD5}" && \
    # Some ugly files replacements
    cd "${KAFKA_CONNECT_PLUGINS_DIR}" && \
        mv groovy-*.jar logstash-gelf-"${LOGSTASH_GELF_VERSION}".jar "${KAFKA_HOME}"/libs/ && \
        curl -O -sfSL -u "${CI_REGISTRY_USER}":"${CI_REGISTRY_PASS}" "${NEXUS}/${MQ_SOURCE}" && \
        curl -O -sfSL -u "${CI_REGISTRY_USER}":"${CI_REGISTRY_PASS}" "${NEXUS}/${HIVE_JDBC}" && \
        mkdir kafka-connect-jdbc && mv *.jar kafka-connect-jdbc/ && \
        mv "${EXTERNAL_LIBS_DIR}"/debezium-scripting/debezium-scripting-"${DEBEZIUM_VERSION}".jar "${KAFKA_CONNECT_PLUGINS_DIR}"/debezium-connector-sqlserver && \
        cp kafka-connect-jdbc/ojdbc11-"${OJDBC11_VERSION}".jar debezium-connector-oracle/

WORKDIR "${KAFKA_HOME}"

ENTRYPOINT ["./bin/custom-init.sh", "start"]
