### commands
```bash
podman login -u christianbueno1 registry-1.docker.io
# check if you are logged in
podman login --get-login registry-1.docker.io

podman build -t docker.io/christianbueno1/chris-fedora43:latest -f Containerfile .

# run and start in the foreground without volume
podman run -it --name fedora-container docker.io/christianbueno1/chris-fedora43:latest zsh

podman volume create chris-home

# podman run -d --name fedora-container \
#   -v chris-home:/home/chris \
#   docker.io/christianbueno1/fedora-chris:1

podman run -it --name fedora-container \
  -v chris-home:/home/chris \
  docker.io/christianbueno1/fedora-chris:1 zsh

# podman exec -it fedora-container zsh

# download the image fedora:42
podman pull docker.io/library/fedora:42

# how to update the image
podman pull docker.io/library/fedora:42
# build the image again with the updated base image
podman build -t docker.io/christianbueno1/fedora-chris:2 .

# after update and building the image, stop and remove the container
podman stop fedora-container
podman rm fedora-container
# remove the image
podman rmi docker.io/christianbueno1/fedora-chris:1
# remove the volume
podman volume rm chris-home
# create a new volume
podman volume create chris-home
# create a new container with the updated image
podman run -it --name fedora-container \
  -v chris-home:/home/chris \
  docker.io/christianbueno1/fedora-chris:2 zsh
