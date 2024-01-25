# Data Generator - Static Files / Kafka version
# Send set of static files to Kafka cluster

# You must have the Confluent CLI installed and configured. 
./check_confluent_cli.sh || exit 1

# Configuration
: "${CLUSTER_ID:=lkc-7p0wzp}" # Set this to your cluster ID
: "${TOPIC:=batched_scans}" 
: "${DATA_DIR:=/tmp/datagen/$TOPIC}"
: "${PREFIX:=$TOPIC}"
: "${SLEEP:=600}" # Time to sleep in between batches

# Non-zero when multiple instances of this script are running
: "${THREAD:=0}" 
# The status file both logs activity and controls script running
STATUS_FILE=$DATA_DIR/.status


# Prechecks for data directories
if [ ! -d $DATA_DIR/static ]; then
	echo "Please create ${DATA_DIR}/static directory."
  exit 1
fi
if [ `ls $DATA_DIR/static/*.json | wc -l ` -eq 0 ]; then
  echo "Populate the ${DATA_DIR}/static directory with sample files."
  exit 1
fi
# If THREAD is 0, means we are not running multiple instances
# We are running standalone, so create the status file
if [ $THREAD -eq 0 ]; then 
	echo "EPOCH" `date` > $STATUS_FILE
fi
if [ ! -f $STATUS_FILE ]; then
  echo "No status file, which shouldn't be as we are THREAD: " $THREAD
  exit 1
fi

# Function to print to console and status file
log_message () {
  echo $*
  echo $* >> $STATUS_FILE
}

# When user wants to exit, shut down gracefully
cleanup ()
{
  # This will cause any other threads to stop
  log_message "STOP" `date`
  rm -f $data_file # clean up partial download
  exit 0
}
trap cleanup SIGINT SIGTERM
log_message "START" $THREAD `date`

# Create and upload files until told to stop
while [ `grep -c "^STOP" $STATUS_FILE` -eq 0 ] 
do
  # Upload files to Kafka and wait
  for staged_file in ${DATA_DIR}/static/*.json
  do
    confluent kafka topic produce $TOPIC --cluster $CLUSTER_ID < $staged_file
    if [ $? -ne 0 ]; then
      log_message "ERR_" $THREAD "Exiting due to upload error" `date`
      exit;
    fi
    log_message "SENT" $staged_file `date` 
    sleep $SLEEP
    if [ `grep -c "^STOP" $STATUS_FILE` -ne 0 ] ; then break; fi
  done
done
log_message "EXIT" $THREAD `date`
