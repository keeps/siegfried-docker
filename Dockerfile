FROM golang:1.26.0-alpine AS build
ARG SIEGFRIED_VERSION=latest
ENV CGO_ENABLED=0

RUN go install github.com/richardlehane/siegfried/cmd/sf@${SIEGFRIED_VERSION}
RUN sf -update

FROM alpine:3.22
ARG SIEGFRIED_USER="siegfried"
ARG SIEGFRIED_UID="1000"

RUN adduser -u "$SIEGFRIED_UID" -S "$SIEGFRIED_USER" -h "/home/$SIEGFRIED_USER/"

COPY --from=build /go/bin/sf /usr/local/bin/sf
COPY --from=build --chown="$SIEGFRIED_UID:0" /root/.local/share/siegfried "/home/$SIEGFRIED_USER/.local/share/siegfried"

USER "$SIEGFRIED_UID"

ENV SIEGFRIED_HOST=0.0.0.0
ENV SIEGFRIED_PORT=5138
ENV USER="$SIEGFRIED_USER"
ENV HOME="/home/$SIEGFRIED_USER/"

EXPOSE ${SIEGFRIED_PORT}

CMD ["sh", "-c", "exec sf -serve $SIEGFRIED_HOST:$SIEGFRIED_PORT"]
