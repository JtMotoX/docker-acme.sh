FROM neilpang/acme.sh:latest

# SETUP SUPERCRONIC FOR NON-ROOT USER
ENV SUPERCRONIC_VERSION="v0.2.1"
ENV CRONTAB_FILE="/crontab"
RUN apk add --no-cache inotify-tools
RUN wget https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64 -O /usr/local/bin/supercronic && \
	chmod 755 /usr/local/bin/supercronic
COPY --chmod=644 ./crontab /crontab
RUN supercronic -json -test /crontab

ENV USER_ID="9001"

ENV LE_HOME="/acme.sh"
ENV LE_CONFIG_HOME="/acme.sh/configs"
ENV LE_WORKING_DIR="/opt/.acme.sh"

# SETUP ACME.SH FOR NON-ROOT USER
RUN mv /root/.acme.sh ${LE_WORKING_DIR} && \
	chown -R ${USER_ID}:${USER_ID} ${LE_WORKING_DIR} && \
	rm -f /usr/local/bin/acme.sh && \
	ln -s ${LE_WORKING_DIR}/acme.sh /usr/local/bin/acme.sh

COPY --chmod=755 ./entrypoint.sh /entrypoint.sh

USER ${USER_ID}:${USER_ID}

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "run" ]
