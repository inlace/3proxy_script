#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Update the package list
apt-get update

# Install required dependencies
apt-get install -y build-essential git libssl-dev

# Clone the 3proxy repository
git clone https://github.com/z3APA3A/3proxy.git

# Change the working directory
cd 3proxy

# Compile and install 3proxy
make -f Makefile.Linux
make -f Makefile.Linux install

# Create a minimal configuration file
mkdir -p /etc/3proxy
echo "nserver 8.8.8.8
nserver 8.8.4.4
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
daemon
pidfile /var/run/3proxy/3proxy.pid
config /etc/3proxy/3proxy.cfg
monitor /etc/3proxy/3proxy.cfg
log /var/log/3proxy/3proxy.log D
logformat \"- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T\"
archiver gz /usr/bin/gzip %F
rotate 30
socks -p1080" > /etc/3proxy/3proxy.cfg

# Generate 10 random usernames and passwords
for i in {1..10}; do
  user="user$i"
  pass=$(openssl rand -base64 12)
  echo "users $user:CL:$pass" >> /etc/3proxy/3proxy.cfg
done

# Create directories for pidfile and log
mkdir -p /var/run/3proxy
mkdir -p /var/log/3proxy

# Create a systemd service file
cat > /etc/systemd/system/3proxy.service << EOL
[Unit]
Description=3proxy Proxy Server
After=network.target
[Service]
Type=forking
PIDFile=/var/run/3proxy/3proxy.pid
ExecStart=/usr/local/bin/3proxy /etc/3proxy/3proxy.cfg
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOL

# Enable and start the 3proxy service
systemctl daemon-reload
systemctl enable 3proxy
systemctl start 3proxy

echo "3proxy installation complete."
