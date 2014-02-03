#!/bin/sh

# add following lines to .bashrc/.zshrc
# =-=
## shadowsocks proxy helper functions
#if [ -x ~/bin/lib/proxy_helper.sh ]; then
#    eval "$(~/bin/lib/proxy_helper.sh)"
#fi
# =-=

NAME="shadowsocks"
CONFFILE="$HOME/bin/shadowsocks.config.json"
LOGFILE="/tmp/$NAME.log"
PIDFILE="/tmp/$NAME.pid"
COMMAND=($HOME/.virtualenvs/sandbox/bin/python $HOME/.virtualenvs/sandbox/bin/sslocal -c $CONFFILE)

NETWORK_INTERFACE="Wi-Fi"
PROXY_HOST="127.0.0.1"
PROXY_PORT="3131"

_proxy_pid(){
  cat <<EOF
proxy_pid(){
    if [ ! -r $PIDFILE ]; then
      echo 0
      return
    fi
    local PID=\$(cat $PIDFILE)
    ps -p \$PID | grep -q shadowsocks
    if [ \$? -ne 0 ]; then
      echo 0
      return
    fi
    echo \$PID
  }
EOF
}

cat <<EOF
proxy_system_status(){
  networksetup -getsocksfirewallproxy Wi-Fi
}
proxy_system_enable(){
  sudo networksetup -setsocksfirewallproxy $NETWORK_INTERFACE $PROXY_HOST $PROXY_PORT
  sudo networksetup -setsocksfirewallproxystate $NETWORK_INTERFACE on
  proxy_system_status
}
proxy_system_disable(){
  sudo networksetup -setsocksfirewallproxystate $NETWORK_INTERFACE off
  proxy_system_status | head -n 1
}

proxy_start(){
  nohup ${COMMAND[@]} > $LOGFILE &
  echo \$! > $PIDFILE
  sleep 3
  cat $LOGFILE
}
proxy_status(){
  $(_proxy_pid)
  echo "[INFO] System Proxy Setting - "
  proxy_system_status

  local PID=\$(proxy_pid)
  if [ \$PID -eq 0 ]; then
    echo "[INFO] $NAME is not running." >&2
  else
    echo "[INFO] $NAME is running with pid \$PID." >&2
    tail -f -n 5 $LOGFILE
  fi
}
proxy_stop(){
  $(_proxy_pid)
  local PID=\$(proxy_pid)
  if [ \$PID -eq 0 ]; then
    echo "[INFO] $NAME is not running." >&2
  else
    kill \$PID
    echo "[INFO] stopped $NAME running with pid \$PID." >&2
    tail -n 5 $LOGFILE
  fi
}
proxy_restart(){
  proxy_stop
  proxy_start
}
EOF

