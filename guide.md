### commands
```bash
podman login -u christianbueno1 registry-1.docker.io
# check if you are logged in
podman login --get-login registry-1.docker.io

podman build -t docker.io/christianbueno1/fedora-chris:1 .

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