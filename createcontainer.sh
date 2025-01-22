#! /bin/bash

# run http.server in background
# to serve the installation files..
tmux new -s createdocker -d "python3 -m http.server"

# build docker
docker build --build-arg SERVER_HOST=host.docker.internal:8000 \
        --add-host=host.docker.internal:host-gateway \
        -f Dockerfile -t xilinx_ise .

# close tmux session
tmux kill-session -t createdocker
