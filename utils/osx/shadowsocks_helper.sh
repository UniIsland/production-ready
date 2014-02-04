#!/bin/sh

## TODO: completion

# add following lines to .bashrc/.zshrc
# =-=
## shadowsocks proxy helper functions
#if [ -x ~/bin/lib/proxy_helper.sh ]; then
#    eval "$(~/bin/lib/proxy_helper.sh)"
#fi
# =-=

NAME="shadowsocks"
VENVPATH="$HOME/.virtualenvs/sandbox/bin"
CONFFILE="$HOME/bin/lib/$NAME.config.json"
LOGFILE="/tmp/$NAME.log"
PIDFILE="/tmp/$NAME.pid"
COMMAND=($VENVPATH/python $VENVPATH/sslocal -c $CONFFILE)

NETWORK_INTERFACE="Wi-Fi"
PROXY_HOST="127.0.0.1"
PROXY_PORT="3131"

cat <<EOF
shadowsocks(){
  case \$1 in
  system_proxy_status)
    echo "[INFO] System Proxy Setting:"
    networksetup -getsocksfirewallproxy $NETWORK_INTERFACE | awk '{print "  \$0"}'
  ;;
  system_proxy_enable)
    sudo networksetup -setsocksfirewallproxy $NETWORK_INTERFACE $PROXY_HOST $PROXY_PORT
    sudo networksetup -setsocksfirewallproxystate $NETWORK_INTERFACE on
    shadowsocks system_proxy_status
  ;;
  system_proxy_disable)
    sudo networksetup -setsocksfirewallproxystate $NETWORK_INTERFACE off
    proxy_system_status | head -n 2
  ;;
  _pid)
    if [ ! -r $PIDFILE ]; then
      echo 0
      return
    fi
    local PID=\$(cat $PIDFILE)
    ps -p \$PID | grep -q $NAME
    if [ \$? -ne 0 ]; then
      echo 0
      return
    fi
    echo \$PID
  ;;
  status)
    shadowsocks system_proxy_status

    local PID=\$(shadowsocks _pid)
    local ARG="-f"
    [ \$2 -eq "-s" ] && ARG=""
    if [ \$PID -eq 0 ]; then
      echo "[INFO] $NAME is not running."
    else
      echo "[INFO] $NAME is running with pid \$PID."
      echo "(press Ctrl-C to exit.)"
      tail -n 5 \$ARG $LOGFILE
    fi
  ;;
  start)
    nohup ${COMMAND[@]} > $LOGFILE &
    echo \$! > $PIDFILE
    if [ \$? -eq 0 ]; then
      echo "[INFO] $NAME is running with pid \$PID."
      sleep 3
      cat $LOGFILE
    else
      echo "[ERR] failed to start $NAME." >&2
    fi
  ;;
  stop)
    local PID=\$(shadowsocks _pid)
    if [ \$PID -eq 0 ]; then
      echo "[INFO] $NAME is not running."
    else
      kill \$PID
      echo "[INFO] stopped $NAME running with pid \$PID."
      #tail -n 5 $LOGFILE
    fi
  ;;
  restart)
    shadowsocks stop
    shadowsocks start
  ;;
  *)
    shadowsocks status -s
    echo "Usage: shadowsocks status|start|stop|restart"
    echo "       shadowsocks system_proxy_(status|enable|disable)"
  ;;
  esac
}
EOF
