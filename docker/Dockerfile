FROM docker.mirror.hashicorp.services/hashicorp/terraform:light

RUN wget https://releases.hashicorp.com/vault/1.11.3/vault_1.11.3_linux_amd64.zip && \
    unzip vault_1.11.3_linux_amd64.zip && \
    mv vault /usr/local/bin/vault && \
    rm vault_1.11.3_linux_amd64.zip