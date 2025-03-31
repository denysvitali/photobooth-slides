dev:
	docker run \
		--rm \
		-u $(shell id -u):$(shell id -g) -v $(shell pwd):/app \
		-w /app \
		-p 3030:3030 \
		-it node:lts-alpine \
		sh
