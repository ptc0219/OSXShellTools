#!/bin/bash

PROXY_PORT=9999
SSH_HOST="user@remote"
SSH_PORT=22

if [[ -n "$1" && "$1" == "on" ]]; then
    curl http://localhost:$PROXY_PORT > /dev/null 2>&1
    ret=$(echo $?);
    if [[ "$ret" == "52" ]]; then
        pids=$(ps aux | grep -E "ssh.*-D.*$PROXY_PORT" | grep -vi grep | awk '{print $2}')
        for i in $pids
        do
            sudo kill -9 $i > /dev/null 2>&1
        done
        echo "Killing pervious SSH Tunnel proccesses..."
    fi
    ssh -p $SSH_PORT $SSH_HOST -N -D $PROXY_PORT &
    echo $! > /tmp/ssh_tunnel.pid
    sudo networksetup -setsocksfirewallproxy Wi-Fi localhost $PROXY_PORT;
    echo "SSH Tunnel Started Successful"
elif [[ -n "$1" && "$1" == "off" ]]; then
    if [[ -f /tmp/ssh_tunnel.pid ]]; then
        pid=$(cat /tmp/ssh_tunnel.pid);
        sudo kill -9 "$pid" > /dev/null 2>&1
        sudo rm /tmp/ssh_tunnel.pid > /dev/null 2>&1
    else
        pids=$(ps aux | grep -E "ssh.*-D.*$PROXY_PORT" | grep -vi grep | awk '{print $2}')
        for i in $pids
        do
            sudo kill -9 $i > /dev/null 2>&1
        done
        echo "Killing all SSH Tunnel proccesses..."
    fi
    sudo networksetup -setsocksfirewallproxy Wi-Fi "" "";
    sudo networksetup -setsocksfirewallproxystate Wi-Fi off;
    echo "SSH Tunnel Stopped Successful"
elif [[ -n "$1" && "$1" == "status" ]]; then
    count=$(ps aux | grep -E "ssh.*-D.*$PROXY_PORT" | grep -vi grep | awk '{print $2}'|wc -l)
    if [[ $count -gt 0 ]]; then
        echo -e "SSH Tunnel: \033[1;36mEstablished\033[m"
        res=$(sudo networksetup -getsocksfirewallproxy Wi-Fi | tr -d ' ')
        for i in $res
        do
            key=$(echo $i | awk -F ":" '{print $1}');
            val=$(echo $i | awk -F ":" '{print $2}');
            echo -e "$key: \033[1;36m$val\033[m"
        done
    else
        echo -e "SSH Tunnel: \033[1;31mDisconnected\033[m"
        res=$(sudo networksetup -getsocksfirewallproxy Wi-Fi | tr -d ' ')
        for i in $res
        do
            key=$(echo $i | awk -F ":" '{print $1}');
            val=$(echo $i | awk -F ":" '{print $2}');
            echo -e "$key: \033[1;31m$val\033[m"
        done
    fi
else
    echo "$0 {on|off|status}"
fi
