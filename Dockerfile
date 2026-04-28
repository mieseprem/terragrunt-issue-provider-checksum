FROM ubuntu:24.04

ARG TERRAGRUNT_VERSION=1.0.3
ARG TOFU_VERSION=1.11.6

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl -Lo /tmp/tofu.tar.gz \
    https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_amd64.tar.gz \
    && tar -xzf /tmp/tofu.tar.gz -C /usr/local/bin/ tofu \
    && chmod +x /usr/local/bin/tofu \
    && rm /tmp/tofu.tar.gz

RUN curl -Lo /usr/local/bin/terragrunt \
    https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
    && chmod +x /usr/local/bin/terragrunt

WORKDIR /workspace

CMD ["bash"]
