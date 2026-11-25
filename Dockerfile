# Anki Desktop Docker - High Performance Browser-Based Anki
# Uses LinuxServer's KasmVNC for optimal streaming performance
# Supports Anki 26.x self-contained bundle format
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# Build arguments
ARG ANKI_VERSION="26.09.4"
ARG BUILD_DATE
ARG VERSION

# Labels
LABEL build_version="Anki Desktop Docker version: ${VERSION} Build-date: ${BUILD_DATE}"
LABEL maintainer="chrislongros"
LABEL org.opencontainers.image.description="Browser-accessible Anki Desktop with KasmVNC - Latest Version"

# Environment variables
ENV TITLE="Anki" \
    CUSTOM_PORT=3000 \
    CUSTOM_HTTPS_PORT=3001 \
    START_DOCKER=false \
    PUID=1000 \
    PGID=1000 \
    ANKI_VERSION=${ANKI_VERSION}

# Install Anki system dependencies (from Anki's own install.sh DEBIAN_DEPS list)
# and tools needed during the build step
RUN \
    echo "**** install dependencies ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        # Anki 26.x required system libs (from upstream install.sh)
        libdbus-1-3 \
        libfontconfig1 \
        libfreetype6 \
        libgl1 \
        libglib2.0-0 \
        libnss3 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-randr0 \
        libxcb-render-util0 \
        libxcb-shape0 \
        libxcb-xinerama0 \
        libxcb-xkb1 \
        libxcomposite1 \
        libxcursor1 \
        libxi6 \
        libxkbcommon0 \
        libxkbcommon-x11-0 \
        libxrandr2 \
        libxrender1 \
        libxtst6 \
        # Additional Qt/Chromium libs needed in a container environment
        libxcb-cursor0 \
        libgbm1 \
        libegl1 \
        libdrm2 \
        libgtk-3-0 \
        libatomic1 \
        libasound2 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libcups2 \
        # Tools needed for build
        zstd \
        unzip \
        curl \
        ca-certificates \
        xdg-utils \
        # Fonts
        fonts-liberation \
        fonts-noto \
        fonts-noto-color-emoji \
    && \
    echo "**** download and install Anki ${ANKI_VERSION} ****" && \
    mkdir -p /opt/anki && \
    curl -fLo /tmp/anki.tar.zst \
        "https://github.com/ankitects/anki/releases/download/${ANKI_VERSION}/anki-${ANKI_VERSION}-linux-$(uname -m | sed 's/aarch64/aarch64/;s/x86_64/x86_64/').tar.zst" && \
    tar --use-compress-program=unzstd -xf /tmp/anki.tar.zst -C /opt/anki --strip-components=1 && \
    chmod +x /opt/anki/anki && \
    echo "**** download AnkiConnect addon to staging ****" && \
    mkdir -p /opt/anki-addons-staging/2055492159 && \
    curl -fLo /tmp/anki-connect.tar.gz \
        "https://github.com/FooSoft/anki-connect/archive/refs/heads/master.tar.gz" && \
    tar -xzf /tmp/anki-connect.tar.gz -C /tmp && \
    cp -a /tmp/anki-connect-master/plugin/. /opt/anki-addons-staging/2055492159/ && \
    echo "**** download Anki Beacon addon to staging ****" && \
    mkdir -p /opt/anki-addons-staging/1577021707 && \
    curl -fLo /tmp/anki-beacon.ankiaddon \
        "https://github.com/bpwhelan/AnkiBeacon/releases/latest/download/Anki.Beacon.ankiaddon" && \
    unzip -q /tmp/anki-beacon.ankiaddon -d /opt/anki-addons-staging/1577021707 && \
    echo "**** download Local Audio for Yomichan addon to staging ****" && \
    mkdir -p /opt/anki-addons-staging/local-audio-yomichan && \
    curl -fLo /tmp/local-audio.tar.gz \
        "https://github.com/yomidevs/local-audio-yomichan/archive/refs/heads/master.tar.gz" && \
    tar -xzf /tmp/local-audio.tar.gz -C /tmp && \
    cp -a /tmp/local-audio-yomichan-master/plugin/. /opt/anki-addons-staging/local-audio-yomichan/ && \
    sed -i 's/ThreadingHTTPServer((HOSTNAME, port)/ThreadingHTTPServer(("0.0.0.0", port)/' /opt/anki-addons-staging/local-audio-yomichan/server.py && \
    grep -q 'ThreadingHTTPServer(("0.0.0.0", port)' /opt/anki-addons-staging/local-audio-yomichan/server.py && \
    echo "**** cleanup ****" && \
    rm -rf /tmp/anki* /tmp/local-audio* && \
    apt-get remove -y zstd unzip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# Copy application config
COPY root/ /

# Expose ports: KasmVNC (3000/3001) + AnkiConnect (8765) + Anki Beacon (7275) + Local Audio (5050)
EXPOSE 3000 3001 8765 7275 5050

# Healthcheck - verify KasmVNC is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD curl -sf http://localhost:3000/ || exit 1

# Volume for Anki data persistence
VOLUME /config
