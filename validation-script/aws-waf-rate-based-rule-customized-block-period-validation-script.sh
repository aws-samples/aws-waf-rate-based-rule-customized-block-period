#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Please add URL after script name like: $0 <url>"
  exit 1
fi

url=$1

# Send 1000 requests to breach rate based rule limit
for i in {1..1000}; do 
  curl -so /dev/null "$url"; 
  if ((i % 100 == 0)); 
    then echo "Completed $i requests"; 
  fi; 
done


# Start making requests for finding status code and tracking time
counter_started=false
consecutive_403=0
consecutive_200=0
while true; do
  response=$(curl -s -o /dev/null -w "%{http_code}" "$url")

  if [[ $response -eq 403 ]]; then
    consecutive_403=$((consecutive_403+1))
    if [[ $consecutive_403 -eq 3 ]]; then
      if ! $counter_started; then
        start_time=$(date +%s)
        counter_started=true
      fi
    fi
    consecutive_200=0
  elif [[ $response -eq 200 && $counter_started == true ]]; then
    consecutive_200=$((consecutive_200+1))
    if [[ $consecutive_200 -eq 3 ]]; then
      end_time=$(date +%s)
      time_diff=$((end_time - start_time))
      echo "Your IP was blocked for around: $time_diff seconds"
      break
    fi
    consecutive_403=0
  else
    consecutive_403=0
    consecutive_200=0
  fi
   
  echo "$(date +%Y-%m-%d\ %H:%M:%S) HTTP Status Code= $response"
   
  sleep 1
done
