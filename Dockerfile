FROM golang

RUN apt-get update
RUN apt-get -y install ffmpeg python3 python3-pip

RUN ls -a

WORKDIR /usr/src/server
RUN git clone https://github.com/aler9/rtsp-simple-server .
RUN go mod download

COPY ./video.mp4 ./
COPY ./rtsp-simple-server.yml ./

CMD ["stdbuf","-oL","go","run","."]