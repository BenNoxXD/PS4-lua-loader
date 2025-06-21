#!/bin/bash

#*
#* Copyright (c) 2025 BenNox_XD
#*
#* This file is part of PS4-lua-loader and is licensed under the MIT License.
#* See the LICENSE file in the root of the project for full license information.
#*

ps4_ip=""
docker="off"
killgame="off" # on/off
continue="shutdown" # shutdown/ping

print_info() {
    echo -e "\033[0;33m$1\033[0m"
}

# Parse command-line arguments
for arg in "$@"; do
    case $arg in
        -killgame=on)
            killgame="on"
            ;;
        -killgame=off)
            killgame="off"
            ;;
        -continue=shutdown)
            continue="shutdown"
            ;;
        -continue=ping)
            continue="ping"
            ;;
        -docker=on)
            docker="on"
            ;;
        -docker=off)
            docker="off"
            ;;
        -ps4_ip=*)
            ps4_ip="${arg#*=}"
            ;;
        -h|--help)
            echo "Usage: ./install.sh -ps4_ip=YOURPS4IP [-killgame=on|off] [-continue=shutdown|ping] [-inject=none|etaHEN|kstuff] [-docker=on|off]"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

# Ensure PS4 IP is set.
if [[ -z "$ps4_ip" ]]; then
    echo "Error: You must specify the PS4 IP Address using -ps4_ip=<YOURPS4IP>"
    echo "Use -h or --help for usage information."
    exit 1
fi

if [[ "$docker" == "off" ]]; then
    ## Start installation
    print_info "Your PS4 IP Address is set to: $ps4_ip"

    # remove old version
    systemctl stop ps4lualoader
    systemctl disable ps4lualoader
    rm /etc/systemd/system/ps4lualoader.service
    rm -rf /opt/PS4-lua-loader
fi

echo $ps4_ip > /tmp/ip.txt
cd /opt
# install new version
git clone https://github.com/BenNoxXD/PS4-lua-loader
cd PS4-lua-loader
mv /tmp/ip.txt /opt/PS4-lua-loader
wget https://raw.githubusercontent.com/shahrilnet/remote_lua_loader/refs/heads/main/payloads/lapse.lua -P scripts
wget https://raw.githubusercontent.com/shahrilnet/remote_lua_loader/refs/heads/main/payloads/send_lua.py
wget https://raw.githubusercontent.com/shahrilnet/remote_lua_loader/refs/heads/main/payloads/bin_loader.lua -P scripts


# create run.sh
cat > /opt/PS4-lua-loader/run.sh <<- "EOF"
#/bin/bash

print_yellow() {
  echo -e "\033[0;33m$1\033[0m"
}

cd /opt/PS4-lua-loader/
EOF

# continue
if [[ "$continue" == "ping" ]]; then
# modify run.sh
cat >> /opt/PS4-lua-loader/run.sh <<- "EOF"
while true
do
EOF
fi


# modify run.sh - exploit & HEN
cat >> /opt/PS4-lua-loader/run.sh <<- "EOF"
goto () {
  python3 test_port.py $(cat ip.txt) 2121 15 close
  python3 test_port.py $(cat ip.txt) 9026 1 open
  sleep .5

  python3 send_lua.py $(cat ip.txt) 9026 scripts/starting.lua

  ## Run Kexploit
  python3 send_lua.py $(cat ip.txt) 9026 scripts/lapse.lua

  ## Success check
  output="$(python3 send_lua.py $(cat ip.txt) 9026 scripts/get_status.lua)"
  if [ -n "$output" ]; then
    print_yellow "Lapse: failure!"
    python3 send_lua.py $(cat ip.txt) 9026 scripts/lapse_failed.lua
    python3 test_port.py $(cat ip.txt) 9026 3 close
    goto
  fi
  print_yellow "Lapse: success!"

  ## Check if HEN exists
  print_yellow "Checking HEN's existence..."
  output="$(python3 send_lua.py $(cat ip.txt) 9026 scripts/check_file_existence.lua)"
  if [ -z "$output" ]; then
    print_yellow "HEN existes!"
    python3 send_lua.py $(cat ip.txt) 9026 scripts/bin_loader.lua
  else
    print_yellow "HEN doesn't exist!"
    python3 send_lua.py $(cat ip.txt) 9026 scripts/no_hen.lua
    python3 test_port.py $(cat ip.txt) 9026 3 close
    goto
  fi
EOF


# killgame
if [[ "$killgame" == "on" ]];
then
cat >> run.sh <<- "EOF"

  ## Kill game
  python3 send_lua.py $(cat ip.txt) 9026 scripts/killgame.lua

EOF
fi

cat >> run.sh <<- "EOF"
  # Ensure that the game is closed, because if 'kill game' is disabled and HEN-VTX is used, the exploit could restart even though the game is still open and jailbroken.
  python3 test_port.py $(cat ip.txt) 9026 5 close
}
goto

sleep 5
EOF
fi

# end while loop or shutdown
if [[ "$continue" == "ping" ]];
then
    echo "done" >> /opt/PS4-lua-loader/run.sh
else
    echo "shutdown now" >> /opt/PS4-lua-loader/run.sh
fi

chmod +x run.sh

if [[ "$docker" == "off" ]];
then
# create a service for autostart
cat > /etc/systemd/system/ps4lualoader.service <<- "EOF"
[Unit]
Description=PS4 lua loader

[Service]
ExecStart=/bin/bash /opt/PS4-lua-loader/run.sh

[Install]
WantedBy=multi-user.target
EOF

# enable the service
systemctl enable ps4lualoader
systemctl start ps4lualoader
print_info "Installation complete!"
fi
