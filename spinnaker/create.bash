#!/bin/bash
set -ex

# scope:
#   default            https://www.googleapis.com/auth/cloud.useraccounts.readonly
#                      https://www.googleapis.com/auth/devstorage.read_only
#                      https://www.googleapis.com/auth/logging.write
#                      https://www.googleapis.com/auth/monitoring.write
#                      https://www.googleapis.com/auth/pubsub
#                      https://www.googleapis.com/auth/service.management.readonly
#                      https://www.googleapis.com/auth/servicecontrol
#                      https://www.googleapis.com/auth/trace.append
#   bigquery           https://www.googleapis.com/auth/bigquery
#   cloud-platform     https://www.googleapis.com/auth/cloud-platform
#   compute-ro         https://www.googleapis.com/auth/compute.readonly
#   compute-rw         https://www.googleapis.com/auth/compute
#   datastore          https://www.googleapis.com/auth/datastore
#   logging-write      https://www.googleapis.com/auth/logging.write
#   monitoring         https://www.googleapis.com/auth/monitoring
#   monitoring-write   https://www.googleapis.com/auth/monitoring.write
#   service-control    https://www.googleapis.com/auth/servicecontrol
#   service-management https://www.googleapis.com/auth/service.management.readonly
#   sql (DEPRECATED)   https://www.googleapis.com/auth/sqlservice:
#   sql-admin          https://www.googleapis.com/auth/sqlservice.admin
#   storage-full       https://www.googleapis.com/auth/devstorage.full_control
#   storage-ro         https://www.googleapis.com/auth/devstorage.read_only
#   storage-rw         https://www.googleapis.com/auth/devstorage.read_write
#   taskqueue          https://www.googleapis.com/auth/taskqueue
#   useraccounts-ro    https://www.googleapis.com/auth/cloud.useraccounts.readonly
#   useraccounts-rw    https://www.googleapis.com/auth/cloud.useraccounts
#   userinfo-email     https://www.googleapis.com/auth/userinfo.email

. "$(dirname "$0")"/env.bash

HALYARD_SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --project="$GCP_PROJECT" --filter="displayName:$HALYARD_SERVICE_ACCOUNT" --format='value(email)')
gcloud beta compute --project="$GCP_PROJECT" instances create "$HALYARD_HOST" \
  --zone="$HALYARD_ZONE" \
  --machine-type="$HALYARD_MACHINE_TYPE" \
  --service-account="$HALYARD_SERVICE_ACCOUNT_EMAIL" \
  --scopes="https://www.googleapis.com/auth/devstorage.read_only,logging-write,monitoring-write,servicecontrol,service-management,https://www.googleapis.com/auth/trace.append" \
  --min-cpu-platform="Automatic" \
  --image-project="ubuntu-os-cloud" \
  --image-family="ubuntu-1404-lts" \
  --boot-disk-size="10" \
  --boot-disk-type="pd-ssd"

gcloud alpha container --project="$GCP_PROJECT" clusters create "$SPINNAKER_CLUSTER" \
  --zone="$SPINNAKER_ZONE" \
  --machine-type="$SPINNAKER_MACHINE_TYPE" \
  --cluster-version="1.7.8"
  --num-nodes="$SPINNAKER_NUM_NODES" \
  --enable-cloud-logging \
  --no-enable-cloud-monitoring \
  --enable-legacy-authorization \
  --scopes=default,compute-rw,https://www.googleapis.com/auth/devstorage.read_only,logging-write,monitoring,service-control,service-management,https://www.googleapis.com/auth/trace.append,userinfo-email

gcloud beta compute --project="$GCP_PROJECT" scp "$(dirname "$0")"/halyard/init.bash "$HALYARD_HOST":halyard.bash --zone="$HALYARD_ZONE"
gcloud beta compute --project="$GCP_PROJECT" ssh "$HALYARD_HOST" --zone="$HALYARD_ZONE" --ssh-flag="-L 9000:localhost:9000" --ssh-flag="-L 8084:localhost:8084" --command="SPINNAKER_CLUSTER=$SPINNAKER_CLUSTER SPINNAKER_ZONE=$SPINNAKER_ZONE GCS_SERVICE_ACCOUNT=$GCS_SERVICE_ACCOUNT SPINNAKER_VERSION=$SPINNAKER_VERSION ~/halyard.bash"
