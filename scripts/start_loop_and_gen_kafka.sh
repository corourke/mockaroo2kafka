# Start up one dynamic script and one static generator

: "${TOPIC:=batched_scans}" 
: "${DATA_DIR:=/tmp/datagen/$TOPIC}"

STATUS_FILE=$DATA_DIR/.status
echo "EPOCH" `date` > $STATUS_FILE




SLEEP=2350 THREAD=1 ./gen_mocks_to_kafka.sh &

SLEEP=600 THREAD=2 ./loop_static_to_kafka.sh &

