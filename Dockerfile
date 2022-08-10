FROM golang:1-alpine
ARG SIEGFRIED_VERSION=latest

RUN go install github.com/richardlehane/siegfried/cmd/sf@${SIEGFRIED_VERSION}
RUN sf -update

ENV SIEGFRIED_HOST=0.0.0.0
ENV SIEGFRIED_PORT=5138

EXPOSE ${SIEGFRIED_PORT}

CMD sf -serve ${SIEGFRIED_HOST}:${SIEGFRIED_PORT}
