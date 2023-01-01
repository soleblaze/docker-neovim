FROM ubuntu:latest

RUN apt-get update && apt-get full-upgrade -y \
  && apt-get install -y \
  build-essential \
  cargo \
  curl \
  git \
  lua5.4 \
  python3 \
  python3-pip \
  ruby \
  ruby-dev \
  && rm -rf /var/lib/apt/lists/*

# Install Node
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get update && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

# Install gh
RUN curl -sLo /usr/share/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
  && apt-get update && apt-get install -y gh \
  && rm -rf /var/lib/apt/lists/*

# Install Neovim
RUN curl -sLo /nvim.tgz https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz \
  && mkdir /neovim \
  && tar xf /nvim.tgz \
  && rm /nvim.tgz \
  && mv /nvim-linux64 /nvim

# Install Go 1.19.4
RUN curl -sLo /go.tgz https://go.dev/dl/go1.19.4.linux-amd64.tar.gz \
  && tar -C /usr/local -xf /go.tgz \
  && rm /go.tgz

# Install ripgrep
RUN curl -sLo /rg.deb https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb \
  && dpkg -i /rg.deb \
  && rm /rg.deb

# Install fzf
RUN curl -sLo /fzf.tgz https://github.com/junegunn/fzf/releases/download/0.35.1/fzf-0.35.1-linux_amd64.tar.gz \
  && tar -C /usr/local/bin -xf /fzf.tgz \
  && rm /fzf.tgz

# Install tools
RUN cargo install --features lsp --locked taplo-cli

RUN gem install solargraph

RUN npm install -g @ansible/ansible-language-server
RUN npm install -g alex
RUN npm install -g bash-language-server
RUN npm install -g dockerfile-language-server-nodejs
RUN npm install -g fixjson
RUN npm install -g jsonlint
RUN npm install -g markdownlint
RUN npm install -g prettier
RUN npm install -g sql-language-server
RUN npm install -g vscode-langservers-extracted
RUN npm install -g write-good
RUN npm install -g yaml-language-server

RUN pip3 install ansible-lint
RUN pip3 install black
RUN pip3 install cmake-language-server
RUN pip3 install pyright

RUN curl -sLo /luals.tgz https://github.com/sumneko/lua-language-server/releases/download/3.6.4/lua-language-server-3.6.4-linux-x64.tar.gz \
  && mkdir /luals \
  && tar -C /luals -xf /luals.tgz \
  && mv /luals/bin/lua-language-server /usr/local/bin \
  && rm -rf /luals

RUN curl -sLo /usr/local/bin/marksman https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux \
  && chmod 755 /usr/local/bin/marksman

RUN curl -sLo /shellcheck.tgz https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz \
  && tar xf /shellcheck.tgz \
  && mv /shellcheck-stable/shellcheck /usr/local/bin \
  && rm -rf /shellcheck.tgz /shellcheck-stable

RUN curl -sLo /tlsp.tgz https://github.com/juliosueiras/terraform-lsp/releases/download/v0.0.12/terraform-lsp_0.0.12_linux_amd64.tar.gz \
  && mkdir /tlsp \
  && tar -C /tlsp -xf /tlsp.tgz \
  && mv /tlsp/terraform-lsp /usr/local/bin \
  && rm -rf /tlsp

RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

RUN curl -sLo /usr/local/bin/tree-sitter.gz https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz \
  && gunzip /usr/local/bin/tree-sitter.gz \
  && chmod 755 /usr/local/bin/tree-sitter


# User Setup
RUN groupadd neovim
RUN useradd -g neovim -ms /bin/bash neovim

# Download Neovim config
RUN mkdir -p /home/neovim/.config
COPY config /home/neovim/.config/nvim
COPY linters/golangci.yml /home/neovim/.golangci.yml
COPY linters/markdownlint.yaml /home/neovim/.markdownlint.yaml
RUN mkdir -p /home/neovim/.config/yamllint
COPY linters/yamllint.yml /home/neovim/.config/yamllint/config

RUN chown -R neovim:neovim /home/neovim

USER neovim
WORKDIR /home/neovim
ENV PATH="$PATH:/usr/local/go/bin:/nvim/bin:/home/neovim/go/bin"

# Install go binaries
RUN go install github.com/abenz1267/gomvp@latest
RUN go install github.com/cweill/gotests/...@latest
RUN go install github.com/davidrjenni/reftools/cmd/fillstruct@latest
RUN go install github.com/davidrjenni/reftools/cmd/fillswitch@latest
RUN go install github.com/fatih/gomodifytags@latest
RUN go install github.com/go-delve/delve/cmd/dlv@latest
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
RUN go install github.com/josharian/impl@latest
RUN go install github.com/koron/iferr@latest
RUN go install github.com/kyoh86/richgo@latest
RUN go install github.com/onsi/ginkgo/v2/ginkgo@latest
RUN go install github.com/segmentio/golines@latest
RUN go install golang.org/x/tools/cmd/callgraph@latest
RUN go install golang.org/x/tools/cmd/goimports@latest
RUN go install golang.org/x/tools/cmd/gorename@latest
RUN go install golang.org/x/tools/cmd/guru@latest
RUN go install golang.org/x/tools/gopls@latest
RUN go install golang.org/x/tools/gopls@latest
RUN go install golang.org/x/vuln/cmd/govulncheck@latest
RUN go install gotest.tools/gotestsum@latest
RUN go install github.com/tmc/json-to-struct@latest
RUN go install mvdan.cc/gofumpt@latest
RUN go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Setup Neovim
RUN nvim --headless +"TSUpdate" +qa

RUN mkdir work
WORKDIR /home/neovim/work
ENTRYPOINT ["nvim"]
