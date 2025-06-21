FROM alpine:latest

ARG ps4_ip
ARG killgame
ARG continue
ENV PYTHONUNBUFFERED=1

RUN apk update
RUN apk add --no-cache bash git wget python3 && ln -sf python3 /usr/bin/python

WORKDIR /opt
RUN wget https://raw.githubusercontent.com/BenNoxXD/PS4-lua-loader/refs/heads/main/install.sh 
RUN chmod +x install.sh 
RUN bash install.sh -ps4_ip=$ps4_ip -docker=on -killgame=$killgame -continue=$continue

RUN chmod +x /opt/PS4-lua-loader/run.sh
RUN rm /opt/install.sh

CMD ["bash", "/opt/PS4-lua-loader/run.sh"]
