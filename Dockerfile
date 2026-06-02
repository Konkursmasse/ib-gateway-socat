FROM ghcr.io/gnzsnz/ib-gateway:stable

USER root
RUN apt-get update \
 && apt-get install -y socat iproute2 novnc websockify xdotool python3-pip \
 && pip3 install --break-system-packages pyotp \
 && rm -rf /var/lib/apt/lists/*

COPY --chown=ibgateway:ibgateway start-with-socat.sh /opt/start-with-socat.sh
RUN chmod +x /opt/start-with-socat.sh

USER ibgateway

EXPOSE 4003 4004 5900 6080

ENTRYPOINT ["/opt/start-with-socat.sh"]
