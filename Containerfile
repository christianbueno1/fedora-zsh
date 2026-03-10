# ============================================
# IMAGEN BASE DEVOPS - USUARIO GENÉRICO 'vscode'
# Fedora 43 - Todo desde repositorios oficiales
# ============================================
FROM fedora:43

LABEL maintainer="team-devops" \
      description="Fedora 43 DevOps Environment - Team Shared" \
      version="2.1-fedora-repos" \
      org.opencontainers.image.source="https://github.com/tu-org/devcontainers"

# ============================================
# 1. DEPENDENCIAS DEL SISTEMA (como root)
# ============================================
RUN dnf update -y && \
    dnf install -y \
        # Shell y herramientas básicas
        sudo zsh git curl wget fastfetch vim-enhanced jq \
        # Build essentials
        gcc gcc-c++ make cmake \
        # Python (para Ansible)
        python3 python3-pip \
        # Herramientas de red y sistema
        bind-utils iputils net-tools iproute procps-ng \
        # Compresión y archivos
        unzip tar gzip xz zip \
        # Otros útiles
        bash-completion which man-db less htop \
        && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# ============================================
# 2. DOTNET 9 SDK (desde repos de Fedora)
# ============================================
RUN dnf install -y \
        dotnet-sdk-9.0 \
        aspnetcore-runtime-9.0 \
        && \
    dnf clean all

# ============================================
# 3. HERRAMIENTAS CLOUD AWS Y AZURE (desde repos Fedora)
# ============================================
RUN dnf install -y \
        awscli2 \
        azure-cli \
        && \
    dnf clean all

# ============================================
# 4. HERRAMIENTAS DEVOPS (¡TODAS DESDE REPOS FEDORA!)
# ============================================
RUN dnf install -y \
        ansible \
        opentofu \
        helm \
        kubernetes1.35-client \
        && \
    dnf clean all

# ============================================
# 5. ANSIBLE LINT Y MOLECULE (pip, no hay en repos)
# ============================================
RUN pip3 install --no-cache-dir \
        ansible-lint \
        molecule \
        molecule-podman \
        pytest-testinfra

# ============================================
# 6. CREAR USUARIO GENÉRICO 'vscode' (ESTÁNDAR)
# ============================================
RUN groupadd --gid 1000 vscode && \
    useradd --uid 1000 --gid 1000 -m -s /bin/zsh vscode && \
    echo 'vscode ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir -p /home/vscode/.local/bin && \
    chown -R vscode:vscode /home/vscode

# ============================================
# 7. CONFIGURAR ZSH PARA VSCODE
# ============================================
USER vscode
WORKDIR /home/vscode

# Oh My Zsh + Plugins esenciales
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Copiar configuración Powerlevel10k (debe existir en contexto de build)
COPY --chown=vscode:vscode p10k.zsh /home/vscode/.p10k.zsh

# Configurar .zshrc completo
RUN sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc && \
    sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc && \
    echo '' >> ~/.zshrc && \
    echo '# ============================================' >> ~/.zshrc && \
    echo '# Powerlevel10k Config' >> ~/.zshrc && \
    echo '# ============================================' >> ~/.zshrc && \
    echo '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' >> ~/.zshrc && \
    echo '' >> ~/.zshrc && \
    echo '# ============================================' >> ~/.zshrc && \
    echo '# DevOps Aliases (Team Standard)' >> ~/.zshrc && \
    echo '# ============================================' >> ~/.zshrc && \
    echo 'alias k=kubectl' >> ~/.zshrc && \
    echo 'complete -o default -F __start_kubectl k' >> ~/.zshrc && \
    echo 'alias tf=terraform' >> ~/.zshrc && \
    echo 'alias tofu=opentofu' >> ~/.zshrc && \
    echo '' >> ~/.zshrc && \
    echo '# ============================================' >> ~/.zshrc && \
    echo '# Environment Variables' >> ~/.zshrc && \
    echo '# ============================================' >> ~/.zshrc && \
    echo 'export ZSH_DISABLE_COMPFIX=true' >> ~/.zshrc && \
    echo 'export PATH=$HOME/.local/bin:$HOME/.dotnet/tools:$PATH' >> ~/.zshrc && \
    echo 'export DOTNET_CLI_TELEMETRY_OPTOUT=1' >> ~/.zshrc && \
    echo 'export EDITOR=vim' >> ~/.zshrc

# ============================================
# 8. CONFIGURAR GIT (template para el equipo)
# ============================================
RUN git config --global init.defaultBranch main && \
    git config --global pull.rebase false && \
    git config --global core.editor "vim" && \
    git config --global core.autocrlf input && \
    git config --global push.default simple

# Crear directorio de trabajo estándar
RUN mkdir -p /workspace

# ============================================
# 9. FINALIZAR
# ============================================
USER vscode
WORKDIR /workspace

ENV SHELL=/bin/zsh \
    HOME=/home/vscode \
    USER=vscode \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    EDITOR=vim \
    TERM=xterm-256color

# Healthcheck simple
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD zsh -c "echo 'Team DevOps Container OK'" || exit 1

CMD ["zsh", "-l"]