FROM centos:7
LABEL maintainer zion

ENV ELASTIC_VERSION 6.2.0
ENV UUID 449
ENV GUID 449

ENV ELASTIC_CONTAINER true
ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0-openjdk

RUN yum update -y && yum install -y java-1.8.0-openjdk-headless wget which

RUN groupadd -g ${GUID} elasticsearch && adduser -u ${UUID} -g ${GUID} -d /usr/share/elasticsearch elasticsearch

WORKDIR /usr/share/elasticsearch

RUN wget --progress=bar:force https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTIC_VERSION}.tar.gz && \
    tar zxf elasticsearch-${ELASTIC_VERSION}.tar.gz && \
    chown -R elasticsearch:elasticsearch elasticsearch-${ELASTIC_VERSION} && \
    mv elasticsearch-${ELASTIC_VERSION}/* . && \
    rmdir elasticsearch-${ELASTIC_VERSION} && \
    rm elasticsearch-${ELASTIC_VERSION}.tar.gz

RUN set -ex && for esdirs in config data logs; do \
        mkdir -p "$esdirs"; \
    done

USER elasticsearch

COPY log4j2.properties config/
COPY bin/es-docker bin/es-docker

USER root
RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch && \
    chmod 0750 bin/es-docker

USER elasticsearch
CMD ["/bin/bash", "bin/es-docker"]

EXPOSE 9200 9300
