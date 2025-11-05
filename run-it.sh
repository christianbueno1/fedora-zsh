#!/bin/bash

# variables
IMAGE_NAME="chris-fedora43"
USER_NAME="christianbueno1"

# run the container
echo "Running the container..."
podman run -it --rm docker.io/$USER_NAME/$IMAGE_NAME:latest
echo "Done."