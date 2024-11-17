#!/bin/sh

set -e
# Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them
export DOCKER_SCAN_SUGGEST=false

NS=registry.cn-qingdao.aliyuncs.com/
VERSION=${VERSION:-latest}
REPO=retry/typing-word
NAME=typing-word
INSTANCE=1
PORTS="-p 3000:3000"

cd `dirname $0`
echo "image: ${NS}${REPO}:${VERSION}"
case "$1" in
    dev-ui)
        cd ui; yarn run dev; cd -;
        ;;
    dev-server)
        cd server;  supervisor bin/www; cd -;
        ;;
    build)
    # --build-arg http_proxy=http://your-proxy-host:your-proxy-port --build-arg https_proxy=http://your-proxy-host:your-proxy-port 
    echo docker build -t ${NS}${REPO}:${VERSION} .
	    docker build  -t ${NS}${REPO}:${VERSION} .
        ;;
    push)
	    docker push ${NS}${REPO}:${VERSION}
        ;;
    exec)
	    docker exec -it openresty_openresty_1 /bin/sh
        ;;
    pull)
	    docker pull ${NS}${REPO}:${VERSION}
        ;;
    shell)
	    docker run --rm --name ${NAME}-${INSTANCE} -i -t ${PORTS} ${VOLUMES} ${ENV} ${NS}${REPO}:${VERSION} /bin/bash
        ;;
    run)
        echo docker run --rm --name ${NAME}-${INSTANCE} ${PORTS} ${VOLUMES} ${ENV} ${NS}${REPO}:${VERSION}
        docker run --rm --name ${NAME}-${INSTANCE} ${PORTS} ${VOLUMES} ${ENV} ${NS}${REPO}:${VERSION}
        ;;
    start)
        docker run -d --name ${NAME}-${INSTANCE} ${PORTS} ${VOLUMES} ${ENV} ${NS}${REPO}:${VERSION}
        ;;
    stop)
        docker stop ${NAME}-${INSTANCE}
        ;;
    rm)
        docker rm ${NAME}-${INSTANCE}
        ;;
    release)
	    ./bootstrap.sh build
	    docker push ${NS}${REPO}:${VERSION}
        ;;
    release-server)
	    docker build -t ${NS}${REPO}:${VERSION} .
        docker push ${NS}${REPO}:${VERSION}
        ;;
    compose)
	    docker-compose up
        ;;
    remove-none-images)
        docker rmi $(docker images | grep "^<none>" | awk '{print $3}')
        ;;
    *)
        echo "Usage: sh bootstrap.sh {build|push|shell|run|start|stop|rm|release|remove-none-images}"
        exit 3
        ;;
esac
