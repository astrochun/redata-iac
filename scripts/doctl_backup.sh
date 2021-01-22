#!/bin/bash
# To execute: ./doctl_backup.sh <token> <volume_name>

# A invalid format error occurs with bash v5.0, but not v4.4
printf -v yyyymmdd_date '%(%Y%m%d)T' -1
printf -v dash_date '%(%Y-%m-%d)T' -1

doctl_token=$1
volume_name=$2

# Retrieve volume_id
volume_id=$(doctl compute volume list -t "$doctl_token" | grep "$volume_name" | awk '{print $1}')

# Retrieve list
doctl compute snapshot list --resource volume -t "$doctl_token" >> doctl_snapshot_list.txt

snapshot_name="$volume_name"_"$yyyymmdd_date"

# Take snapshot
doctl compute volume snapshot "$volume_id" --snapshot-name "$snapshot_name" \
      --snapshot-desc "doctl $dash_date" -tag "backup" -t "$doctl_token"
