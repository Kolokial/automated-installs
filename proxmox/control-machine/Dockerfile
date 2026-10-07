FROM debian:trixie-slim

# Pin these to what `tofu version`, `sops --version`, etc. report in your dev container
ARG TOFU_VERSION=1.10.0
ARG SOPS_VERSION=3.10.2
ARG AGE_VERSION=1.2.1
ARG ANSIBLE_CORE_VERSION=2.18.0

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git gh jq make openssh-client unzip \
      python3 pipx nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# OpenTofu, SOPS, age (arch is amd64 or arm64)
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    curl -fsSL -o /tmp/tofu.zip "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_${arch}.zip"; \
    unzip -o /tmp/tofu.zip tofu -d /usr/local/bin; \
    rm /tmp/tofu.zip; \
    curl -fsSL -o /usr/local/bin/sops "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${arch}"; \
    chmod +x /usr/local/bin/sops; \
    curl -fsSL "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-${arch}.tar.gz" \
      | tar -xz -C /usr/local/bin --strip-components=1 age/age age/age-keygen

# Ansible in an isolated venv
ENV PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin
RUN pipx install "ansible-core==${ANSIBLE_CORE_VERSION}" \
    && pipx install ansible-lint

# Claude Code (unpinned)
RUN npm install -g @anthropic-ai/claude-code

# Non-root user; pre-create mount points so named volumes inherit ownership
RUN useradd -m -u 1000 -s /bin/bash dev \
    && mkdir -p /work /home/dev/.config/gh /home/dev/.claude \
    && chown -R dev:dev /work /home/dev

COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

USER dev
WORKDIR /work
ENTRYPOINT ["entrypoint.sh"]
CMD ["bash"]
