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
RUN curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
    | gpg --dearmor -o /usr/share/keyrings/ngrok.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/ngrok.gpg] https://ngrok-agent.s3.amazonaws.com noble main" \
    > /etc/apt/sources.list.d/ngrok.list && \
    apt-get update && apt-get install -y ngrok

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

CMD ["/usr/bin/supervisord","-n"]
