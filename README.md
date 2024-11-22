# Jenkins_KnowHow
On Windows

git clone https://github.com/ShohelAlMahmudDev/Jenkins_KnowHow

If you are working on a Docker desktop, please check whether you have "enabled docker terminal" from the settings.
If not enabled then enable it. and step forward...



The Jenkins project provides a Linux container image, not a Windows container image. Be sure that your Docker for Windows installation is configured to run Linux Containers rather than Windows Containers. Refer to the Docker documentation for instructions to switch to Linux containers. Once configured to run Linux Containers, the steps are:

1. Open up a command prompt window and similar to the macOS and Linux instructions above do the following:

2. Create a bridge network in Docker

    docker network create jenkins_local

3.  Run a docker:dind Docker image

    docker run --name jenkins-docker --rm --detach \
      --privileged --network jenkins_local --network-alias docker \
      --env DOCKER_TLS_CERTDIR=/certs \
      --volume jenkins-docker-certs:/certs/client \
      --volume jenkins-data:/var/jenkins_home \
      --publish 2376:2376 \
      docker:find

4.  Customize the official Jenkins Docker image, by executing the following two steps:

  a. Create a Dockerfile with the following content:

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

  b.  Build a new docker image from this Dockerfile and assign the image a meaningful name, e.g. "myjenkins-blueocean:2.479.1-1":

      docker build -t myjenkins-blueocean:2.479.1-1 .

      If you have not yet downloaded the official Jenkins Docker image, the above process automatically downloads it for you.

5.  Run your own myjenkins-blueocean:2.479.1-1 image as a container in Docker using the following docker run command:

    docker run --name jenkins-blueocean --restart=on-failure --detach \
      --network jenkins_local --env DOCKER_HOST=tcp://docker:2376 \
      --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
      --volume jenkins-data:/var/jenkins_home \
      --volume jenkins-docker-certs:/certs/client:ro \
      --publish 8080:8080 --publish 50000:50000 myjenkins-blueocean:2.479.1-1


Get the Password

docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword

Connect to the Jenkins

https://localhost:8080/

Installation Reference:
https://www.jenkins.io/doc/book/installing/docker/



alpine/socat container to forward traffic from Jenkins to Docker Desktop on Host Machine
https://stackoverflow.com/questions/47709208/how-to-find-docker-host-uri-to-be-used-in-jenkins-docker-plugin

docker run -d --restart=always -p 127.0.0.1:2376:2375 --network jenkins -v /var/run/docker.sock:/var/run/docker.sock alpine/socat tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock

docker inspect <container_id>

Remote Filesystem Root(AGENT_WORKDIR)
/home/jenkins/agent

