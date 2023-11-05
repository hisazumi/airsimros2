# ------------ ベースとなるイメージファイル
# FROM nvidia/cuda:11.7.0-devel-ubuntu22.04
FROM ubuntu:22.04

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
# ------------ BridgePoint
        openjdk-11-jdk openjdk-17-jdk unzip
RUN bash -c unzip /workspaces/rc/org.xtuml.bp.product-linux.gtk.$(dpkg --print-architecture).*.zip

# ------------ ROS2のセットアップ
COPY setup.sh /root/
RUN bash ~/setup.sh

# ------------ cleanup
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*
