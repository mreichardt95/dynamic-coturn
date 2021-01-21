FROM instrumentisto/coturn:4

ADD https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.2/s6-overlay-amd64-installer /tmp/
COPY run.sh /tmp/
COPY detect-ip-change.sh /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer / \
    && mkdir -p /etc/services.d/turnserver/ \
    && mkdir -p /etc/services.d/detect-ip-change/ \
    && mv /tmp/run.sh /etc/services.d/turnserver/run \
    && chmod +x /etc/services.d/turnserver/run \
    && mv /tmp/detect-ip-change.sh /etc/services.d/detect-ip-change/run \
    && chmod +x /etc/services.d/detect-ip-change/run

ENTRYPOINT ["/init"]
