#!/bin/bash
set -ex

. "$(dirname "$0")"/env.bash

gcloud iam service-accounts --project="$GCP_PROJECT" create "$APPENGINE_SERVICE_ACCOUNT_NAME" --display-name "$APPENGINE_SERVICE_ACCOUNT_NAME"
APPENGINE_SERVICE_ACCOUNT_EMAIL="$(gcloud iam service-accounts list --filter="displayName:$APPENGINE_SERVICE_ACCOUNT_NAME" --format='value(email)')"
gcloud projects add-iam-policy-binding --project="$GCP_PROJECT" "$GCP_PROJECT" --role roles/storage.admin --member serviceAccount:"$APPENGINE_SERVICE_ACCOUNT_EMAIL"
gcloud projects add-iam-policy-binding --project="$GCP_PROJECT" "$GCP_PROJECT" --role roles/appengine.appAdmin --member serviceAccount:"$APPENGINE_SERVICE_ACCOUNT_EMAIL"

gcloud compute scp --project="$GCP_PROJECT" "$(dirname "$0")"/halyard/appengine.bash "$HALYARD_HOST":appengine.bash --zone="$HALYARD_ZONE"
APPENGINE_SERVICE_ACCOUNT_EMAIL="$(gcloud iam service-accounts --project="$GCP_PROJECT_DIST" list --filter="displayName:$APPENGINE_SERVICE_ACCOUNT_NAME" --format='value(email)')"
gcloud iam service-accounts keys create "./$GCP_PROJECT_DIST-service-account.json" --iam-account "$APPENGINE_SERVICE_ACCOUNT_EMAIL"
gcloud compute scp --project="$GCP_PROJECT" "./$GCP_PROJECT_DIST-service-account.json" "$HALYARD_HOST:~/.config/gcloud/credentials/$GCP_PROJECT_DIST-appengine-account.json" --zone="$HALYARD_ZONE"
gcloud compute ssh "$HALYARD_HOST" --project="$GCP_PROJECT" --zone="$HALYARD_ZONE" --command="GITHUB_TOKEN=$GITHUB_TOKEN GCP_PROJECT=$GCP_PROJECT_DIST APPENGINE_SERVICE_ACCOUNT_NAME=$APPENGINE_SERVICE_ACCOUNT_NAME ~/appengine.bash"
