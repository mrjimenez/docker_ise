#!/bin/bash

#DISPLAY=$(ifconfig br0 | awk '/inet / {print $6}'):0
#echo "$DISPLAY"

# Set XAUTHORITY, if not set
XAUTHORITY="${XAUTHORITY:-${HOME}/.Xauthority}"
#echo "$XAUTHORITY"

docker run \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v "$XAUTHORITY":/home/xilinx/.Xauthority:ro \
        -v "$HOME":/home/xilinx/shared \
        -v "$HOME"/.config/Xilinx:/home/xilinx/.config/Xilinx \
        -v /etc/localtime:/etc/localtime:ro \
        -e QT_X11_NO_MITSHM=1 \
        -e DISPLAY="$DISPLAY" \
        -it \
        --rm \
        --name docker_ise \
        --net=host --ipc=host \
        xilinx_ise
#bash
