FROM ubuntu:impish

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends ca-certificates\
        curl \
        make \
        sudo

# # install docker
RUN curl https://get.docker.com/ | bash

# install kind
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

# install kubectl
RUN curl -LO https://dl.k8s.io/release/v1.22.5/bin/linux/amd64/kubectl && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# install helm
RUN curl -L https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz -O  && \
    tar -zxvf helm-v3.8.0-linux-amd64.tar.gz && \
    cp linux-amd64/helm /usr/local/bin && \
    rm -r helm* linux-amd64
    
# install rasactl
RUN curl -L https://github.com/RasaHQ/rasactl/releases/download/1.0.4/rasactl_1.0.4_linux_amd64.tar.gz -O && \
    tar -zxvf rasactl_1.0.4_linux_amd64.tar.gz && \
    cp rasactl_1.0.4_linux_amd64/rasactl /usr/local/bin/ && \
    rm -r rasactl_1.0.4_linux_amd64*

WORKDIR /app
COPY rei.sh .
COPY makefile .
COPY values.yml .
COPY custom-ingress.yml .
