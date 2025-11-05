FROM fedora:43

# Instalar dependencias necesarias
RUN dnf update -y && \
    dnf install -y sudo zsh git curl && \
    dnf clean all

# Crear usuario chris
RUN useradd -m -s /bin/zsh chris && \
    echo 'chris ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Cambiar al usuario chris
USER chris
WORKDIR /home/chris

# Instalar Oh My Zsh, Powerlevel10k y plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# Configurar .zshrc
RUN sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc && \
    sed -i 's/^plugins=(/&zsh-autosuggestions /' ~/.zshrc

COPY --chown=chris:chris p10k.zsh /home/chris/.p10k.zsh

# Comando por defecto
# CMD ["sleep", "infinity"]