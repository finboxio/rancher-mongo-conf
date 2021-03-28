FROM finboxio/rancher-conf-aws:v1.1.1

RUN apk add --no-cache yaml-cpp

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/main' > /etc/apk/repositories
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >> /etc/apk/repositories
RUN apk add --no-cache mongodb

ADD mongo-init /opt/rancher/bin/
ADD mongo-init-cleanup /opt/rancher/bin/
ADD mongo-preload /opt/rancher/bin/
ADD mongo-backup-verify /opt/rancher/bin/

ADD pre-snapshot /pre-snapshot
ADD post-snapshot /post-snapshot

ENV PRE_SNAPSHOT_SCRIPT /pre-snapshot
ENV POST_SNAPSHOT_SCRIPT /post-snapshot

ADD entrypoint.sh /opt/rancher/bin/entrypoint.sh
