include Makefile.variables

.PHONY: gitignore
gitignore: ## .gitignoreをDL
	curl --output .gitignore $(GIT_IGNORE_URL)

.PHONY: docker-network
docker-network: ## コンテナが属するnetworkを作成
	( docker network ls | grep $(DOCKER_NETWORK_NAME) ) \
	|| docker network create $(DOCKER_NETWORK_NAME)

.PHONY: pg-data
pg-data: ## DBのdataを永続化させるためのディレクトリを作成
	mkdir -p $(DOCKER_PG_DATA_PATH)

.PHONY: up
up: docker-network pg-data ## DBコンテナを立ち上げる
	( docker container ls | grep $(DOCKER_PG_HOST) ) \
	|| docker run \
		--detach \
		--rm \
		--publish 5432:5432 \
		--user `id -u`:`id -g` \
		--network $(DOCKER_NETWORK_NAME) \
		--hostname $(DOCKER_PG_HOST) \
		--name $(DOCKER_PG_HOST) \
		--env POSTGRES_USER=$(DOCKER_PG_USER) \
		--env POSTGRES_PASSWORD=$(DOCKER_PG_PASSWORD) \
		--env POSTGRES_DB=$(DOCKER_PG_DATABASE) \
		--env POSTGRES_INITDB_ARGS="--encoding=UTF-8" \
		--env LANG=C.UTF-8 \
		--env TZ=Asia/Tokyo \
		--mount type=bind,source=$(DOCKER_PG_DATA_PATH)/,target=/var/lib/postgresql/data \
		postgres:$(DOCKER_PG_TAG)
	make health-check

.PHONY: bash
bash: up ## DBコンテナに入る
	docker exec -it $(DOCKER_PG_HOST) bash

# PG_PASSWORDではないのはわざと
.PHONY: health-check
health-check: ## DBが起動しているか確認
	docker run \
		--rm \
		--tty \
		--entrypoint '' \
		--network $(DOCKER_NETWORK_NAME) \
		--env PG_HOST=$(DOCKER_PG_HOST) \
		--env PG_USER=$(DOCKER_PG_USER) \
		--env PG_DATABASE=$(DOCKER_PG_DATABASE) \
		--env PGPASSWORD=$(DOCKER_PG_PASSWORD) \
		--mount type=bind,source=$(PWD)/health-check.sh,target=/health-check.sh,readonly \
		postgres:$(DOCKER_PG_TAG) bash /health-check.sh

.PHONY: down
down: ## DBコンテナを落とす
	docker container ls --quiet --filter 'name=$(DOCKER_PG_HOST)' \
	| xargs -I {container-id} docker container stop {container-id}

.PHONY: clean
clean: down ## DBの永続データを削除
	rm --recursive --force $(DOCKER_PG_DATA_PATH)

.PHONY: help
help: ## Make タスク一覧
	@echo '######################################################################'
	@echo '# Makeタスク一覧'
	@echo '# $$ make XXX'
	@echo '# or'
	@echo '# $$ make XXX --dry-run'
	@echo '######################################################################'
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' Makefile \
	| grep --invert-match "## non-help" \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
