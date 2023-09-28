# Check that the Confluent CLI is installed
if [[ ( ! -d ~/.confluent ) || ( ! -f ~/.confluent/config.json ) ]]; then
  cat << EOF
Confluent Command Line Interface not installed or configured.
See:  https://docs.confluent.io/confluent-cli/current/beginner-cloud.html
TL;DR;
  $ brew install confluentinc/tap/cli
  $ confluent login --save
  $ confluent api-key store --resource <CLUSTER _ID>
  $ confluent api-key use <KAFKA API KEY>
EOF
  exit 1
fi
