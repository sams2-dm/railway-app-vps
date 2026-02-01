FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    ca-certificates \
    gnupg \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Set root password
RUN echo "root:root123" | chpasswd

# Prepare ssh
RUN mkdir -p /var/run/sshd

# Enable root login + password login
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Install ngrok (Ubuntu 24.04 / noble)
RUN curl -Lo /tmp/ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz \
    && tar -xzf /tmp/ngrok.tgz -C /usr/local/bin \
    && rm /tmp/ngrok.tgz


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

CMD ["/usr/bin/supervisord","-n"]
