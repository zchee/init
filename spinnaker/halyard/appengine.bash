#!/bin/bash
set -ex

APPENGINE_SERVICE_ACCOUNT_DEST=~/.config/gcloud/credentials/"$GCP_PROJECT"-appengine-account.json
mkdir -p "$(dirname "$APPENGINE_SERVICE_ACCOUNT_DEST")"

hal config provider appengine enable
hal config provider appengine account add "$GCP_PROJECT"-appengine-account --project "$GCP_PROJECT" --json-path "$APPENGINE_SERVICE_ACCOUNT_DEST" --github-oauth-access-token
