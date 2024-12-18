FROM jenkins/jenkins:2.479.1-jdk17

# Switch to root to install dependencies
USER root

# Install base dependencies
RUN apt-get update && apt-get install -y \
    lsb-release \
    curl \
    gnupg \
    && apt-get clean

# Add Docker's official GPG key
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up Docker repository
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Update and install Docker CLI and Python
RUN apt-get update && apt-get install -y \
    docker-ce-cli \
    python3 \
    python3-pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && apt-get clean

# Switch back to Jenkins user
USER jenkins

# Install Jenkins plugins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
