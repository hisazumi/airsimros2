# ------------ ベースとなるイメージファイル
# Assume that the platform is linux/amd64. aarch64/arm64 may not work.
FROM osrf/ros:humble-desktop-full

# ------------ 環境設定
ENV DISPLAY host.docker.internal:0.0
ENV DEBIAN_FRONTEND=noninteractive

# ------------ タイムゾーンの設定
RUN apt-get update && apt-get install -y tzdata
ENV TZ=Asia/Tokyo 

# ------------ ワークディレクトリの設定
WORKDIR /root

# ------------ Ubuntu上での環境構築
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
        python3 python3-pip \
# windows上でx-serverに接続するために必要なx11-appsのインストール
        x11-apps \
# gitのインストール（20.04以降はデフォルトでインストールされていない）
        git \
# matplotlibなどでの描画GUIに必要
        python3-tk \
# ArduPilot related
	sudo lsb-release \
# ROS2
        curl gnupg \        
# BridgePoint
        openjdk-11-jdk openjdk-17-jdk unzip

#RUN bash -c unzip /workspaces/rc/org.xtuml.bp.product-linux.gtk.$(dpkg --print-architecture).*.zip

# ------------ ROS2のセットアップ
# COPY setup.sh /root/
# RUN bash ~/setup.sh
RUN apt-get install -y \
        ros-humble-tf2-sensor-msgs \
        ros-humble-tf2-geometry-msgs \
        ros-humble-mavros \
        ros-humble-mavros-msgs \
        ros-humble-geographic-msgs \
        libyaml-cpp-dev

# ------------ Ardupilotのセットアップ
RUN echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.bashrc
RUN git clone https://github.com/ArduPilot/ardupilot.git ardupilot \
        && cd ardupilot && git submodule update --init --recursive

RUN USER=nobody EUID=nobody ardupilot/Tools/environment_install/install-prereqs-ubuntu.sh -y -q

#RUN cd ardupilot \
#        && ./waf distclean \
#        && ./waf configure --board sitl \
#        && ./waf copter \
#        && ./waf rover \
#        && ./waf plane \
#        && ./waf sub


EXPOSE 5760/tcp
EXPOSE 9003/udp

# ------------ cleanup
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*
