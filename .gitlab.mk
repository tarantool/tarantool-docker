TNT_VER=$(shell cat versions/${OS}_${VER})

build:
	docker build --no-cache --network=host --build-arg TNT_VER=${TNT_VER} \
		-t ${IMAGE}:${TAG} -f dockerfiles/${OS}_${DVER} .
	docker run --rm --name tarantool_${TAG} -p ${PORT}:${PORT} -d ${IMAGE}:${TAG}
	docker exec -t tarantool_${TAG} tarantool_is_up
	docker stop tarantool_${TAG}
	docker push ${IMAGE}:${TAG}
	if [ -n "${TAG_LATEST}" ] ; then \
		docker tag ${IMAGE}:${TAG} ${IMAGE}:${TAG_LATEST} ; \
		docker push ${IMAGE}:${TAG_LATEST} ; \
	fi
