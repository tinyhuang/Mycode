#!/bin/bash
#
# !!!DANGEROUS!!!
#
#  
# Delete non-SOA and non-NS records. Then delete a Route 53 hosted zone with all contents
#
# !!!!Note!!!!
# Set your local profile properly, in this case the profile is set to vwcniot
# --region cn-northwest-1 --endpoint-url https://api.route53.cn  are special setting for route53 China preview service, remove it if you do not need that
#  
#  USAGE:  /bin/bash remove_zone.sh  < zone name like dp.vw.wcar-c.cn >
#

set -e
VERBOSE=true



for domain_to_delete in "$@"; do
  $VERBOSE && echo "DESTROYING: $domain_to_delete in Route 53"

  hosted_zone_id=$(
    aws  --profile vwcniot route53 --region cn-northwest-1 --endpoint-url https://api.route53.cn  list-hosted-zones \
      --output text \
      --query 'HostedZones[?Name==`'$domain_to_delete'.`].Id'
  )
  $VERBOSE &&
    echo hosted_zone_id=${hosted_zone_id:?Unable to find: $domain_to_delete}

  aws  --profile vwcniot route53 --region cn-northwest-1 --endpoint-url https://api.route53.cn  list-resource-record-sets \
    --hosted-zone-id $hosted_zone_id |
  jq -c '.ResourceRecordSets[]' | \
  grep -v 'SOA'  | \
  grep -v 'NS' |
  while read -r resourcerecordset; do
    read -r name type <<<$(jq -r '.Name,.Type' <<<"$resourcerecordset")
    if [ $type == "NS" -o $type == "SOA" ]; then
      $VERBOSE && echo "SKIPPING: $type $name"
    else
      change_id=$(aws  --profile vwcniot route53 --region cn-northwest-1 --endpoint-url https://api.route53.cn  change-resource-record-sets \
        --hosted-zone-id $hosted_zone_id \
        --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":
            '"$resourcerecordset"'
          }]}' \
        --output text \
        --query 'ChangeInfo.Id')
      $VERBOSE && echo "DELETING: $type $name $change_id"
    fi
  done

  change_id=$(aws  --profile vwcniot route53 --region cn-northwest-1 --endpoint-url https://api.route53.cn  delete-hosted-zone \
    --id $hosted_zone_id \
    --output text \
    --query 'ChangeInfo.Id')
  $VERBOSE && echo "DELETING: hosted zone for $domain_to_delete $change_id"
done