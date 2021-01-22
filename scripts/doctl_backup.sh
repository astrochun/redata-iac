#!/bin/bash
# To execute and take snapshot:
#   ./doctl_backup.sh <token> <volume_name> --take
# To delete:
#   ./doctl_backup.sh <token> <volume_name> --delete

# A invalid format error occurs with bash v5.0, but not v4.4
printf -v yyyymmdd_date '%(%Y%m%d)T' -1
printf -v dash_date '%(%Y-%m-%d)T' -1

doctl_token=$1
volume_name=$2

log_file=doctl_snapshot_list.log

# Retrieve volume_id
volume_id=$(doctl compute volume list -t "$doctl_token" | \
           grep "$volume_name" | awk '{print $1}')

# Retrieve list
doctl compute snapshot list --resource volume -t "$doctl_token" >> "$log_file"

snapshot_name="$volume_name"_"$yyyymmdd_date"

# Take snapshot
function TakeSnapshot {
  printf "Taking snapshot of %s called %s" "$volume_id" "$snapshot_name" >> "$log_file"
  doctl compute volume snapshot "$volume_id" --snapshot-name "$snapshot_name" \
        --snapshot-desc "doctl $dash_date" -tag "backup" -t "$doctl_token"
}

# Delete snapshot
function DeleteSnapshot {
  # Need to retrieve oldest snapshot_id
  printf "Retrieving list of previous snapshots for %s" "$volume_name" >> "$log_file"
  snapshot_id=$(doctl compute snapshot list --resource volume -t "$doctl_token" | \
               grep "$volume_name" | tail -1 | awk '{print $1}')
  snapshot_date=$(doctl compute snapshot list --resource volume -t "$doctl_token" | \
               grep "$volume_name" | tail -1 | awk '{print $3}')
  printf "Deleting last one: %s" "$snapshot_id" >> "$log_file"
  printf "Date of: %s" "$snapshot_date" >> "$log_file"
  echo doctl compute snapshot delete "$snapshot_id" -t "$doctl_token"
}

###

if [[ "$ARG_TAKE" = true ]]; then
  TakeSnapshot
fi

if [[ "$ARG_DELETE" = true ]]; then
  DeleteSnapshot
fi
