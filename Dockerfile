FROM golang

RUN apt-get update
RUN apt-get -y install ffmpeg python3 python3-pip

RUN ls -a

WORKDIR /usr/src/server
RUN git clone https://github.com/aler9/rtsp-simple-server .
RUN go mod download


COPY ./rtsp-simple-server.yml ./
WORKDIR /var/content
COPY ./video.mp4 ./video.mp4

WORKDIR /usr/src/server
CMD ["stdbuf","-oL","go","run","."]