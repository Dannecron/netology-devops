FROM elasticsearch:7.16.3

ENV NODE_NAME=netology_test
ENV DISCOVERY_TYPE=single-node
ENV ES_HEAP_SIZE=262144

RUN mkdir -m 774 -p /var/lib/elasticsearch-data \
    && chown elasticsearch -R /var/lib/elasticsearch-data \
    && mkdir -m 774 -p /var/log/elasticsearch \
    && chown elasticsearch -R /var/log/elasticsearch

COPY ./elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
