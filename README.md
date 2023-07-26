# Siegfried docker deployment
Docker deployment for Siegfried file format identifier service.

Check docker images at:
https://github.com/keeps/siegfried-docker/pkgs/container/siegfried

Siegfried file format identification service running as a minimal container.

Documentation on how to use the service on:
https://github.com/richardlehane/siegfried/wiki/Using-the-siegfried-server

Run as a server:
```sh
# Start server, mapping data into the container, here using the current directory `$PWD`
docker run -v $PWD:$PWD -p 5138:5138 -e SIEGFRIED_HOST=0.0.0.0 -d --name siegfried keeps/siegfried:v1.9.4
# Make requests using curl, here sending the current directory in base64 encoding
curl  "http://localhost:5138/identify/$(echo -n $PWD | base64 -)?base64=true"
# Stop server
docker stop siegfried
```
Run as a command:
```sh
# Run in current directory
docker run -v $PWD:$PWD --rm keeps/siegfried:v1.9.4 sf $PWD
```


Parameters via environment variables:
* SIEGFRIED_HOST: Set the binding host for the service, use `0.0.0.0` to accept any connection. Default: `0.0.0.0`
* SIEGFRIED_PORT: Set the port for the service. Default: `5138`.

Change user id so siegfried can access content in mounted volumes:
* Set user id and group using docker run --user or [docker compose user attribute](https://docs.docker.com/compose/compose-file/compose-file-v3/#domainname-hostname-ipc-mac_address-privileged-read_only-shm_size-stdin_open-tty-user-working_dir)
* Set USER environment variable to "siegfried"
* Set HOME environment variable to "/home/siegfried/"

Build arguments:
* SIEGFRIED_VERSION: Set the version of siegfried to install. Default: `latest`
* SIEGFRIED_USER: Set the name of the user running in the container. Default: `siegfried`
* SIEGFRIED_UID: Set the UID of the user running in the container. Default: `1000`
