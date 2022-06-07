FROM golang:1.18-alpine
ARG SIEGFRIED_VERSION=latest

RUN go install github.com/richardlehane/siegfried/cmd/sf@${SIEGFRIED_VERSION}
RUN sf -update

EXPOSE 5138

CMD sf -serve localhost:5138