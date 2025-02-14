#! /bin/bash

# run http.server in background
# to serve the installation files..
#tmux new -s createdocker -d "python3 -m http.server"

# The ISE tar file.
#
# Make sure this file or a hard link to it is in the same
# directory as this script.
XILINX_TAR=Xilinx_ISE_DS_14.7_1015_1.tar

# Manage Xilinx license.
#
# First try a file in the current directory, then try to link
# to the default location.
XILINX_LICENSE_NAME="Xilinx.lic"
XILINX_LICENSE_FULL="${HOME}/.Xilinx/$XILINX_LICENSE_NAME"
[[ -f ${XILINX_LICENSE_NAME} ]] || ln "${XILINX_LICENSE_FULL}" . ||
        {
                echo "Error: could not find ${XILINX_LICENSE_NAME}"
                exit 1
        }

# Build the docker image
#
#        --build-arg HOST_HOME="${HOME}" \
#        --build-arg HOST_SERVER=host.docker.internal:8000 \
#        --add-host=host.docker.internal:host-gateway \
docker build \
        --build-arg XILINX_TAR="${XILINX_TAR}" \
        -f Dockerfile \
        -t xilinx_ise \
        .

# close tmux session
#tmux kill-session -t createdocker
