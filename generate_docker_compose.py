generate_docker_compose = lambda ip_address,subnet,port : f"""version: "2.3"

services:
  rtsp_server:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      - RTSP_PROTOCOLS=tcp
    networks:
      lan:
        ipv4_address: {ip_address}
    ports:
      - {port}:8554
      - 1935:1935
      - 8888:8888

    volumes:
      - content:/var/content

volumes:
  content:


networks:
  lan:
    name: lan
    driver: macvlan
    driver_opts:
      parent: eth0 
    ipam:
      config:
        - subnet: {subnet} 

"""

if __name__ == "__main__":


  from utils import parse_env

  env_config = parse_env()


  yaml_content = generate_docker_compose(
      ip_address=env_config["ip_address"],
      subnet=env_config["subnet"],
      port=env_config["port"]
  )

  with open("docker-compose.yml","w") as fp:
      fp.write(yaml_content)
