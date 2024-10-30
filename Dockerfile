FROM amd64/ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y curl sudo jq

# Download the GitHub Actions runner package
ADD https://github.com/actions/runner/releases/download/v2.316.0/actions-runner-linux-x64-2.316.0.tar.gz runner.tar.gz

# Create the 'runner' user
RUN newuser=runner && \
    adduser --disabled-password --gecos "" $newuser && \
    usermod -aG sudo $newuser && \
    echo "$newuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to runner user
USER runner
WORKDIR /home/runner

# Move and extract runner package
RUN sudo mv /runner.tar.gz ./runner.tar.gz && \
    sudo chown runner:runner ./runner.tar.gz && \
    mkdir runner && \
    tar xzf runner.tar.gz -C runner && \
    rm runner.tar.gz

WORKDIR /home/runner/runner
RUN sudo ./bin/installdependencies.sh

# Copy start script
COPY start.sh start.sh
RUN chmod +x start.sh
ENTRYPOINT ["./start.sh"]
