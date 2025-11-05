#!/bin/bash
# script to build the image using podman on fedora 43

# get the short commit sha
COMMIT_SHA=$(git rev-parse --short HEAD)
# get the branch name
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD | tr '/' '-')
# print for debugging
echo "Building image for commit: $COMMIT_SHA on branch: $BRANCH_NAME"
# variables
IMAGE_NAME="chris-fedora43"
USER_NAME="christianbueno1"

# build the image with podman
podman build -t docker.io/$USER_NAME/$IMAGE_NAME:$COMMIT_SHA -f Containerfile .
# tag with branch name
podman tag docker.io/$USER_NAME/$IMAGE_NAME:$COMMIT_SHA docker.io/$USER_NAME/$IMAGE_NAME:$BRANCH_NAME
# tag with latest if on main branch
if [ "$BRANCH_NAME" == "main" ]; then
    podman tag docker.io/$USER_NAME/$IMAGE_NAME:$COMMIT_SHA docker.io/$USER_NAME/$IMAGE_NAME:latest
fi

# print for debugging the images built
echo "Built images:"
podman images --filter=reference="docker.io/$USER_NAME/$IMAGE_NAME*"

# authenticate to docker hub, use password-stdin and file ~/Documents/docker-pat.txt
echo "Authenticating to Docker Hub..."
podman login -u $USER_NAME --password-stdin docker.io < ~/Documents/docker-pat.txt

# push the images
echo "Pushing images to Docker Hub..."
podman push docker.io/$USER_NAME/$IMAGE_NAME:$COMMIT_SHA
podman push docker.io/$USER_NAME/$IMAGE_NAME:$BRANCH_NAME
if [ "$BRANCH_NAME" == "main" ]; then
    podman push docker.io/$USER_NAME/$IMAGE_NAME:latest
fi