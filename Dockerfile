FROM jenkins/jenkins:2.479.1-jdk17

# Switch to root to install necessary packages
USER root

# Install dependencies for Docker and Python
RUN apt-get update && apt-get install -y \
    lsb-release \
    curl \
    docker-ce-cli \
    python3 \
    python3-pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && apt-get clean

# Install Docker GPG key and repository
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Update and install Docker CLI again (ensures latest version from Docker's repo)
RUN apt-get update && apt-get install -y docker-ce-cli && apt-get clean

# Switch back to Jenkins user
USER jenkins

# Install required Jenkins plugins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
