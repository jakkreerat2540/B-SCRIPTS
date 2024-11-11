#!/bin/bash

workdir=$(pwd)

function download_docker(){

    # download script to install docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    chmod +x get-docker.sh

}

function install_docker(){

    # install docker
    ./get-docker.sh

    sleep 5

    # check service docker exist
    check_docker=$(systemctl status docker | grep "Active: active (running)" | wc -l)
    if [[ $check_docker -eq 1 ]]; then
        
        # create docker daemon logging 3 files with 100MB each 
        mkdir -p /etc/docker
        touch /etc/docker/daemon.json
        cat > /etc/docker/daemon.json <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    }
}
EOF

        # restart docker service
        systemctl daemon-reload
        systemctl restart docker

        # check docker version
        docker --version

        # check docker info
        docker info

    else
        echo "Docker is not running"
    fi


}


# function main 
function main(){

    download_docker
    install_docker

}

main