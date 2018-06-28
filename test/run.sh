#!/usr/bin/env bash

PACKERBIN=$(which packer-io || which packer)
BASEDIR="$(dirname $0)/.."
IMAGE="$1"
REGIONS=${2:-$OS_REGION_NAME}
TAG=$(git describe --tags 2>/dev/null)
VERSION=${TAG:-latest}
IMAGE_PREFIX="OVH Lookatch"
COMMIT=$(git rev-parse --verify --short HEAD 2>/dev/null)

is_already_built(){
    image=$1
    echo "Checking if image already built for commit $COMMIT" >&2
    image_id=$(openstack image list \
                         --name "$image" \
                         --property "version=$VERSION" \
                         --property "commit=$COMMIT" \
                         --status active \
                         -f value \
                         -c ID)
    if [ ! -z "$image_id" ]; then
        echo "Image already built under id $image_id. Skipping..." >&2
        return 0
    fi
    return 1
}

build(){
    if is_already_built ${IMAGE}; then
        continue
    fi
    export PACKER_NETWORK_ID=$(openstack network show -c id -f value "Ext-Net")
    echo "Detected Ext-Net on $OS_REGION_NAME on ID $PACKER_NETWORK_ID"
    echo "Starting build for region $OS_REGION_NAME..."
    ${PACKERBIN} build \
        -var version=${VERSION} \
        -var commit=${COMMIT} \
        ${IMAGE}
    if [[ "$?" -ne 0 ]]; then
        exit 1
    fi
}

# check for openstack cli
if ! [ -x "$(command -v openstack)" ]; then
    echo -e "\033[0;31mError: Openstack CLI is not installed.\033[0m\nSee https://docs.openstack.org/mitaka/user-guide/common/cli_install_openstack_command_line_clients.html"
    exit 1
fi

for region in ${REGIONS}; do
    export OS_REGION_NAME="$region";
    if ! (build); then
        echo "Image build failed. Aborting" >&2
        exit 1
    fi
done

if [ "$PUBLISH" == "publish" ]; then
    # if everything is ok, publish
    (cd "${BASEDIR}" && ./test/publish.sh "$(jq -r '.variables.image_name' ${IMAGE})")
fi