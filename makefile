IMAGE = "automatic_auctions"

run:
	docker build . -f BaseDockerfile -t elixir1.10.3
	docker build . --build-arg PORT=$(PORT) -t $(IMAGE)
	docker run -p $(PORT):$(PORT) $(IMAGE)