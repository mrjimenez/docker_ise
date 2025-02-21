# Xilinx ISE docker image <!-- omit in toc -->

- [1. What is this](#1-what-is-this)
- [2. How to use it](#2-how-to-use-it)

## 1. What is this

This is a docker image of the Xilinx ISE environment. It runs on an old Ubuntu 14:04 virtual environment and does some virtual maps to ensure a natural usage. The GUI uses X11 to display on the host screen, so it just works as if natively ran.

| Host path              | Guest path                  | Flag |
|------------------------|-----------------------------|:----:|
| /tmp/.X11-unix         | /tmp/.X11-unix              |      |
| "$XAUTHORITY"          | /home/xilinx/.Xauthority    | ro   |
| /etc/localtime         | /etc/localtime              | ro   |
| "$HOME"                | /home/xilinx/shared         |      |
| "$HOME"/.config/Xilinx | /home/xilinx/.config/Xilinx |      |
| "$LICENSE_MAC"         | "01:ab:23:cd:45:ef"         |      |

The folder `~/.config/.Xilinx/` is used to store Xilinx configuration files in the host and in the guest systems, as normal. On the guest, the folder `/home/xilinx/shared` gives you access to your host's home folder.

## 2. How to use it

```bash
# Clone the repo
git clone git@github.com:mrjimenez/docker_ise.git
cd docker_ise

# If you have a license file in ~/.Xilinx/Xilinx.lic, you don't have to do anything.
# Otherwise, copy the license file to this directory.
# cp /some/path/Xilinx.lic .

# Hard link or copy the tar ball. Download it from the Xilinx (now AMD) site.
ln /some/other/path/Xilinx_ISE_DS_14.7_1015_1.tar Xilinx_ISE_DS_14.7_1015_1.tar

# Docker image creation. Do this only on the first time.
./create_image.sh

# After that, just run this command to start ISE
./run_container.sh
```
