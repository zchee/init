#!/bin/bash
set -ex

. "$(dirname "$0")"/env.bash

gcloud beta compute --project="$GCP_PROJECT" firewall-rules create spinnaker --direction=INGRESS --action=ALLOW --rules="tcp:7002,tcp:7003,tcp:8080,tcp:8083,tcp:8084,tcp:8087,tcp:8088,tcp:8088,tcp:9000" --description="Spinnaker\ microservices\ firewall\ rule$'\n'$'\n'Deck\	\	9000$'\n'Gate\	\	8084$'\n'Orca\	\	8083$'\n'Clouddriver\	7002$'\n'Front50\	\	8080$'\n'Rosco\	\	8087$'\n'Igor\	\	\	8088$'\n'Echo\	\	8089$'\n'Fiat\	\	\	7003"
