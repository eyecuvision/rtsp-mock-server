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