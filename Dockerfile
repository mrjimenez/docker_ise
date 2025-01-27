FROM ubuntu:14.04

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
EOF

ENV TERM xterm-256color

#### Don't use dash on Ubuntu

RUN which dash &> /dev/null && (\
    echo "dash dash/sh boolean false" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash) || \
    echo "Skipping dash reconfigure (not applicable)"


#### Install Xilinx

ARG SERVER_HOST
COPY headless-install.sh /

RUN <<EOF
mkdir -p /xilinx
cd /xilinx
echo "Downloading Xilinx_ISE_DS_14.7_1015_1.tar from ${SERVER_HOST}"
wget ${SERVER_HOST}/Xilinx_ISE_DS_14.7_1015_1.tar
tar xvf Xilinx_ISE_DS_14.7_1015_1.tar
yes | /xilinx/Xilinx_ISE_DS_14.7_1015_1/bin/lin64/batchxsetup --batch /headless-install.sh
cd /
rm -rf /xilinx
EOF

# wget ${SERVER_HOST}/Xilinx_ISE_DS_14.7_1015_1.tar 
# cd /xilinx
# tar xvf Xilinx_ISE_DS_14.7_1015_1.tar
# curl ${SERVER_HOST}/Xilinx_ISE_DS_14.7_1015_1.tar -o /xilinx/Xilinx_ISE_DS_14.7_1015_1.tar

#ADD Xilinx_ISE_DS_14.7_1015_1.tar /xilinx
#RUN yes | /xilinx/Xilinx_ISE_DS_14.7_1015_1/bin/lin64/batchxsetup --batch /headless-install.sh
#RUN rm /bin/sh && ln -s /bin/bash /bin/sh
#RUN rm -rf /xilinx

RUN <<EOF
mv /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6 /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6.distrib
mv /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6.0.8 /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6.0.8.distrib
ln /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6
ln /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.19 /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libstdc++.so.6.0.19
ln -s /usr/lib/x86_64-linux-gnu/libXpm.so.4 /lib/x86_64-linux-gnu/libXp.so.6
EOF
# ENV LD_LIBRARY_PATH /lib:/lib64:/usr/lib:/usr/lib64

ENV THE_USER xilinx
ENV UID_GID 1000

RUN groupadd -g ${UID_GID} ${THE_USER}
RUN useradd -d /home/${THE_USER} -s /bin/bash -m ${THE_USER} -u ${UID_GID} -g ${UID_GID}

ADD Xilinx.lic /home/${THE_USER}/.Xilinx/

COPY <<EOF /home/${THE_USER}/.config/Xilinx/ISE.conf 
[14.7]
Project%20Navigator/TipOfDay/ShowTipAtStartUp=false
ECS/Settings/ISETEXTEDITOR="bUseSpace=true;bShowWhitespace=false;bShowEol=false;bShowIndent=false;bUseBlackColorScheme=false;tabWidth=4;font=Courier,12,-1,5,50,0,0,0,0,0;longLinesLimit=80;bShowLineNumbers=true;bShowOutline=false;"
EOF

RUN chown -hR ${THE_USER}:${THE_USER} /home/${THE_USER}

RUN <<EOF
apt update
apt install -y sudo apt-utils locales
locale-gen en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
EOF

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

USER ${THE_USER}
WORKDIR /home/${THE_USER}
ENV HOME /home/${THE_USER}
SHELL ["/bin/bash", "-c"]
CMD source /opt/Xilinx/14.7/ISE_DS/settings64.sh && ise
