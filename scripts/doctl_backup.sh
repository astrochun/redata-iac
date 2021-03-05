#!/bin/bash
# To execute and take snapshot:
#   ./doctl_backup.sh -t -v <volume_name> (uses doctl auth stored)
#   ./doctl_backup.sh -t -v <volume_name> -t <token> (uses specified token)
# To delete:
#   ./doctl_backup.sh -d -v <volume_name> (uses doctl auth stored)
#   ./doctl_backup.sh -d -v <volume_name> -t <token> (uses specified token)

log_file=doctl_snapshot_list.log

# A invalid format error occurs with bash v5.0, but not v4.4
yyyymmdd_date=$(date +%Y%m%d)
dash_date=$(date +%Y-%m-%d)

function usage() {
  echo "Usage:
  To execute and take snapshot:
    ./doctl_backup.sh -t -v <volume_name> (uses doctl auth stored)
    ./doctl_backup.sh -t -v <volume_name> -t <token> (uses specified token)

  To delete:
    ./doctl_backup.sh -d -v <volume_name> (uses doctl auth stored)
    ./doctl_backup.sh -d -v <volume_name> -t <token> (uses specified token)\n"
}

t_str=""
while getopts ":hsd:v:t:" opt; do
  case "${opt}" in
    h)
      usage
      exit 0
      ;;
    s)
      snapshot="true"
      ;;
    d)
      delete="true"
      ;;
    v)
      volume_name="$OPTARG"
      msg="VOLUME PROVIDED : $volume_name"
      echo $msg
      printf "$msg\n" >> $log_file
      ;;
    t)
      msg="TOKEN PROVIDED"
      printf "$msg\n" >> $log_file
      doctl_token="$OPTARG"
      t_str="-t $doctl_token"
      ;;
  esac
done


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

if [[ "$snapshot" = "true" ]]; then
  TakeSnapshot
fi

if [[ "$delete" = "true" ]]; then
  DeleteSnapshot
fi
