#!/bin/bash
# script to build the image using podman on fedora 43

# get the short commit sha
COMMIT_SHA=$(git rev-parse --short HEAD)
# get the branch name
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD | tr '/' '-')
# print for debugging
echo "Building image for commit: $COMMIT_SHA on branch: $BRANCH_NAME"
# variables
IMAGE_NAME="devops-fedora43"
DOCKER_USER="christianbueno1"
REGISTRY="registry-1.docker.io"
PAT_FILE="$HOME/Documents/docker-pat.txt"
# use $1 set default false
RUN_CONTAINER="${1:-false}" # set to true to run the container after building


# build the image with podman
podman build -t docker.io/$DOCKER_USER/$IMAGE_NAME:$COMMIT_SHA -f Containerfile .
# tag with branch name
podman tag docker.io/$DOCKER_USER/$IMAGE_NAME:$COMMIT_SHA docker.io/$DOCKER_USER/$IMAGE_NAME:$BRANCH_NAME
# tag with latest if on main branch
if [ "$BRANCH_NAME" == "main" ]; then
    podman tag docker.io/$DOCKER_USER/$IMAGE_NAME:$COMMIT_SHA docker.io/$DOCKER_USER/$IMAGE_NAME:latest
fi

# print for debugging the images built
echo "Built images:"
podman images --filter=reference="docker.io/$DOCKER_USER/$IMAGE_NAME*"

# Authenticate to Docker Hub
echo "🔐 Authenticating to Docker Hub..."
podman login -u "$DOCKER_USER" --password-stdin "$REGISTRY" < "$PAT_FILE"
echo "✅ Authenticated successfully."

# push the images
echo "Pushing images to Docker Hub..."
podman push docker.io/$DOCKER_USER/$IMAGE_NAME:$COMMIT_SHA
podman push docker.io/$DOCKER_USER/$IMAGE_NAME:$BRANCH_NAME
if [ "$BRANCH_NAME" == "main" ]; then
    podman push docker.io/$DOCKER_USER/$IMAGE_NAME:latest
fi

# run the container
if [ "$RUN_CONTAINER" == "run" ]; then
    echo "Running the container..."
    podman run -it --rm docker.io/$DOCKER_USER/$IMAGE_NAME:$COMMIT_SHA
fi
echo "Done."