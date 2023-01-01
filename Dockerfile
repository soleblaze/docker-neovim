FROM debian:latest

RUN apt-get update && apt-get full-upgrade -y \
  && apt-get install -y \
  build-essential \
  curl \
  git \
  && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get update && apt-get install nodejs \
  && rm -rf /var/lib/apt/lists/*


# Install Neovim
RUN curl -Lo /nvim.tgz https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz \
  && mkdir /neovim \
  && tar xf /nvim.tgz \
  && rm /nvim.tgz

# Install Go
RUN curl -Lo /go.tgz https://go.dev/dl/go1.19.4.linux-amd64.tar.gz \
  && tar -C /usr/local -xf /go.tgz \
  && rm /go.tgz

# Install Tree-Sitter
RUN curl -Lo /usr/local/bin/tree-sitter.gz https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz \
  && gunzip /usr/local/bin/tree-sitter.gz \
  && chmod 755 /usr/local/bin/tree-sitter

RUN groupadd neovim
RUN useradd -g neovim -ms /bin/bash neovim

USER neovim
WORKDIR /home/neovim
ENV PATH="$PATH:/usr/local/go/bin:/nvim-linux64/bin"

# Download Neovim config
RUN mkdir -p /home/neovim/.config
RUN git clone https://github.com/soleblaze/neovimContainer \
 && mv neovimContainer/config /home/neovim/.config/nvim \
 && rm -rf neovimContainer

# Setup Neovim
RUN /nvim-linux64/bin/nvim --headless +"TSUpdate" +qa
