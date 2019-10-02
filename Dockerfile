FROM finboxio/rancher-conf-aws:v0.1.0

RUN apk add --no-cache util-linux mongodb bash curl && \
    curl -L -o /usr/sbin/slack https://gist.githubusercontent.com/bdentino/6f6f91960e239e158f84d6bfe08cfd1d/raw/d1a387c6c568cff1f5169e158a3dfc15bdd1a9b7/slack-bash && \
    chmod +x /usr/sbin/slack

ADD mongo-init /opt/rancher/bin/
ADD mongo-init-cleanup /opt/rancher/bin/
ADD mongo-preload /opt/rancher/bin/
ADD mongo-backup /opt/rancher/bin/
ADD mongo-backup-verify /opt/rancher/bin/

ADD entrypoint.sh /opt/rancher/bin/entrypoint.sh
