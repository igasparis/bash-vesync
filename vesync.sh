#!/bin/bash

function usage() {
  echo "Usage: vesync.sh [-h] [-l] [-u] <username> [-p] <password> [-t] <token> [-i] <id> [-d] <device id> [-a] action"
  echo "Login: vesync.sh -l -u username -p password"
  echo "Turn on: vesync.sh -t token -i id -d device_id -a on"
  echo "Turn off: vesync.sh -t token -i id -d device_id -a off"
  exit 0
}

BASE_URL="https://server1.vesync.com:4007"
LOGIN_PATH="/login"
LOAD_PATH="/loadMain"
ACTION_PATH="/devRequest"

LOGIN="0"
USERNAME=""
PASSWORD=""
TOKEN=""
ID=""
DEVICE_ID=""
ACTION=""

while getopts ":hlu:p:t:i:d:a:" opt; do
  case $opt in
    h) 
      usage
      ;;
    l) 
      LOGIN="1"
      ;;
    i)
      ID=$OPTARG
      ;;
    a)
      ACTION=$OPTARG
      ;;
    u) 
      USERNAME=$OPTARG
      ;;
    p) 
      PASSWORD=$OPTARG
      ;;
    t) 
      TOKEN=$OPTARG
      ;;
    d) 
      DEVICE_ID=$OPTARG
      ;;
    *) 
      usage
      ;;
  esac
done

if [ "$LOGIN" -eq "1" ]; then
  ([[ -z "$PASSWORD" ]] || [[ -z "$USERNAME" ]]) && usage
  json=$(curl -H "password:${PASSWORD}" -H "account:${USERNAME}" -X POST ${BASE_URL}${LOGIN_PATH} --silent)
  TOKEN=$(echo $json | jq -r .tk)
  ID=$(echo $json | jq -r .id) 
  json=$(curl -H "tk:${TOKEN}" -H "id:${ID}" -X POST  ${BASE_URL}$LOAD_PATH --silent)
  DEVICE_ID=$(echo $json | jq -r .devices[].id)
  
  echo "Token:     $TOKEN"
  echo "ID:        $ID"
  echo "DEVICE_ID: $DEVICE_ID"
  exit 0
fi


([[ -z "$TOKEN" ]] || [[ -z "$DEVICE_ID" ]] || [[ -z "$ID" ]] || [[ -z "$ACTION" ]]) && usage
BODY="{\"cid\":\"${DEVICE_ID}\",\"uri\":\"\/relay\",\"action\":";

if [ "$ACTION" == "on" ]; then
  echo "Turning on device: $DEVICE_ID"
  BODY="$BODY\"open\"}";
elif [ "$ACTION" == "off" ]; then
  echo "Turning off device: $DEVICE_ID"
  BODY="$BODY\"break\"}";
fi

curl -H "tk:${TOKEN}" -H "id:${ID}" -d "$BODY" -X POST ${BASE_URL}${ACTION_PATH} --silent > /dev/null
