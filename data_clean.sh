#!/bin/bash

# Load environment variables
set -a
source .env
set +a

# List of index patterns to delete
INDICES_TO_DELETE=(
  "filebeat-*"
  "metricbeat-*"
  "logstash-*"
  "packetbeat-*"
  "winlogbeat-*"
  "heartbeat-*"
)

# Validate password is set
if [ -z "$ELASTIC_PASSWORD" ]; then
  echo "Error: ELASTIC_PASSWORD is not set in .env file"
  exit 1
fi

# Delete specified indices
for index in "${INDICES_TO_DELETE[@]}"; do
  echo "Deleting index pattern: $index"
  curl -X DELETE "http://localhost:9200/$index" \
    -u "elastic:$ELASTIC_PASSWORD" \
    -H "Content-Type: application/json"
done

# Optional: Perform index cleanup
curl -X POST "http://localhost:9200/_delete_by_query" \
  -u "elastic:$ELASTIC_PASSWORD" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "except": [
          {"match": {"type": "security"}},
          {"match": {"type": "fleet"}},
          {"match": {"type": "apm"}}
        ]
      }
    }
  }'