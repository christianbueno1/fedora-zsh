# Notes

Use p10k.zsh file in the container file to have the same terminal theme as in the host machine.

# 2026-03-09
Cuando haces podman-build del Containerfile, se copia el p10k.zsh al contenedor.
El script build.sh hace el build del Containerfile y luego hace un push a docker.io con el tag latest.
Para correr el contenedor, solo usa run-it.sh, este va a estar listo con zsh y el tema de p10k.zsh, no necesitas preservar el volumen.