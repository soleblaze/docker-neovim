build:
	podman build -t "ghcr.io/soleblaze/neovim:main" --no-cache .

build-cache:
	podman build -t "ghcr.io/soleblaze/neovim:main" .
