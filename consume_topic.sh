# Consume Kafka Topic

# You must have the Confluent CLI installed and configured. 
./check_confluent_cli.sh || exit 1

# Configuration
: "${CLUSTER_ID:=lkc-7p0wzp}" # Set this to your cluster ID
: "${TOPIC:=batched_scans}" 

confluent kafka topic consume $TOPIC --cluster $CLUSTER_ID 

