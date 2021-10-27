#!/usr/bin/env bash

set -e

. funcs.conf

if [ $(get_version) = "ubuntu" ] || [ $(get_version) = "debian" ]; then
    get_msg "updating environment..."
    (apt-get update && apt-get upgrade -y) >/dev/null 2>&1

    get_msg "installing packages..."
    (apt-get install -y build-essential python3-venv hdparm \
                        python3-pip libssl-dev unzip netcat \
                        python3-dev libffi-dev htop jq nmap \
                        inxi vim git tmux) >/dev/null 2>&1

    get_msg "get golang $(curl -s https://golang.org/VERSION?m=text)"
    install_latest_go

    get_msg "setting paths..."
    [ ! -d "/opt/bsc" ] || rm -rf /opt/bsc && get_clone_repo
    mv geth.service /etc/systemd/system/
    cd /opt/bsc && (make geth) >/dev/null 2>&1

    get_msg "get mainnet $(get_latest_tag)"
    get_latest_release
    unzip -q mainnet.zip && rm -f $_

    get_msg "running node..."
    create_service_geth && sleep 3

    get_msg "installation completed..."

    get_msg "default directory/logs"
    printf "/opt/bsc\n"
    printf "/opt/install.log\n"
    printf "journalctl -fau geth\n"

    get_msg "disclaimer"
    printf "$ systemctl status geth; #status service\n"
    printf "$ systemctl stop geth; #stop service\n"
    printf "$ systemctl start geth; #start service\n"
    printf "$ systemctl restart geth; #restart service\n"
    printf "$ systemctl disable geth; #disable service\n\n"
else
    get_msg "OS not supported..."
    exit 1
fi
