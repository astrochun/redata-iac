#!/bin/bash
# To execute and take snapshot:
#   ./doctl_backup.sh -v <volume_name> -m take (uses doctl auth stored)
#   ./doctl_backup.sh -v <volume_name> -t <token> -m take(uses specified token)
# To delete:
#   ./doctl_backup.sh -v <volume_name> -m delete (uses doctl auth stored)
#   ./doctl_backup.sh -v <volume_name> -t <token> -m delete (uses specified token)

log_file=doctl_snapshot_list.log

# A invalid format error occurs with bash v5.0, but not v4.4
yyyymmdd_date=$(date +%Y%m%d)
dash_date=$(date +%Y-%m-%d)

function usage() {
  echo "Usage:
  To execute and take snapshot:
    ./doctl_backup.sh -v <volume_name> -m take -v (uses doctl auth stored)
    ./doctl_backup.sh -v <volume_name> -m take -t <token> (uses specified token)

  To delete:
    ./doctl_backup.sh -v <volume_name> -m delete (uses doctl auth stored)
    ./doctl_backup.sh -v <volume_name> -m delete -t <token> (uses specified token)"
}

function logging() {
  echo $1
  printf "$1\n" >> "$log_file"
}

if [ -e $1 ]
then
  usage
  exit 1
fi

t_str=""
while getopts "hm:v:t:" opt; do
  case "${opt}" in
    h)
      usage
      exit 0
      ;;
    m)
      method="$OPTARG"
      ;;
    v)
      volume_name="$OPTARG"
      logging "VOLUME PROVIDED : $volume_name"
      ;;
    t)
      logging "TOKEN PROVIDED"
      doctl_token="$OPTARG"
      t_str="-t ${doctl_token}"
      ;;
  esac
done

# Retrieve volume_id
volume_id=$(doctl compute volume list $t_str | \
           grep $volume_name | awk '{print $1}')
logging "VOLUME ID : $volume_id"

# Retrieve list
r_cmd="doctl compute snapshot list --resource volume ${t_str} >> ${log_file}"
logging "${r_cmd}"
eval "$r_cmd"

# Take snapshot
function TakeSnapshot {
  snapshot_name="${volume_name}_${yyyymmdd_date}"

  logging "SAVING SNAPSHOT AS : $snapshot_name"
  logging "Taking snapshot of $volume_id called $snapshot_name"

  s_cmd="doctl compute volume snapshot $volume_id --snapshot-name $snapshot_name \
    --snapshot-desc doctl $dash_date -tag backup ${t_str}"
  logging "$s_cmd"
  # eval "$s_cmd"
}

# Delete snapshot
function DeleteSnapshot {
  # Need to retrieve oldest snapshot_id
  logging "Retrieving list of previous snapshots for $volume_name"
  snapshot_id=$(doctl compute snapshot list --resource volume "$t_str" | grep $volume_name | tail -1 | awk '{print $1}')
  snapshot_date=$(doctl compute snapshot list --resource volume "$t_str" | \
               grep "$volume_name" | tail -1 | awk '{print $3}')
  logging "Deleting last one: ${snapshot_id}"
  logging "Date of: $snapshot_date"
  d_cmd="doctl compute snapshot delete $snapshot_id ${t_str}"
  logging "$d_cmd"
  # eval "$d_cmd"
}

###

if [[ "$method" = "take" ]]; then
  TakeSnapshot
fi

if [[ "$method" = "delete" ]]; then
  DeleteSnapshot
fi
