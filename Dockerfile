FROM nvidia/cuda:12.9.1-base-ubuntu22.04
ENV SHELL="/bin/bash"
ENV DEBIAN_FRONTEND="noninteractive"
ENV DEBCONF_NONINTERACTIVE_SEEN="true"

RUN apt update \
    && apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    inetutils-ping \
    sudo \
    python3 \
    python3-pip \
    vim-nox \
    net-tools \
    telnet \
    git \
    rsync \
    tmux \
    ripgrep \
    htop \
    jq \
    ipmitool \
    dnsutils \
    openssh-client sshpass xauth \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu129

RUN pip3 install transformers

RUN pip3 install git+https://github.com/huggingface/diffusers

WORKDIR /root
COPY . .
