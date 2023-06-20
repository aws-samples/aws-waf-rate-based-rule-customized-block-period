# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Please add URL after script name like: $0 <url>"
  exit 1
fi

url=$1

counter_started=false
i=1

while true; do
  response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [[ $response -eq 403 && $counter_started == false ]]; then
    start_time=$(date +%s)
    counter_started=true
    echo "Your IP is blocked now"
    echo "$(date +%Y-%m-%d\ %H:%M:%S) HTTP Status Code= $response"
    sleep 3
    break
  fi
  if ((i % 10 == 0)); then 
    echo "Completed $i requests without block"; 
  fi 
  i=$((i+1))
done

while true; do
  response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [[ $response -eq 200 && $counter_started == true ]]; then
    end_time=$(date +%s)
    time_diff=$((end_time - start_time))
    minutes=$(expr $time_diff / 60)
    seconds=$(expr $time_diff % 60)
    echo "Your IP was blocked for around: $minutes minutes $seconds seconds"
    break
  fi
  echo "$(date +%Y-%m-%d\ %H:%M:%S) HTTP Status Code= $response"
  sleep 3
done
