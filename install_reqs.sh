#!/bin/bash

check_if_installed(){
    REQUIRED_PKG=$1
    PKG_OK=$(dpkg-query -W -f='${Status}' $REQUIRED_PKG 2>/dev/null | grep -c "ok installed")
	if [[ $PKG_OK -eq 1 ]]; then
		echo "$REQUIRED_PKG is already installed."
		return 1
	else 
		return 0
	fi
}


install_prereqs(){
	sudo apt-get -y update 
	sudo apt-get -y upgrade 

	sudo apt-get -y install build-essential libssl-dev libffi-dev \
			python3-dev cargo moreutils
	sudo apt-get -y install curl python3-pip python-pip libhdf5-dev libffi-dev python-openssl libssl-dev zlib1g-dev gcc g++ make awscli pv
	sudo -H python3 -m pip install setuptools_rust

	sudo -H python3 -m pip install jetson-stats
	sudo systemctl enable jetson_stats.service
	sudo systemctl start jetson_stats.service
	sudo timedatectl set-timezone UTC

	
	check_if_installed rustc
	is_rust_installed=$?
	if [[ is_rust_installed -eq 0 ]]; then
		#Non interactive rust install
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	fi
	
}

install_docker(){
	
	check_if_installed docker-compose
	is_docker_compose_installed=$?
	if [[ is_docker_compose_installed -eq 0 ]]; then
		sudo -H python3 -m pip install docker-compose

		sudo chmod 666 /var/run/docker.sock
		sudo groupadd docker
		sudo usermod -aG docker $USER
		echo "exit" | newgrp docker

		sudo groupadd  docker-compose
		sudo usermod -aG docker-compose $USER
		echo "exit" | newgrp docker-compose
	else
		echo "Docker is installed."
	fi
	
		
}	

install_server(){
	FILEPATH="/etc/systemd/system/rtsp_server.service"
	if [ -z ${WORKING_DIRECTORY} ]; then export 
		WORKING_DIRECTORY="$PWD" 
	else 
		: 
	fi



	DOCKER_PATH=$(which docker)
	DOCKER_COMPOSE_PATH=$(which docker-compose)

	SERVICE_DEFINITION=$"# $FILEPATH
	[Unit]
	Description=rtsp_server.service
	Requires=docker.service network-online.target
	After=docker.service network-online.target
	OnFailure=ward-fallback.service
	[Service]
	Environment='PWD=$WORKING_DIRECTORY'
	Type=oneshot
	RemainAfterExit=yes
	WorkingDirectory=$WORKING_DIRECTORY
	ExecStartPre=$DOCKER_PATH container prune --force
	ExecStart=$DOCKER_COMPOSE_PATH up 
	ExecStop=$DOCKER_COMPOSE_PATH down
	TimeoutStartSec=0
	[Install]
	WantedBy=multi-user.target
	"

	if [[ ERROR_CODE -eq "0" ]]; then
		sudo bash -c "echo \"$SERVICE_DEFINITION\" > $FILEPATH"
		sudo systemctl enable rtsp_server
		echo "Installation succeeded."

	else
		echo "Installation failed."
	fi
}



install_prereqs
install_docker
python3 -m pip install -r requirements.txt