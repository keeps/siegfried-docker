FROM golang:1.18-alpine
ARG SIEGFRIED_VERSION=latest

RUN go install github.com/richardlehane/siegfried/cmd/sf@${SIEGFRIED_VERSION}
RUN sf -update

ENV SIEGFRIED_HOST=localhost
ENV SIEGFRIED_PORT=5138

EXPOSE ${SIEGFRIED_PORT}

CMD sf -serve ${SIEGFRIED_HOST}:${SIEGFRIED_PORT}