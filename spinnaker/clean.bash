#!/bin/bash
set -ex

. "$(dirname "$0")"/env.bash

gcloud iam --quiet service-accounts delete "$HALYARD_SERVICE_ACCOUNT"@"$GCP_PROJECT".iam.gserviceaccount.com
gcloud iam --quiet service-accounts delete "$GCS_SERVICE_ACCOUNT"@"$GCP_PROJECT".iam.gserviceaccount.com
gcloud iam --quiet service-accounts delete "$APPENGINE_SERVICE_ACCOUNT_NAME"@"$GCP_PROJECT".iam.gserviceaccount.com

gcloud compute instances delete --zone="$HALYARD_ZONE" "$HALYARD_HOST"
gcloud alpha container clusters delete --zone="$SPINNAKER_ZONE" "$SPINNAKER_CLUSTER"
