#!/usr/bin/env bash


# ## Update apt, and install some common vm tools
sudo apt-get update -y
sudo apt-get install -y fish unzip


# ## Install kpm
curl -sSL learn.koding.com/kpm.sh | sh


# ## Install ngrok
pushd /tmp
curl -sSL -o ./ngrok.zip \
  "https://api.equinox.io/1/Applications/ap_pJSFC5wQYkAyI0FIVwKYs9h1hW/Updates/Asset/ngrok.zip?os=linux&arch=386&channel=stable"
unzip ./ngrok.zip
chmod +x ./ngrok
sudo mv ./ngrok /usr/local/bin/ngrok
popd

# ## Add ngrok upstart
cat > "/etc/init/ngrok.conf" << EOF
# Ubuntu upstart file at /etc/init/ngrok.conf

description     "Ngrok Tunneling"

start on (klient
          and local-filesystems
          and runlevel [2345])
stop on runlevel [!2345]

script
  ulimit -n 100000
  /usr/local/bin/ngrok -log=stdout 56789 > /var/log/ngrok.klient.log
  cat /var/log/ngrok.klient.log | grep "Tunnel established at" | awk '{print $8}' > /var/log/ngrok.klient.host
end script

respawn
respawn limit 3 10

# give up if I respawn 3 times in 60 seconds...
EOF



# ## Install klient
pushd /tmp
curl -sLO https://s3.amazonaws.com/koding-klient/install.sh
bash ./install.sh
popd



# ## Add ngrok customized klient upstart
cat > /etc/init/klient.conf << EOF
# Ubuntu upstart file at /etc/init/klient.conf
# After putting it into /etc/init do the following for initialization:
#
#   initctl reload-configuration
#   initctl list
#
# you should see klient in the list, if not you upstart script is wrong. After that start it:
#
#   start klient
#
# log is stored into local syslog and /var/log/klient.log

description     "Koding Klient"

start on (net-device-up
          and local-filesystems
          and runlevel [2345])
stop on runlevel [!2345]

env KITE_HOME=/etc/kite
env KITE_LOG_NOCOLOR=true

script
  ulimit -n 100000
  ngrokAddress=`cat /var/log/ngrok.klient.host`
  cd /opt/kite/klient
  ./klient -kontrol-url https://koding.com/kontrol/kite -env managed -register-url "\$ngrokAddress/kite"
end script

respawn
respawn limit 3 10

# give up if I respawn 3 times in 60 seconds...
EOF
