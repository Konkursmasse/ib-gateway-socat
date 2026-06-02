FROM ghcr.io/gnzsnz/ib-gateway:stable

USER root
RUN apt-get update \
 && apt-get install -y socat iproute2 novnc websockify \
 && rm -rf /var/lib/apt/lists/*

COPY --chown=ibgateway:ibgateway start-with-socat.sh /opt/start-with-socat.sh
RUN chmod +x /opt/start-with-socat.sh

USER ibgateway

EXPOSE 4003 4004 5900 6080

ENTRYPOINT ["/opt/start-with-socat.sh"]
