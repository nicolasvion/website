FROM alpine:3.13

ENV WWW_URL=""
ARG DOCKER_HUGO_VERSION="0.80.0"
ENV DOCKER_HUGO_NAME="hugo_extended_${DOCKER_HUGO_VERSION}_Linux-64bit"
ENV DOCKER_HUGO_BASE_URL="https://github.com/gohugoio/hugo/releases/download"
ENV DOCKER_HUGO_URL="${DOCKER_HUGO_BASE_URL}/v${DOCKER_HUGO_VERSION}/${DOCKER_HUGO_NAME}.tar.gz"
ENV DOCKER_HUGO_CHECKSUM_URL="${DOCKER_HUGO_BASE_URL}/v${DOCKER_HUGO_VERSION}/hugo_${DOCKER_HUGO_VERSION}_checksums.txt"

WORKDIR /build
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk add --no-cache --virtual .build-deps wget && \
    apk add --no-cache \
    git \
    bash \
    make \
    nginx \
    ca-certificates \
    libc6-compat \
    libstdc++ && \
    wget --quiet "${DOCKER_HUGO_URL}" && \
    wget --quiet "${DOCKER_HUGO_CHECKSUM_URL}" && \
    grep "${DOCKER_HUGO_NAME}.tar.gz" "./hugo_${DOCKER_HUGO_VERSION}_checksums.txt" | sha256sum -c - && \
    tar -zxvf "${DOCKER_HUGO_NAME}.tar.gz" && \
    mv ./hugo /usr/bin/hugo && \
    hugo version && \
    apk del .build-deps && \
    rm -rf /build

COPY entrypoint.sh /opt/entrypoint.sh
COPY default.conf /etc/nginx/conf.d/

WORKDIR /src
ENTRYPOINT /opt/entrypoint.sh ${WWW_URL}

EXPOSE 80
