build:
	docker build --network=host -t ${IMAGE}:${TAG} ${DIR}/
	docker run --rm --name tarantool_${TAG} -p ${PORT}:${PORT} -d ${IMAGE}:${TAG}
	docker exec -t tarantool_${TAG} tarantool_is_up
	docker stop tarantool_${TAG}
	docker push ${IMAGE}:${TAG}

