#!/bin/bash

sname="mdt.initd.sh"
spath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
rpath=$(dirname $(dirname $spath))

cat <<EOF > /etc/init.d/$sname
#!/bin/sh

### BEGIN INIT INFO
# Provides:          start.sh
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO


# Carry out specific functions when asked to by the system
case "\$1" in
  start)
    echo "Starting mdt services"
    $rpath/start.sh
    ;;
  stop)
    echo "Stopping mdt services"
    $rpath/stop.sh
    ;;
  status)
    $rpath/status.sh
    ;;
  *)
    echo "Usage: /etc/init.d/$sname {start|stop|status}"
    exit 1
    ;;
esac

exit 0
EOF


ln -s /etc/init.d/$sname /usr/bin/mdt
chmod +x /etc/init.d/$sname
update-rc.d $sname defaults
/etc/init.d/$sname start

echo ""
echo "mdt cli wrapper installed!!"
echo ""
exit 0
