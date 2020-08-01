TNT_VER=$(shell cat versions/${OS}_${DIST}_${VER})
ROCKS_INSTALLER?='tarantoolctl rocks'
ENABLE_BUNDLED_LIBYAML?='ON'

build:
	docker build --no-cache --network=host \
		--build-arg ROCKS_INSTALLER=${ROCKS_INSTALLER} \
		--build-arg ENABLE_BUNDLED_LIBYAML=${ENABLE_BUNDLED_LIBYAML} \
		--build-arg TNT_VER=${TNT_VER} \
		--build-arg BASE_IMAGE="${OS}:${DIST}" \
		-t ${IMAGE}:${TAG} -f dockerfiles/${OS}_${DIST}_${DOCKERFILE_NAME_SUFFIX} .
	docker run --rm --name tarantool_${TAG} -p ${PORT}:${PORT} -d ${IMAGE}:${TAG}
	docker exec -t tarantool_${TAG} tarantool_is_up
	docker stop tarantool_${TAG}
	docker push ${IMAGE}:${TAG}
	if [ -n "${TAG_LATEST}" ] ; then \
		docker tag ${IMAGE}:${TAG} ${IMAGE}:${TAG_LATEST} ; \
		docker push ${IMAGE}:${TAG_LATEST} ; \
	fi
