# Xilinx ISE docker image <!-- omit in toc -->

- [1. What is this](#1-what-is-this)
- [2. How to use it](#2-how-to-use-it)

## 1. What is this

This is a docker image of the Xilinx ISE environment. It runs on an old Ubuntu 14:04 virtual environment and does some virtual maps to ensure a natural usage. The GUI uses X11 to display on the host screen, so it just works as if natively ran.

Host path              | Guest path                  | Flag
-----------------------|-----------------------------|------
/tmp/.X11-unix         | /tmp/.X11-unix              |
"$XAUTHORITY"          | /home/xilinx/.Xauthority    | ro
/etc/localtime         | /etc/localtime              | ro
"$HOME"                | /home/xilinx/shared         |
"$HOME"/.config/Xilinx | /home/xilinx/.config/Xilinx |

The folder `~/.config/.Xilinx/` is used to store Xilinx configuration files in the host and in the guest systems, as normal. On the guest, the folder `/home/xilinx/shared` gives you access to your host's home folder.

## 2. How to use it

```bash
# On the first time, you have to create the docker image
./create_image.sh
# After that, just run this command to start ISE
./run_container.sh
```
