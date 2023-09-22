# Start up multiple data generator scripts
# (When we want to really crank up the volume while staying under
#  mockaroo's 1000 row free plan limit)

: "${DATA_DIR:=/tmp/scans}"
: "${THREADS:=5}"
: "${SCRIPT:=./gen_mocks_to_kafka.sh}"

# A 'STOP' anywhere in the status file causes all threads to stop
STATUS_FILE=$DATA_DIR/data_loader_status
echo "EPOCH" `date` > $STATUS_FILE

if [ ! -d $DATA_DIR ]; then
	echo "Please ensure that $DATA_DIR is writable."
  exit 1
fi


cleanup ()
{
  echo "STOP" `date` >> $STATUS_FILE
  exit 0
}

trap cleanup SIGINT SIGTERM

echo "STARTING" ${THREADS} "threads --"  `date` >> $STATUS_FILE
for (( n=1; n<=$THREADS; n++))
do
  DATA_DIR=${DATA_DIR} THREAD=${n} $SCRIPT &
  sleep 10
done
echo " "
