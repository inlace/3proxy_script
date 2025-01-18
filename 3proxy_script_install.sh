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
echo "# Specify valid name servers. You can locate them on your VPS in /etc/resolv.conf
#
nserver 8.8.8.8
nserver 8.8.4.4
nserver 1.1.1.1
nserver 1.0.0.1
#Leave default cache size for DNS requests:
#
nscache 65536
#Leave default timeout as well:
#
timeouts 1 5 30 60 180 1800 15 60
#If your server has several IP-addresses, you need to provide an external one
#Alternatively, you may ignore this line
#external YOURSERVERIP
#If you ignore this line, proxy will listen all the server's IP-addresses
#internal YOURSERVERIP
#Create users proxyuser1 and proxyuser2 and specify a password
#
#Specify daemon as a start mode
#
daemon

#added authentication caching to make life easier
authcache user 60

# Start new ACLs
#enable strong authorization. To disable authentication, simply change to 'auth none'
auth strong cache
#restrict access for ports via http(s)-proxy and deny access to local interfaces
deny * * 127.0.0.0/8,192.168.1.1
allow * * * 80-88,8080-8088 HTTP
allow * * * 443,8443 HTTPS
# allow SOCKS connection to all ports
allow * * * 1-65535 CONNECT
allow * * * 1-65535 HTTPS

#HTTP Proxy
# Use default ACLs, don't need to flush
proxy -n -p56952 -a

#SOCKS
flush
auth strong cache
socks -p49587

#Enable admin web-ui on specified port, only allow connection from loopback interface (127.0/8) & intranet's admin user (10/8)
#flush
#auth iponly strong cache
#allow * * 127.0.0.0/8
#allow admin * 10.0.0.0/8
#admin -p2525
" > /etc/3proxy/3proxy.cfg

# Generate 10 random usernames and passwords
for i in {1..2}; do
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
