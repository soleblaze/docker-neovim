build:
	docker build -t "ghcr.io/soleblaze/neovim:main" --no-cache .

build-cache:
	docker build -t "ghcr.io/soleblaze/neovim:main" .
