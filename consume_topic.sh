# Consume Kafka Topic

# You must have the Confluent CLI installed and configured. 

# Configuration
: "${CLUSTER_ID:=lkc-7p0wzp}" # Set this to your cluster ID
: "${TOPIC:=pos_scans}" 

# Check that the Confluent CLI is installed
if [[ ( ! -d ~/.confluent ) || ( ! -f ~/.confluent/config.json ) ]]; then
  echo "Confluent Command Line Interface not installed or configured."
  exit 1
fi
set -e

confluent kafka topic consume $TOPIC --cluster $CLUSTER_ID 

