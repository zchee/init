#!/bin/bash
set -ex

curl -O https://storage.googleapis.com/kubernetes-release/release/"$(curl -sSL https://storage.googleapis.com/kubernetes-release/release/latest.txt)"/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/stable/InstallHalyard.sh
sudo bash -x InstallHalyard.sh -y --user "$USER"
. ~/.bashrc

gcloud config set container/use_client_certificate true
gcloud container clusters get-credentials "$SPINNAKER_CLUSTER" --zone="$SPINNAKER_ZONE"

GCS_SERVICE_ACCOUNT_DEST=~/.config/gcloud/credentials/"$GCS_SERVICE_ACCOUNT".json
mkdir -p "$(dirname "$GCS_SERVICE_ACCOUNT_DEST")"
gcloud iam service-accounts keys create "$GCS_SERVICE_ACCOUNT_DEST" --iam-account "$(gcloud iam service-accounts list --filter="displayName:$GCS_SERVICE_ACCOUNT" --format='value(email)')"

hal config version edit --version "$SPINNAKER_VERSION"

hal config storage gcs edit --project "$(gcloud info --format='value(config.project)')" --json-path "$GCS_SERVICE_ACCOUNT_DEST"
hal config storage edit --type gcs

hal config provider docker-registry enable
hal config provider docker-registry account add gcr-account --address gcr.io --username _json_key --password-file "$GCS_SERVICE_ACCOUNT_DEST"

hal config provider kubernetes enable
hal config provider kubernetes account add k8s-account --docker-registries gcr-account --context "$(kubectl config current-context)"

hal config deploy edit --account-name k8s-account --type distributed
hal deploy apply
