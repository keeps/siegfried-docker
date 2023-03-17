#!/bin/bash

SIEGFRIED_VERSION=${1:-latest}

docker build --build-arg "SIEGFRIED_VERSION=$SIEGFRIED_VERSION" -t "ghcr.io/keeps/siegfried:$SIEGFRIED_VERSION" .