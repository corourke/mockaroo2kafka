
: "${DATA_DIR:=/tmp/scans}"
STATUS_FILE=$DATA_DIR/data_loader_status

if [ ! -f $STATUS_FILE ]; then
  echo "Can't find the status file"
  exit 1
fi

echo "STOP" `date` >> $STATUS_FILE
