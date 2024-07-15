#!/bin/bash
# Function to check if the last command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error occurred in $1"
        exit 1
    fi
}
# Check if Docker is installed and install if not
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io build-essential
    check_success "Docker Installation"
else
    echo "Docker is already installed."
fi
# Add the current user to the Docker group
echo "Adding the current user to the Docker group..."
sudo usermod -aG docker $USER
check_success "Adding User to Docker Group"
# Wait for usermod to take effect
sleep 5
# Check if Docker Compose is installed and install if not
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    check_success "Downloading Docker Compose"
    sudo chmod +x /usr/local/bin/docker-compose
    check_success "Setting Docker Compose Executable"
else
    echo "Docker Compose is already installed."
fi
# Initialize Docker Swarm
echo "Initializing Docker Swarm..."
if ! docker info | grep -q "Swarm: active"; then
    sudo docker swarm init
    check_success "Initializing Docker Swarm"
fi
# Create necessary Docker networks if they don't exist
create_network_if_not_exists() {
    if ! docker network ls | grep -q $1; then
        echo "Creating Docker network: $1"
        sudo docker network create -d overlay $1
        check_success "Creating $1 network"
    fi
}
create_network_if_not_exists "lmf-net"
echo "Installation and deployment completed!"

sudo chmod -R 755 /usr/apps
sudo chown -R $USER:$USER /usr/apps