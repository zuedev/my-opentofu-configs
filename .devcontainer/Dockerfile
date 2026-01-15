FROM ubuntu:20.04

WORKDIR /app

# get apt lists
RUN apt update

# install & enable fish shell
RUN apt install -y fish && \
    chsh -s /usr/bin/fish

# install opentofu (terraform fork)
RUN apt install -y gnupg software-properties-common curl && \
    curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh && \
    chmod +x install-opentofu.sh && \
    ./install-opentofu.sh --install-method deb && \
    rm install-opentofu.sh

# clean up
RUN apt clean && rm -rf /var/lib/apt/lists/*

# print opentofu version
RUN tofu -version