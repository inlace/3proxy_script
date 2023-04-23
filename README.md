# 3proxy_script_install

This repository contains a Bash script for quickly installing and setting up the [3proxy](https://github.com/3proxy/3proxy) proxy server on Debian-based systems (e.g., Ubuntu). The script configures 3proxy as a SOCKS5 proxy server with basic settings and generates 10 random user accounts for authentication.

## Prerequisites

- A Debian-based Linux distribution (e.g., Ubuntu)
- Root access

## 💻 Installation and Setup

To install and set up 3proxy using the provided script, follow these simple steps:

1. **downlad script:
   `wget https://raw.githubusercontent.com/lindex/3proxy_script/main/3proxy_script_install.sh`

2. **Make the script executable**:
   `chmod +x 3proxy_script_install.sh`

3. **Run the script as root**:
   `sudo ./3proxy_script_install.sh`

4. The script will install the necessary dependencies, compile and install 3proxy, create a configuration file, and set up a systemd service. It will also generate 10 random user accounts and display them at the end of the script execution. 🎉


## Configuration

The configuration file is located at `/etc/3proxy/3proxy.cfg`. You can edit this file to modify the proxy settings, such as changing the listening IP, port, or adding more users for authentication.

To add more users, follow this format in the configuration file:
users username:CL:password

Replace `username` and `password` with the desired username and password.

## Managing the 3proxy Service

The script creates a systemd service for 3proxy. You can manage the service using the following commands:

- Start the service: `sudo systemctl start 3proxy`
- Stop the service: `sudo systemctl stop 3proxy`
- Restart the service: `sudo systemctl restart 3proxy`
- Check the service status: `sudo systemctl status 3proxy`

## Logs

The log files are stored in `/var/log/3proxy`. You can monitor the logs using the `tail` command:


This command will display the log output in real-time.


