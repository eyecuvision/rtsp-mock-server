import netifaces as ni
import ipaddress
from dotenv import dotenv_values

def get_ip_address(iface = "eth0"):
    return ni.ifaddresses(iface)[ni.AF_INET][0]["addr"]


def get_netmask(iface = "eth0"):
    return ni.ifaddresses(iface)[ni.AF_INET][0]["netmask"]

def get_subnet():
    ip_address = get_ip_address()
    netmask = get_netmask()
    net = ipaddress.ip_network(f'{ip_address}/{netmask}', strict=False)

    return str(net)

def parse_env():
    env_config = dotenv_values(".env")
    username = env_config.get("USERNAME","")
    password = env_config.get("PASSWORD","")
    route = env_config.get("ROUTE","/")
    port = int(env_config.get("PORT",554))
    ip_address = env_config.get("IP_ADDRESS",get_ip_address())
    subnet = env_config.get("SUBNET",get_subnet())
    content_name = env_config.get("CONTENT_NAME","test.mp4")

    return {
        "username":username,
        "password":password,
        "route":route,
        "port":port,
        "ip_address":ip_address,
        "subnet":subnet,
        "content_name":content_name
    }