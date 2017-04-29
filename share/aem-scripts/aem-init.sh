#!/bin/bash

# Description: A service to add restart functionality to the AEM author application.

# 20170314 Dan: Added timers to the start/stop tasks. Cleaned up the output a bit more.
# 20170223 Dan: Adding some output to make things a little clearer.
# 20170221 Dan: Making this a standard shell script.
# 20170104 Dan: Adding check for the server to be running after start.
# 20161207 Dan: Scripts Birthday

if [ ! -f /etc/sysconfig/aem-config ]; then
    exit 6
fi

. /etc/sysconfig/aem-config

cd $AEMHOME

CQ_PIDFILE=$AEMHOME/conf/cq.pid

if [[ -f $CQ_PIDFILE ]]; then
    AEMPID=`cat $CQ_PIDFILE`
fi

TIMEFORMAT="%E"

# See how we were called.
case "$1" in
  start)
        if [[ -z $AEMPID || `ps -o pid= -p $AEMPID | awk '{print $1}'` != $AEMPID ]]; then
            echo ""
            echo "Starting AEM..."
            echo "-----------------"
            START=$(date +%s)
            su $AEMUSER -c bin/start &

            loop=20
            while [[ `curl -so /dev/null -w '%{response_code}' http://127.0.0.1:4502/libs/granite/core/content/login.html` != 200 && $loop != 0 ]]; do
                ((loop--))
                echo "INFO: AEM is not ready"
                sleep 30
            done

            if [[ `curl -so /dev/null -w '%{response_code}' http://127.0.0.1:4502/libs/granite/core/content/login.html` != 200 ]]; then
                echo ""
                echo "ERROR: AEM appears to not have started correctly."
                echo ""
                exit 1
            fi
            echo "AEM is running."

            END=$(date +%s)
            DIFF=$(($END - $START))
            echo "Starting AEM took $DIFF seconds."
        else
            echo "AEM is already running"
        fi
        ;;
  stop)
        if [[ ! -z $AEMPID ]]; then
            su $AEMUSER -c bin/stop
            echo ""
            echo "Stopping AEM..."
            echo "-----------------"
            START=$(date +%s)

            loop=10
            while [[ `ps -o pid= -p $AEMPID | awk '{print $1}'` = $AEMPID && $loop != 0 ]]; do
                ((loop--))
                if [[ $loop = 0 ]]; then
                    echo "INFO: AEM is not stopping. Trying to kill AEM now."
                    kill $AEMPID
                else
                    echo "INFO: AEM has not stopped."
                fi
                sleep 30
            done
            if [[ `ps -o pid= -p $AEMPID` = $AEMPID ]]; then
                echo ""
                echo "ERROR: Unable to stop AEM"
                echo ""
                exit 1
            else
                rm -f $CQ_PIDFILE
                echo "AEM is stopped."
            fi

            END=$(date +%s)
            DIFF=$(($END - $START))
            echo "Stopping AEM took $DIFF seconds."
        else
            echo "NFO: AEM is not running"
        fi
        ;;
  status)
        bin/status
        ;;
  restart)
        $0 stop
        $0 start
        ;;
  *)
            echo $"Usage: $0 {start|stop|status|restart}"
            exit 2
esac
