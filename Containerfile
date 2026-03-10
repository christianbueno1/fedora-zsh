FROM fedora:43

# 1. Herramientas del sistema y .NET SDK (Agnóstico al usuario)
RUN dnf update -y && \
    dnf install -y sudo zsh git curl fastfetch vim-enhanced \
    dotnet-sdk-9.0 && \
    dnf clean all

# 2. Crear usuario genérico 'vscode'
# Usamos UID/GID 1000 que es el estándar para el primer usuario en Linux
RUN groupadd --gid 1000 vscode && \
    useradd --uid 1000 --gid 1000 -m -s /bin/zsh vscode && \
    echo 'vscode ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# 3. Configurar entorno visual para el usuario vscode
USER vscode
WORKDIR /home/vscode

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# Copiamos el archivo p10k.zsh (debe estar en la misma carpeta que el Containerfile)
COPY --chown=vscode:vscode p10k.zsh /home/vscode/.p10k.zsh

RUN sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc && \
    sed -i 's/^plugins=(/&zsh-autosuggestions /' ~/.zshrc && \
    echo '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' >> ~/.zshrc

ENV SHELL=/bin/zsh
CMD ["zsh", "-l"]