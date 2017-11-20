
IMAGE_NAME = matlab-s2i

.PHONY: build
build:
	docker build -t $(IMAGE_NAME) .
	./install.sh $(IMAGE_NAME)

.PHONY: test
test:
	docker build -t $(IMAGE_NAME)-candidate .
	IMAGE_NAME=$(IMAGE_NAME)-candidate test/run
