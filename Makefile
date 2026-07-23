IMAGE_NAME ?= chessdriller
VERSION    ?= $(shell grep -m1 '"version"' package.json | sed -E 's/.*: *"([^"]+)".*/\1/')
REGISTRY   ?=

NODE_IMAGE       ?= node:alpine
NODE_MODULES_VOL ?= $(IMAGE_NAME)_node_modules

DOCKER_RUN := docker run --rm -it \
	-v "$(CURDIR):/code" \
	-v $(NODE_MODULES_VOL):/code/node_modules \
	-w /code \
	-p 3123:3123 \
	$(NODE_IMAGE)

define npm_in_docker
$(DOCKER_RUN) sh -c "apk add --no-cache openssl >/dev/null && npm install && $(1)"
endef

.PHONY: dev build check lint test docker docker-run docker-push clean

dev:
	$(call npm_in_docker,npm run dev -- --host 0.0.0.0)

build:
	$(call npm_in_docker,npm run build)

check:
	$(call npm_in_docker,npm run check)

lint:
	$(call npm_in_docker,npm run lint)

test:
	$(call npm_in_docker,npm test)

docker:
	docker build . -t $(IMAGE_NAME):$(VERSION) -t $(IMAGE_NAME):latest

docker-run:
	docker compose up -d --build

docker-push:
ifeq ($(strip $(REGISTRY)),)
	$(error REGISTRY is not set. Usage: make docker-push REGISTRY=registry.example.com)
endif
	@docker image inspect $(IMAGE_NAME):$(VERSION) >/dev/null 2>&1 || \
		{ echo "Error: $(IMAGE_NAME):$(VERSION) not found locally. Run 'make docker IMAGE_NAME=$(IMAGE_NAME) VERSION=$(VERSION)' first."; exit 1; }
	docker tag $(IMAGE_NAME):$(VERSION) $(REGISTRY)/$(IMAGE_NAME):$(VERSION)
	docker tag $(IMAGE_NAME):latest $(REGISTRY)/$(IMAGE_NAME):latest
	docker push $(REGISTRY)/$(IMAGE_NAME):$(VERSION)
	docker push $(REGISTRY)/$(IMAGE_NAME):latest

clean:
	rm -rf .svelte-kit build
	docker volume rm -f $(NODE_MODULES_VOL)
