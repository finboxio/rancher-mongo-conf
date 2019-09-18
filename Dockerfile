FROM finboxio/rancher-conf-aws:v0.1.0

ADD mongo-init /opt/rancher/bin/
ADD mongo-init-cleanup /opt/rancher/bin/
ADD mongo-preload /opt/rancher/bin/

ADD entrypoint.sh /opt/rancher/bin/entrypoint.sh
