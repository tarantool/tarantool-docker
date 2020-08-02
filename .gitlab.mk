TNT_VER=$(shell cat versions/${OS}_${DIST}_${VER})
ROCKS_INSTALLER?='tarantoolctl rocks'
ENABLE_BUNDLED_LIBYAML?='ON'
IMAGE?='tarantool/tarantool'

build:
	[ "${TNT_VER}" != "" ] || (echo "ERROR: TNT_VER not defined" ; exit 1)
	[ "${DOCKERFILE_NAME_SUFFIX}" != "" ] && \
		DOCKERFILE_SUFFIX=_${DOCKERFILE_NAME_SUFFIX} ; \
	docker build --no-cache --network=host \
		--build-arg ROCKS_INSTALLER=${ROCKS_INSTALLER} \
		--build-arg ENABLE_BUNDLED_LIBYAML=${ENABLE_BUNDLED_LIBYAML} \
		--build-arg TNT_VER=${TNT_VER} \
		--build-arg BASE_IMAGE="${OS}:${DIST}" \
		-t ${IMAGE}:${TAG} -f dockerfiles/${OS}_${DIST}$${DOCKERFILE_SUFFIX} .
	docker run --rm --name tarantool_${TAG} -p ${PORT}:${PORT} -d ${IMAGE}:${TAG}
	docker exec -t tarantool_${TAG} tarantool_is_up
	docker stop tarantool_${TAG}
	if [ -n "${GITLAB_CI}" ] ; then \
		docker push ${IMAGE}:${TAG} ; \
		if [ -n "${TAG_LATEST}" ] ; then \
			docker tag ${IMAGE}:${TAG} ${IMAGE}:${TAG_LATEST} ; \
			docker push ${IMAGE}:${TAG_LATEST} ; \
		fi ; \
	fi
