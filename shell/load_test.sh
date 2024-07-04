#!/bin/bash

# Number of concurrent requests
CONCURRENCY=10

# Number of total requests
TOTAL_REQUESTS=100

# Function to call the API
call_api() {
  ./call_api.sh
}

export -f call_api

# Use seq to generate the number of requests and xargs to run them in parallel
seq $TOTAL_REQUESTS | xargs -n1 -P$CONCURRENCY bash -c 'call_api'
