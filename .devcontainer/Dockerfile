# Clean-room check that bootstrap.sh links everything on a fresh Linux box.
FROM ubuntu:24.04

ARG USERNAME=dev

COPY platform/linux/apt.sh /tmp/apt.sh
RUN apt-get update && apt-get install -y --no-install-recommends sudo \
    && bash /tmp/apt.sh && rm /tmp/apt.sh

RUN useradd --create-home --shell /bin/zsh "${USERNAME}" \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}"

USER ${USERNAME}
WORKDIR /home/${USERNAME}
