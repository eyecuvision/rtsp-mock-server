#!/bin/bash
pip3 install -r requirements.txt
python3 generate_docker_compose.py
python3 generate_simple_server.py
docker-compose build 
