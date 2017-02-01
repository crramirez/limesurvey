LimeSurvey
==========

LimeSurvey - the most popular
Free Open Source Software survey tool on the web.

https://www.limesurvey.org/en/

This docker image is for Limesurvey on apache/php in its own container. It accepts environment variables to update the configuration file.

# How to use this image

```console
$ docker run --name some-limesurvey --link some-mysql:mysql -d acspri/limesurvey
```

The following environment variables are also honored for configuring your Limesurvey instance. If Limesurvey is already installed, these environment variables will update the Limesurvey config file.

-	`-e LIMESURVEY_DB_HOST=...` (defaults to the IP and port of the linked `mysql` container)
-	`-e LIMESURVEY_DB_USER=...` (defaults to "root")
-	`-e LIMESURVEY_DB_PASSWORD=...` (defaults to the value of the `MYSQL_ROOT_PASSWORD` environment variable from the linked `mysql` container)
-	`-e LIMESURVEY_DB_NAME=...` (defaults to "limesurvey")
-	`-e LIMESURVEY_TABLE_PREFIX=...` (defaults to "" - set this to "lime_" for example if your database has a prefix)

If the `LIMESURVEY_DB_NAME` specified does not already exist on the given MySQL server, it will be created automatically upon startup of the `limesurvey` container, provided that the `LIMESURVEY_DB_USER` specified has the necessary permissions to create it.

If you'd like to be able to access the instance from the host without the container's IP, standard port mappings can be used:

```console
$ docker run --name some-limesurvey --link some-mysql:mysql -p 8080:80 -d acspri/limesurvey
```

Then, access it via `http://localhost:8080` or `http://host-ip:8080` in a browser.

If you'd like to use an external database instead of a linked `mysql` container, specify the hostname and port with `LIMESURVEY_DB_HOST` along with the password in `LIMESURVEY_DB_PASSWORD` and the username in `LIMESURVEY_DB_USER` (if it is something other than `root`):

```console
$ docker run --name some-limesurvey -e LIMESURVEY_DB_HOST=10.1.2.3:3306 \
    -e LIMESURVEY_DB_USER=... -e LIMESURVEY_DB_PASSWORD=... -d acspri/limesurvey
```

## ... via [`docker-compose`](https://github.com/docker/compose)

Example `docker-compose.yml` for `limesurvey`:

```yaml
version: '2'

services:

  limesurvey:
    image: limesurvey
    ports:
      - 8082:80
    environment:
      LIMESURVEY_DB_PASSWORD: example

  mysql:
    image: mariadb
    environment:
      MYSQL_ROOT_PASSWORD: example
```

Run `docker-compose up`, wait for it to initialize completely, and visit `http://localhost:8080` or `http://host-ip:8080`.

# Supported Docker versions

This image is officially supported on Docker version 1.12.3.

Support for older versions (down to 1.6) is provided on a best-effort basis.

Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker daemon.

Notes
-----

This Dockerfile is based on the [Wordpress official docker image](https://github.com/docker-library/wordpress/tree/8ab70dd61a996d58c0addf4867a768efe649bf65/php5.6/apache)

