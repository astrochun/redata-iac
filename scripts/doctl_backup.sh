#!/bin/bash
# To execute and take snapshot:
#   ./doctl_backup.sh <volume_name> --take (uses doctl auth stored)
#   ./doctl_backup.sh <volume_name> <token> --take (uses specified token)
# To delete:
#   ./doctl_backup.sh <volume_name> --delete (uses doctl auth stored)
#   ./doctl_backup.sh <volume_name> <token> --delete (uses specified token)

log_file=doctl_snapshot_list.log

# A invalid format error occurs with bash v5.0, but not v4.4
printf -v yyyymmdd_date '%(%Y%m%d)T' -1
printf -v dash_date '%(%Y-%m-%d)T' -1

volume_name=$1

if [ "$#" == 2 ]
then
  doctl_token=$2
  t_str="-t $doctl_token"
  printf "TOKEN PROVIDED\n"
  printf "TOKEN PROVIDED\n" >> "$log_file"
else
  t_str=""
fi


# Retrieve volume_id
volume_id=$(doctl compute volume list "$t_str" | \
           grep "$volume_name" | awk '{print $1}')
echo $volume_id

# Retrieve list
r_cmd='doctl compute snapshot list --resource volume $t_str >> $log_file'
printf $r_cmd + '\n'
eval "$r_cmd"

snapshot_name="$volume_name"_"$yyyymmdd_date"

# Take snapshot
function TakeSnapshot {
  printf "Taking snapshot of %s called %s" "$volume_id" "$snapshot_name" >> "$log_file"
  t_cmd='doctl compute volume snapshot $volume_id --snapshot-name $snapshot_name \
         --snapshot-desc doctl $dash_date -tag backup $t_str'
  eval "$t_cmd"
}

# Delete snapshot
function DeleteSnapshot {
  # Need to retrieve oldest snapshot_id
  printf "Retrieving list of previous snapshots for %s" "$volume_name" >> "$log_file"
  snapshot_id=$(doctl compute snapshot list --resource volume "$t_str" | \
               grep "$volume_name" | tail -1 | awk '{print $1}')
  snapshot_date=$(doctl compute snapshot list --resource volume "$t_str" | \
               grep "$volume_name" | tail -1 | awk '{print $3}')
  printf "Deleting last one: %s" "$snapshot_id" >> "$log_file"
  printf "Date of: %s" "$snapshot_date" >> "$log_file"
  echo doctl compute snapshot delete "$snapshot_id" "$t_str"
}

###

if [[ "$ARG_TAKE" = true ]]; then
  TakeSnapshot
fi

if [[ "$ARG_DELETE" = true ]]; then
  DeleteSnapshot
fi
