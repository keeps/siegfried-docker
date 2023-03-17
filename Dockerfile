FROM golang:1-alpine
ARG SIEGFRIED_VERSION=latest
ARG SIEGFRIED_USER="siegfried"
ARG SIEGFRIED_UID="1000"

RUN go install github.com/richardlehane/siegfried/cmd/sf@${SIEGFRIED_VERSION}
RUN sf -update

ENV SIEGFRIED_HOST=0.0.0.0
ENV SIEGFRIED_PORT=5138

RUN adduser -u "$SIEGFRIED_UID" -S "$SIEGFRIED_USER" -h /home/siegfried/;

EXPOSE ${SIEGFRIED_PORT}

USER "$SIEGFRIED_UID"

RUN sf -update;

CMD sf -serve ${SIEGFRIED_HOST}:${SIEGFRIED_PORT}
