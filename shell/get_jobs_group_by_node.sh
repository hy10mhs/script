#!/bin/bash

# URL prefix
URL_PREFIX="https://domain.com"

# Check if jq and curl are installed
if ! [ -x "$(command -v jq)" ] || ! [ -x "$(command -v curl)" ]; then
  echo 'Error: jq or curl is not installed. Please install jq (https://stedolan.github.io/jq/download/) and curl.' >&2
  exit 1
fi

# Function to parse JSON from file
parse_json_from_file() {
  local json_file="$1"
  local headers="$2"

  # Example: Extracting 'url' fields from each object in the 'data' array
  urls=$(jq -r '.data[].url' "$json_file")

  # Initialize array to store extracted IP addresses
  extracted_ips=()

  # Loop through each URL
  for url in $urls; do
    full_url="${URL_PREFIX}${url}"

    # Make HTTP request with headers and get response
    echo "Calling URL: $full_url with headers: $headers"
    response=$(curl -s -H "$headers" "$full_url")

    # Example: Extracting IP addresses from response using grep (adjust based on your response structure)
    # Matches IPs in the format 10.211.32.122 or 10-233-112-511
    extracted_ips+=("$(echo "$response" | grep -oE '\b([0-9]{1,3}[-.,]){3}[0-9]{1,3}\b')")
  done

  # Print gathered extracted IP addresses
  echo "Extracted IP Addresses:"
  printf '%s\n' "${extracted_ips[@]}"
}

# Function to parse JSON from parameter
parse_json_from_param() {
  local json_data="$1"
  local headers="$2"

  # Example: Extracting 'url' fields from each object in the 'data' array
  urls=$(jq -r '.data[].url' <<< "$json_data")

  # Initialize array to store extracted IP addresses
  extracted_ips=()

  # Loop through each URL
  for url in $urls; do
    full_url="${URL_PREFIX}${url}"

    # Make HTTP request with headers and get response
    echo "Calling URL: $full_url with headers: $headers"
    response=$(curl -s -H "$headers" "$full_url")

    # Example: Extracting IP addresses from response using grep (adjust based on your response structure)
    # Matches IPs in the format 10.211.32.122 or 10-233-112-511
    extracted_ips+=("$(echo "$response" | grep -oE '\b([0-9]{1,3}[-.,]){3}[0-9]{1,3}\b')")
  done

  # Print gathered extracted IP addresses
  echo "Extracted IP Addresses:"
  printf '%s\n' "${extracted_ips[@]}"
}

# Main script
if [ $# -eq 3 ] && [ "$2" == "-h" ]; then
  headers="$3"

  # Check if the argument is a file
  if [ -f "$1" ]; then
    parse_json_from_file "$1" "$headers"
  else
    parse_json_from_param "$1" "$headers"
  fi
else
  echo "Usage: $0 '<json_file>' -h \"-H 'header1: header1value' -H 'header2: header2value'\" OR '$0 '<json_data>' -h \"-H 'header1: header1value' -H 'header2: header2value'\""
  exit 1
fi

exit 0
