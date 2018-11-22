#!/bin/bash
#
# Usage: start.sh [debug]
#
cd `dirname $0`
BIN_DIR=`pwd`
cd ..
DEPLOY_DIR=`pwd`
CONF_DIR=$DEPLOY_DIR/conf
#SERVER_PORT

DEBUG_MODE=""
SERVER_NAME=`grep -v '^\s*#' conf/application.properties | sed '/application.name/!d;s/.*=//' | tr -d '\r'`
SERVER_PORT=$1
LOGS_DIR="logs"
APPLICATION_LAUNCHER=`sed '/application.launcher/!d;s/.*=//' conf/application.properties | tr -d '\r'`

#while getopts "p:d" opt ;do
#        case opt in
#             p)
#                echo "port's arg:$OPTARG"
#                SERVER_PORT="$OPTARG"
#                ;;
#             d)
#                DEBUG_MODE="debug"
#                ;;
#             ?)
#                #当有不认识的选项的时候arg为?
#                echo "unkonw argument"
#                exit 1
#                 ;;
#        esac
#done

if  [  -n "$SERVER_PORT" ] ;then
	echo "Server_Port is : $SERVER_PORT"
else
    SERVER_PORT=`grep -v '^\s*#' conf/application.properties | sed '/application.port/!d;s/.*=//' | tr -d '\r'`
	if  [  -n "$SERVER_PORT" ] ;then
	    echo "Server_Port is : $SERVER_PORT"
	else
	    SERVER_PORT="8080"
        echo "Use default server port 8080"
    fi
fi

if test -n "/usr/local/program/jdk1.7.0_79"; then
  if test -z "${JAVA_EXE}"; then
    JAVA_EXE=$JAVA_HOME/bin/java
  fi
fi

if test -z "${JAVA_EXE}"; then
  JAVA_EXE=java
fi

${JAVA_EXE} -version >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "ERROR: Not Found java installed!"
  exit 1
fi

PIDS=`ps -ef | grep java | grep "$CONF_DIR" |awk '{print $2}'`
#if [ -n "$PIDS" ]; then
#    echo "ERROR: The $SERVER_NAME already started!"
#    echo "PID: $PIDS"
#    exit 1
#fi

#if [ -n "$SERVER_PORT" ]; then
#    SERVER_PORT_COUNT=`netstat -tln | grep $SERVER_PORT | wc -l`
#    if [ $SERVER_PORT_COUNT -gt 0 ]; then
#        echo "ERROR: The $SERVER_NAME port $SERVER_PORT already used!"
#        exit 1
#    fi
#fi

if [ ! -d $LOGS_DIR ]; then
    mkdir -p $LOGS_DIR
fi
if [ ! -d $LOGS_DIR ]; then
  echo "ERROR: Please check LOGS_DIR=$LOGS_DIR is ok?"
  exit 1
fi
STDOUT_FILE=$LOGS_DIR/console.log

LIB_DIR=$DEPLOY_DIR/lib
#LIB_JARS=`ls $LIB_DIR|grep .jar|awk '{print "'$LIB_DIR'/"$0}'|tr "\n" ":"`
LIB_JARS=$DEPLOY_DIR/lib/*

JAVA_OPTS=" -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true "
JAVA_DEBUG_OPTS=""
if [ "$DEBUG_MODE" = "debug" ]; then
    JAVA_DEBUG_OPTS=" -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=9112,server=y,suspend=n "
fi
JAVA_JMX_OPTS=""
if [ "$DEBUG_MODE" = "jmx" ]; then
    JAVA_JMX_OPTS=" -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false "
fi
JAVA_MEM_OPTS=""
BITS=`${JAVA_EXE} -version 2>&1 | grep -i 64-bit`
if [ -n "$BITS" ]; then
    JAVA_MEM_OPTS=" -server -Xmx2g -Xms2g -Xmn512m -XX:PermSize=128m -Xss256k -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 "
else
    JAVA_MEM_OPTS=" -server -Xms1g -Xmx1g -XX:PermSize=128m -XX:SurvivorRatio=2 -XX:+UseParallelGC "
fi

JAVA_AGENT_OPTS=""
AGENT_LIB=`ls $LIB_DIR | grep sgm-agent* | grep .jar`
if [ -n "$AGENT_LIB" ]; then
    JAVA_AGENT_OPTS=" -Xbootclasspath/a:$LIB_DIR/$AGENT_LIB -javaagent:$LIB_DIR/$AGENT_LIB "
fi

echo "Starting the $SERVER_NAME on $SERVER_PORT"
nohup ${JAVA_EXE} $JAVA_SPRING_OPTS $JAVA_AGENT_OPTS $JAVA_OPTS $JAVA_MEM_OPTS $JAVA_DEBUG_OPTS $JAVA_JMX_OPTS -classpath $CONF_DIR:$LIB_JARS $APPLICATION_LAUNCHER $SERVER_PORT > $STDOUT_FILE 2>&1 &

PIDS=`ps -ef | grep java | grep "$DEPLOY_DIR" | awk '{print $2}'`
echo "Starting with PID[$PIDS]"

COUNT=0
while [ $COUNT -lt 1 ]; do
    sleep 1
    if [ -n "$SERVER_PORT" ]; then
            COUNT=`netstat -an | grep $SERVER_PORT | wc -l`
            echo "netstat check count[$COUNT]"
    else
        COUNT=`ps -ef | grep java | grep "$DEPLOY_DIR" | awk '{print $2}' | wc -l`
        echo "ps check count[$COUNT]"
    fi
    if [ $COUNT -gt 0 ]; then
        break
    fi
done

echo "OK!"
PIDS=`ps -ef | grep java | grep "$DEPLOY_DIR" | awk '{print $2}'`
echo "PID: $PIDS"
echo "STDOUT: $STDOUT_FILE"
