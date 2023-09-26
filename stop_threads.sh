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
