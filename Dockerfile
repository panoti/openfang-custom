FROM debian:bookworm-slim AS builder

ARG OPENFANG_VERSION=v0.5.9

WORKDIR /build

# Download openfang release
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && curl -L -o openfang.tar.gz https://github.com/RightNow-AI/openfang/releases/download/${OPENFANG_VERSION}/openfang-x86_64-unknown-linux-gnu.tar.gz \
    && tar -xzf openfang.tar.gz -C /build \
    && rm openfang.tar.gz \
    && rm -rf /var/lib/apt/lists/*

FROM rust:1-slim-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/openfang /usr/local/bin/
COPY --from=builder /build/agents /opt/openfang/agents/

EXPOSE 4200
VOLUME /data
ENV OPENFANG_HOME=/data
ENTRYPOINT ["openfang"]
CMD ["start"]
