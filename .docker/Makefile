init:
	docker-compose up -d && \
	docker-compose exec php sh -c './.docker/scripts/init.sh' && \
	docker-compose exec php sh -c './.docker/scripts/services.sh' && \
	docker-compose exec php sh -c './.docker/scripts/build.sh'
