# docker-dev-env
Docker develop environment

## Install Virtualbox
https://www.virtualbox.org/wiki/Downloads

## Install Docker

  // OSX
  brew install docker
  // Linux
  Please install docker by your package manager 

## Install Docker-machine(OSX, Windows)
https://github.com/docker/machine/releases

## Create docker virtual machine
    
    docker-machine create --driver virtualbox --virtualbox-memory 2048 dev
    // from the second
    docker-machine start dev
    
## Launch docker devlop environment

    docker-compose up -d

## Access develop environment

    ssh -p 10022 dev@$(docker-machine ip)
  
## Access Sinatra App

    curl or Browser access => http://$(docker-machine ip):19393/
    
## Stop and remove docker machine
  
    docker-machine stop dev
    docker-machine rm dev

