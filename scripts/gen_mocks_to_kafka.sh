# Data Generator - Mockaroo / Kafka version
# Call Mockaroo to get data, and upload it to a Kafka cluster

# You must have the Confluent CLI installed and configured. 
./check_confluent_cli.sh || exit 1

# Configuration
: "${CLUSTER_ID:=lkc-7p0wzp}" # Set this to your cluster ID
: "${TOPIC:=batched_scans}" 
: "${DATA_DIR:=/tmp/datagen/$TOPIC}"
: "${PREFIX:=$TOPIC}"
: "${SLEEP:=2400}" # Time to sleep in between batches

# Non-zero when multiple instances of this script are running
: "${THREAD:=0}" 
# The status file both logs activity and controls script running
STATUS_FILE=$DATA_DIR/.status

# We are running standalone, so create the status file
if [ $THREAD -eq 0 ]; then 
	echo "EPOCH" `date` > $STATUS_FILE
fi

# Prechecks for data directories
if [ ! -d $DATA_DIR ]; then
	echo "Please ensure that $DATA_DIR is writable."
  exit 1
fi
if [ ! -f $STATUS_FILE ]; then
  echo "No status file, which shouldn't be as we are THREAD: " $THREAD
  exit 1
fi
if [ ! -d $DATA_DIR/stage ]; then
  echo "creating $DATA_DIR/stage directory"
  mkdir $DATA_DIR/stage
fi
if [ ! -d $DATA_DIR/processed ]; then
  echo "creating $DATA_DIR/processed directory"
  mkdir $DATA_DIR/processed
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
  # Get new sample data rows
  timestamp=`date "+%s"`
  file_name=${PREFIX}-${THREAD}-${timestamp}.json
  data_file="$DATA_DIR/stage/$file_name"
  rows="$[${RANDOM}%50+10]" # Randomizes the number of rows
  # Replace the mockaroo call with the one given to you by mockaroo
  # Note you can go to 1000 rows and 200 requests/day on mockaroo for free
  curl --silent "https://api.mockaroo.com/api/3d0e46b0?count=${rows}&key=76b93870" > $data_file
  log_message "GENR" $rows $file_name `date`
  data_file=""

  # Upload files generated by this instance (THREAD) to Kafka and archive
  for staged_file in ${DATA_DIR}/stage/${PREFIX}-${THREAD}-*.json
  do
    confluent kafka topic produce $TOPIC --cluster $CLUSTER_ID < $staged_file
    if [ $? -ne 0 ]; then
      log_message "ERR_" $THREAD "Exiting due to upload error" `date`
      log_message "STOP" `date`
      exit;
    fi
    log_message "SENT" $staged_file `date` 
    mv $staged_file $DATA_DIR/processed
  done

  # Check the datetime formula in the mockaroo schema to ensure that it gives you the right
  # timeframe. Ex: this formula produces times within the last 5 minutes
  # (now() - minutes(random(0,4)) - seconds(random(0,59)))
  sleep $SLEEP
done
log_message "EXIT" $THREAD `date`
