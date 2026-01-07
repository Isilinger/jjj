FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    firefox \
    xvfb \
    x11vnc \
    fluxbox \
    wget \
    git \
    python3 \
    python3-pip \
    ca-certificates \
    && pip3 install websockify \
    && rm -rf /var/lib/apt/lists/*

# Clone noVNC (static web client)
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC

# Copy startup script (the repo will contain .devcontainer/start.sh)
COPY .devcontainer/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 6080 5900

ENTRYPOINT ["/usr/local/bin/start.sh"]
