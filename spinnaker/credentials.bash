#!/bin/bash
set -ex

. "$(dirname "$0")"/env.bash

gcloud service-management --project="$GCP_PROJECT" enable iam.googleapis.com
gcloud service-management --project="$GCP_PROJECT" enable cloudresourcemanager.googleapis.com

gcloud iam service-accounts create "$HALYARD_SERVICE_ACCOUNT" --project="$GCP_PROJECT" --display-name "$HALYARD_SERVICE_ACCOUNT" || true
HALYARD_SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --project="$GCP_PROJECT" --filter="displayName:$HALYARD_SERVICE_ACCOUNT" --format='value(email)')
gcloud projects add-iam-policy-binding "$GCP_PROJECT" --role roles/iam.serviceAccountKeyAdmin --member serviceAccount:"$HALYARD_SERVICE_ACCOUNT_EMAIL"
gcloud projects add-iam-policy-binding "$GCP_PROJECT" --role roles/container.admin --member serviceAccount:"$HALYARD_SERVICE_ACCOUNT_EMAIL"

gcloud iam service-accounts create "$GCS_SERVICE_ACCOUNT" --project="$GCP_PROJECT" --display-name "$GCS_SERVICE_ACCOUNT" || true
GCS_SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --project="$GCP_PROJECT" --filter="displayName:$GCS_SERVICE_ACCOUNT" --format='value(email)')
gcloud projects add-iam-policy-binding "$GCP_PROJECT" --role roles/storage.admin --member serviceAccount:"$GCS_SERVICE_ACCOUNT_EMAIL"
