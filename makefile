IMAGE = "automatic_auctions"

run:
	docker build . -f BaseDockerfile -t elixir1.10.3
	docker build . --build-arg PORT=$(PORT) -t $(IMAGE)
	docker network create elixir-net || true
	docker run -p $(PORT):$(PORT) -e COOKIE=secret --network elixir-net $(IMAGE)