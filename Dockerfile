FROM ubuntu:rolling AS base
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime
RUN apt-get update
RUN yes | unminimize
RUN apt-get install -y apt-utils apt-transport-https curl build-essential
RUN groupadd toolbox && useradd -m -g toolbox toolbox

FROM base AS rustup

USER toolbox
WORKDIR /home/toolbox

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -q -y

FROM rustup AS bat
RUN .cargo/bin/cargo install --locked bat

FROM base

MAINTAINER Raphael Peters <raphael.r.peters@gmail.com>

RUN curl -s "https://raw.githubusercontent.com/rupa/z/master/z.sh" > /usr/local/bin/z.sh && chmod +x /usr/local/bin/z.sh
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update
RUN apt-get install -y \
    gnupg2 openssh-client sshfs git \
    zsh fish mksh \
    openjdk-13-jre-headless \
    curl wget \
    gzip bzip2 pbzip2 xz-utils zstd \
    iputils-ping iputils-tracepath mtr-tiny traceroute \
    python3 python3-pip \
    man-db \
    tmux screen mosh \
    vim-nox \
    build-essential \
    dnsutils iftop vnstat hping3 iperf3 bmon nmap tcpdump speedtest-cli \
    sudo \
    kubectl
RUN apt-get install -y ncdu

COPY --from=rustup --chown=toolbox:toolbox /home/toolbox/.rustup /home/toolbox/.rustup
COPY --from=rustup --chown=toolbox:toolbox /home/toolbox/.cargo /home/toolbox/.cargo
COPY --from=bat --chown=toolbox:toolbox /home/toolbox/.cargo/bin/bat /home/toolbox/.cargo/bin/bat

USER toolbox
WORKDIR /home/toolbox

ENTRYPOINT bash
