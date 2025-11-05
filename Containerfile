FROM fedora:43

# Instalar dependencias necesarias
RUN dnf update -y && \
    dnf install -y sudo zsh git curl fastfetch && \
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
    
COPY --chown=chris:chris p10k.zsh /home/chris/.p10k.zsh

# Ensure .zshrc uses powerlevel10k and sources the local p10k.zsh,
# add autosuggestions plugin if it's not already there.
RUN sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc && \
    sed -i 's/^plugins=(/&zsh-autosuggestions /' ~/.zshrc || true && \
    echo '' >> ~/.zshrc && \
    echo '# Source local Powerlevel10k config if present' >> ~/.zshrc && \
    echo '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' >> ~/.zshrc && \
    echo 'export ZSH_DISABLE_COMPFIX=true' >> ~/.zshrc

# Ensure login shell and start zsh by default
ENV SHELL=/bin/zsh
CMD ["zsh", "-l"]


# Comando por defecto
# CMD ["sleep", "infinity"]