FROM ubuntu:14.04

# Temporary mount point for bind mounts.
ENV TMP_MNT=/tmp/mnt

# Prerequisites
RUN <<EOF
apt-get -qq update
apt-get install -y --install-recommends firefox
apt-get install -y --install-recommends \
    libncurses5 libqt4-core libx11-6 \
    libsm6 libxi6 libgconf-2-4 libxrender1 \
    libxrandr2 libfreetype6 libfontconfig1 \
    libxm4 libxp6 libstdc++5 rpcbind \
    build-essential gcc gcc-multilib \
    lib32z1 libsm-dev libxi-dev libxrender-dev \
    libxrandr-dev libfontconfig-dev dosfstools \
    mtools xinetd wget curl rsync git minicom \
    libtinfo5 libtool bison tmux nano
apt-get -qq -y upgrade
rpcbind
mkdir -p ${TMP_MNT}
EOF

ENV TERM=xterm-256color

#### Don't use dash on Ubuntu
RUN which dash &> /dev/null && (\
    echo "dash dash/sh boolean false" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash) || \
    echo "Skipping dash reconfigure (not applicable)"

#### Install Xilinx
ARG XILINX_TAR

COPY headless-install.sh /

RUN --mount=type=bind,src=${XILINX_TAR},dst=${TMP_MNT}/ise.tar <<EOF
    rm -rf /xilinx
    mkdir -p /xilinx
    cd /xilinx
    tar xvf ${TMP_MNT}/ise.tar
    yes | /xilinx/*/bin/lin64/batchxsetup --batch /headless-install.sh
    cd /
    rm -rf /xilinx
EOF

RUN <<EOF
    mv /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6 /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6.distrib
    mv /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6.0.8 /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6.0.8.distrib
    ln /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6
    ln /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.19 /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6.0.19
    ln -s /usr/lib/x86_64-linux-gnu/libXpm.so.4 /lib/x86_64-linux-gnu/libXp.so.6
EOF
# ENV LD_LIBRARY_PATH=/lib:/lib64:/usr/lib:/usr/lib64

ENV GUEST_USER=xilinx
ENV GUEST_HOME=/home/${GUEST_USER}
ENV UID_GID=1000

RUN groupadd -g ${UID_GID} ${GUEST_USER}
RUN useradd -d ${GUEST_HOME} -s /bin/bash -m ${GUEST_USER} -u ${UID_GID} -g ${UID_GID}

# Copy the license file
RUN --mount=type=bind,src=Xilinx.lic,dst=${TMP_MNT}/Xilinx.lic <<EOF
    mkdir -p ${GUEST_HOME}/.Xilinx
    cp ${TMP_MNT}/Xilinx.lic ${GUEST_HOME}/.Xilinx/Xilinx.lic
EOF

RUN chown -hR ${GUEST_USER}:${GUEST_USER} ${GUEST_HOME}

RUN <<EOF
    apt update
    apt install -y sudo apt-utils locales
    locale-gen en_US.UTF-8
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
EOF

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

USER ${GUEST_USER}
WORKDIR ${GUEST_HOME}
ENV HOME=${GUEST_HOME}
SHELL ["/bin/bash", "-c"]
CMD source /opt/Xilinx/14.7/ISE_DS/settings64.sh && ise
