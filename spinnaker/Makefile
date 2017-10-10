.DEFAULT_GOAL = init

init: create ## initialize spinnaker to GCP GKE instance.

credentials:  ## create a service account for halyard host VM.
	./credentials.bash
.PHONY: credentials

create: credentials
	./create.bash
.PHONY: create

clean:  ## clean spinnaker GKE instance.
	./clean.bash
.PHONY: clean

help:  ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.PHONY: help
