FROM ubuntu:latest

ARG fzfVersion=0.35.1
ARG goVersion=1.19.4
ARG lualsVersion=3.6.4
ARG nodeVersion=18
ARG rgVersion=13.0.0
ARG terraformLspVersion=0.0.12

ENV DEBIAN_FRONTEND noninteractive
# Set the locale
RUN apt-get update && apt-get -y install locales \
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure locales \
  && update-locale LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get full-upgrade -y \
  && apt-get install -y \
  build-essential \
  cargo \
  curl \
  fd-find \
  git \
  locate \
  lua5.4 \
  python3 \
  python3-pip \
  ruby \
  ruby-dev \
  && curl -fsSL https://deb.nodesource.com/setup_${nodeVersion}.x | bash - \
  &&  curl -sLo /usr/share/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
  && apt-get update && apt-get install -y gh nodejs \
  && rm -rf /var/lib/apt/lists/*  \
  && ln -s $(which fdfind) /usr/local/bin/fd

# Install tools
RUN curl -sLo /usr/local/bin/marksman https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux \
  && chmod 755 /usr/local/bin/marksman \
  && curl -sLo /shellcheck.tgz https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz \
  && tar xf /shellcheck.tgz \
  && mv /shellcheck-stable/shellcheck /usr/local/bin \
  && rm -rf /shellcheck.tgz /shellcheck-stable \
  && curl -sLo /tlsp.tgz https://github.com/juliosueiras/terraform-lsp/releases/download/v${terraformLspVersion}/terraform-lsp_${terraformLspVersion}_linux_amd64.tar.gz \
  && mkdir /tlsp \
  && tar -C /tlsp -xf /tlsp.tgz \
  && mv /tlsp/terraform-lsp /usr/local/bin \
  && rm -rf /tlsp \
  && curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash \
  && curl -sLo /usr/local/bin/tree-sitter.gz https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz \
  && gunzip /usr/local/bin/tree-sitter.gz \
  && chmod 755 /usr/local/bin/tree-sitter \
  && curl -sLo /fzf.tgz https://github.com/junegunn/fzf/releases/download/${fzfVersion}/fzf-${fzfVersion}-linux_amd64.tar.gz \
  && tar -C /usr/local/bin -xf /fzf.tgz \
  && rm /fzf.tgz \
  && curl -sLo /nvim.tgz https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz \
  && mkdir /neovim \
  && tar xf /nvim.tgz \
  && rm /nvim.tgz \
  && mv /nvim-linux64 /nvim \
  && curl -sLo /go.tgz https://go.dev/dl/go${goVersion}.linux-amd64.tar.gz \
  && tar -C /usr/local -xf /go.tgz \
  && rm /go.tgz \
  && curl -sLo /rg.deb https://github.com/BurntSushi/ripgrep/releases/download/${rgVersion}/ripgrep_${rgVersion}_amd64.deb \
  && dpkg -i /rg.deb \
  && rm /rg.deb \
  && gem install solargraph \
  && npm install -g @ansible/ansible-language-server \
  && npm install -g alex \
  && npm install -g bash-language-server \
  && npm install -g dockerfile-language-server-nodejs \
  && npm install -g fixjson \
  && npm install -g jsonlint \
  && npm install -g markdownlint-cli \
  && npm install -g prettier \
  && npm install -g sql-language-server \
  && npm install -g vscode-langservers-extracted \
  && npm install -g write-good \
  && npm install -g yaml-language-server

# User Setup
RUN groupadd neovim && useradd -g neovim -ms /bin/bash neovim \
  && mkdir -p /home/neovim/.config/yamllint

USER neovim
WORKDIR /home/neovim
ENV HOME="/home/neovim"
ENV PATH="$PATH:/usr/local/go/bin:/nvim/bin:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/luals/bin"

RUN cargo install --features lsp --locked taplo-cli

# Install go binaries
RUN curl -sLo /home/neovim/luals.tgz https://github.com/sumneko/lua-language-server/releases/download/${lualsVersion}/lua-language-server-${lualsVersion}-linux-x64.tar.gz \
  && mkdir /home/neovim/luals \
  && tar -C /home/neovim/luals -xf /home/neovim/luals.tgz \
  && rm -rf /home/neovim/luals.tgz \
  && go install github.com/abenz1267/gomvp@latest \
  && go install github.com/cweill/gotests/...@latest \
  && go install github.com/davidrjenni/reftools/cmd/fillstruct@latest \
  && go install github.com/davidrjenni/reftools/cmd/fillswitch@latest \
  && go install github.com/fatih/gomodifytags@latest \
  && go install github.com/go-delve/delve/cmd/dlv@latest \
  && go install github.com/golang/mock/mockgen@latest \
  && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest \
  && go install github.com/josharian/impl@latest \
  && go install github.com/koron/iferr@latest \
  && go install github.com/kyoh86/richgo@latest \
  && go install github.com/onsi/ginkgo/v2/ginkgo@latest \
  && go install github.com/segmentio/golines@latest \
  && go install github.com/tmc/json-to-struct@latest \
  && go install golang.org/x/tools/cmd/callgraph@latest \
  && go install golang.org/x/tools/cmd/goimports@latest \
  && go install golang.org/x/tools/cmd/gorename@latest \
  && go install golang.org/x/tools/cmd/guru@latest \
  && go install golang.org/x/tools/gopls@latest \
  && go install golang.org/x/vuln/cmd/govulncheck@latest \
  && go install gotest.tools/gotestsum@latest \
  && go install mvdan.cc/gofumpt@latest \
  && go install mvdan.cc/sh/v3/cmd/shfmt@latest \
  && pip3 install --user ansible-lint \
  && pip3 install --user black \
  && pip3 install --user cmake-language-server \
  && pip3 install --user pyright

COPY linters/golangci.yml /home/neovim/.golangci.yml
COPY linters/markdownlint.yaml /home/neovim/.markdownlint.yaml
COPY linters/yamllint.yml /home/neovim/.config/yamllint/config
COPY config /home/neovim/.config/nvim

USER root
RUN chown -R neovim:neovim /home/neovim

# Setup Neovim
USER neovim
RUN nvim --headless +"TSUpdate" +qa

WORKDIR /work
ENTRYPOINT ["nvim"]
