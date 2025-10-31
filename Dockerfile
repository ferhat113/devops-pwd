FROM jenkins/jenkins:lts-jdk21

# Switch to root to install packages
USER root

# Install dependencies and tools in a single layer to reduce image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        lsb-release \
        wget \
        vim \
        ca-certificates \
        gnupg && \
    \
    # Add Docker CLI
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
          https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    \
    # Install Maven
    MAVEN_VERSION=3.9.11 && \
    cd /opt && \
    wget -q "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" && \
    tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    mv apache-maven-${MAVEN_VERSION} maven && \
    rm apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    \
    # Clean up apt cache and temp files
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set Maven environment variables
ENV M2_HOME=/opt/maven
ENV PATH=${M2_HOME}/bin:${PATH}

# Switch back to jenkins user
USER jenkins
