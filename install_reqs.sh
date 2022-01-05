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
	
	check_if_installed amazon-cloudwatch-agent
	is_cloudwatch_agent_installed=$?
	if [[ is_cloudwatch_agent_installed -eq 0 ]]; then
		wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/arm64/latest/amazon-cloudwatch-agent.deb
		sudo dpkg -i amazon-cloudwatch-agent.deb 
		rm amazon-cloudwatch-agent.deb 
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

install_prereqs
install_docker
python3 -m pip install -r requirements.txt