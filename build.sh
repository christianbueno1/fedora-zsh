#!/bin/bash
# script to build the image using podman on fedora 43

# get the short commit sha
COMMIT_SHA=$(git rev-parse --short HEAD)
# get the branch name
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD | tr '/' '-')
# print for debugging
echo "Building image for commit: $COMMIT_SHA on branch: $BRANCH_NAME"
