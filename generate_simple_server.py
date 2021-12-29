generate_yaml_content = lambda username,password,route,ip_address,port,content_name,buffer_size=8192 : f"""


logLevel: info
logDestinations: [stdout]
logFile: rtsp-simple-server.log

readTimeout: 10s
writeTimeout: 10s
readBufferCount: {buffer_size}


externalAuthenticationURL:

api: no
apiAddress: 127.0.0.1:9997

metrics: no
metricsAddress: 127.0.0.1:9998

pprof: no
pprofAddress: 127.0.0.1:9999

runOnConnect:
runOnConnectRestart: no

rtspDisable: no
protocols: [udp, multicast, tcp]
# Available values are "no", "strict", "optional".
encryption: "no"
rtspAddress: :{port}
rtspsAddress: :{port+1}
rtpAddress: :8000
rtcpAddress: :8001
multicastIPRange: 224.1.0.0/16
multicastRTPPort: 8002
multicastRTCPPort: 8003

serverKey: server.key
serverCert: server.crt

authMethods: [basic, digest]
readBufferSize: {buffer_size}


rtmpDisable: no
rtmpAddress: :1935


hlsDisable: no
hlsAddress: :8888
hlsAlwaysRemux: no
hlsSegmentCount: 3
hlsSegmentDuration: 1s
hlsAllowOrigin: '*'


paths:
    video:
    
        source: publisher
        sourceProtocol: automatic

        sourceAnyPortEnable: no

        sourceFingerprint:

        sourceOnDemand: no
        sourceOnDemandStartTimeout: 10s
        sourceOnDemandCloseAfter: 10s

        sourceRedirect:

        disablePublisherOverride: no

        fallback:

        publishUser:
        publishPass:
        publishIPs: []

        readUser: {username}
        readPass: {password}
        readIPs: []



        runOnInit: ffmpeg -re -stream_loop -1 -i ./video.mp4 -c copy -f rtsp -rtsp_transport tcp rtsp://{ip_address}:{port}{route}
        runOnInitRestart: yes

        runOnDemand:
        runOnDemandRestart: no
        runOnDemandStartTimeout: 10s
        runOnDemandCloseAfter: 10s

        runOnPublish:
        runOnPublishRestart: no

        runOnRead:
        runOnReadRestart: no
"""



if __name__ == "__main__":

    from utils import parse_env

    env_config = parse_env()
 
    yaml_content = generate_yaml_content(
      ip_address=env_config["ip_address"],
      port=env_config["port"],
      username=env_config["username"],
      password=env_config["password"],
      route=env_config["route"],
      content_name=env_config["content_name"],
    )


    with open("rtsp-simple-server.yml","w") as fp:
        fp.write(yaml_content)
