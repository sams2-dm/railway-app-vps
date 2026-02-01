FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    ca-certificates \
    gnupg \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create ssh user
RUN useradd -m vps && \
    echo "vps:vps123" | chpasswd && \
    usermod -aG sudo vps

# Prepare ssh
RUN mkdir /var/run/sshd

# Allow password login
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Install ngrok (official repo for Ubuntu 24.04)
RUN curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
    | gpg --dearmor -o /usr/share/keyrings/ngrok.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/ngrok.gpg] https://ngrok-agent.s3.amazonaws.com noble main" \
    > /etc/apt/sources.list.d/ngrok.list && \
    apt-get update && apt-get install -y ngrok

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

CMD ["/usr/bin/supervisord","-n"]
