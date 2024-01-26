# Stops all the data generator threads

: "${TOPIC:=batched_scans}" 
: "${DATA_DIR:=/tmp/datagen/$TOPIC}"

STATUS_FILE=$DATA_DIR/.status

if [ ! -f $STATUS_FILE ]; then
  echo "Can't find the status file"
  exit 1
fi

# A 'STOP' anywhere in the status file causes all threads to stop
echo "STOP" `date` >> $STATUS_FILE

# This will terminate the sleep commands
echo "attempting to kill sleep processes (can take a while)..."
parent_pids=$(lsof | grep 'gen_mocks_to_kafka.sh\|loop_static_to_kafka.sh' | awk '{print $2}')
sleep_pids=""
for pid in $parent_pids; do
    sleep_pids+=" $(ps -eo pid,ppid,command | grep 'sleep' | awk -v ppid=$pid '$2==ppid {print $1}')"
done
if [ "$sleep_pids" != "" ]; then
  echo "killing sleep processes... " $sleep_pids
  kill $sleep_pids
fi


