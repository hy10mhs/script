#!/bin/bash

URL="http://your_api_endpoint/hello"

curl -s -o /dev/null -w "%{http_code}" $URL
