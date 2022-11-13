ARG VARIANT=3.10-bullseye
FROM python:${VARIANT}

COPY .devcontainer/python.sh /tmp/scripts/

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends wget \
    curl \
    ca-certificates \
    make \
    grep

ENV PIPX_HOME=/usr/local/pipx \
    PIPX_BIN_DIR=/usr/local/pipx/bin

ENV PATH=${PATH}:${PIPX_BIN_DIR}

RUN bash /tmp/scripts/python.sh \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN rm -rf /tmp/scripts
