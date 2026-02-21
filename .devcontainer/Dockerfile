ARG VARIANT=3.10-bullseye
FROM python:${VARIANT}

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends wget \
    curl \
    ca-certificates \
    make \
    grep
