#!/bin/bash

# https://www.daskeyboard.io/q-api-quick-start/
BACKEND_URL="http://localhost:27301"
HEADERS=(-H "Content-Type: application/json")
URL="$BACKEND_URL/api/1.0/signals"

# Example
#curl "${HEADERS[@]}" -X POST -d  '{
#  "zoneId": "KEY_Q",
#  "color": "#FF0000",
#  "effect": "SET_COLOR",
#  "pid": "DK5QPID",
#  "clientName": "Shell script",
#  "message": "Q App version 3 is available. Download it at https://www.daskeyboard.io/get-started/download/",
#  "name": "New Q app version available"}' $URL

# This will return a signal ID and you can use that later to revert the key color.
# Signals from localhost will always be negative.

# Just Set Q key to Red
# This will return a signal ID and you can use that later to revert the key color.
# Signals from localhost will always be negative.

#curl "${HEADERS[@]}" -X POST -d  '{
#  "zoneId": "KEY_Q",
#  "color": "#FF0000",
#  "effect": "SET_COLOR",
#  "pid": "DK5QPID",
#  "clientName": "Shell script"}' $URL

# Delete previously sent signal to revert key color.
SIGNAL_ID="-7930529"
URL="$BACKEND_URL/api/1.0/signals/$SIGNAL_ID"
curl "${HEADERS[@]}" -X DELETE $URL

# Get all shadows
#BACKEND_URL="http://localhost:27301"
#HEADERS=(-H "Content-Type: application/json")
#URL="$BACKEND_URL/api/1.0/signals/shadows"
#curl "${HEADERS[@]}" -X GET $URL
