FROM finboxio/rancher-conf-aws:v1.1.3

RUN apk add --no-cache \
  -X http://dl-cdn.alpinelinux.org/alpine/v3.9/community \
  yaml-cpp=0.6.2-r2 && \
  apk add --no-cache \
  -X http://dl-cdn.alpinelinux.org/alpine/v3.9/main \
  -X http://dl-cdn.alpinelinux.org/alpine/v3.9/community \
  mongodb && \
  apk upgrade --available

ADD mongo-init /opt/rancher/bin/
ADD mongo-init-cleanup /opt/rancher/bin/
ADD mongo-preload /opt/rancher/bin/
ADD mongo-backup-verify /opt/rancher/bin/

ADD pre-snapshot /pre-snapshot
ADD post-snapshot /post-snapshot

ENV PRE_SNAPSHOT_SCRIPT /pre-snapshot
ENV POST_SNAPSHOT_SCRIPT /post-snapshot

ADD entrypoint.sh /opt/rancher/bin/entrypoint.sh
