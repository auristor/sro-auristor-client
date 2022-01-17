#!/bin/bash

# The MIT License

# Copyright (c) 2019 Dusty Mabe

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

set -eu

# This library is to be sourced in as part of the kmods-via-containers
# framework. There are some environment variables that are used in this
# file that are expected to be defined by the framework already:
# - KVC_CONTAINER_ENVIRONMENT
#   - The container runtime to use (example: podman|docker)
# - KVC_SOFTWARE_NAME
#   - The name of this module software bundle
# - KVC_KVER
#   - The kernel version we are targeting

# There are other environment variables that come from the config file
# delivered alongside this library. The expected variables are:
# - KMOD_CONTAINER_BUILD_CONTEXT
#   - A string representing the location of the build context
# - KMOD_CONTAINER_BUILD_FILE
#   - The name of the file in the context with the build definition
#     (i.e. Dockerfile)
# - KMOD_SOFTWARE_VERSION
#   - The version of the software bundle
# - KMOD_NAMES
#   - A space separated list kernel module names that are part of the
#     module software bundle and are to be checked/loaded/unloaded
source "/etc/kvc/${KVC_SOFTWARE_NAME}.conf"

# The name of the container image to consider. It will be a unique
# combination of the module software name/version and the targeted
# kernel version.
IMAGE="${KVC_SOFTWARE_NAME}-${KMOD_SOFTWARE_VERSION}:${KVC_KVER}"


touch /tmp/SOMETHING_WENT_THROUGH_LIB

display_message() {
    touch /tmp/DISPLAY_MESSAGE
	echo in DM
    msg_source=$1
    shift
    echo $msg_source: $@
    echo $msg_source: $@  >>/tmp/AURISTOR_CLIENT_LIB_MESSAGES
}

build_kmod_container() {
    display_message "build_kmod_container"  "Building ${IMAGE} kernel module container at image-registry.openshift-image-registry.svc:5000/auristor-client/${IMAGE}"
#    skopeo copy --dest-creds="builder:$TOKEN" --dest-tls-verify=false docker://moniker.auristor.com:5000/auristor-sro-kmod:latest docker://image-registry.openshift-image-registry.svc:5000/auristor-client/${IMAGE}
    display_message "build_kmod_container"  "skopeo completed"

    #kvc_c_build -t ${IMAGE}                              \
    #    --file ${KMOD_CONTAINER_BUILD_FILE}          \
    #    --label="name=${KVC_SOFTWARE_NAME}"          \
    #    --build-arg KVER=${KVC_KVER}                 \
        # --build-arg KMODVER=${KMOD_SOFTWARE_VERSION} \
    #    --build-arg KMOD_SOFTWARE_VERSION=${KMOD_SOFTWARE_VERSION} \
    #    ${KMOD_CONTAINER_BUILD_CONTEXT}

    # get rid of any dangling containers if they exist
    #display_message "build_kmod_container" "Checking for old kernel module images that need to be recycled"
    #rmi1=$(kvc_c_images -q -f label="name=${KVC_SOFTWARE_NAME}" -f dangling=true)
    # keep around any non-dangling images for only the most recent 3 kernels
    #rmi2=$(kvc_c_images -q -f label="name=${KVC_SOFTWARE_NAME}" -f dangling=false | tail -n +4)
    #if [ ! -z "${rmi1}" -o ! -z "${rmi2}" ]; then
    #    display_message "build_kmod_container" "Cleaning up old kernel module container builds"
    #    kvc_c_rmi -f $rmi1 $rmi2
    #fi
}

is_kmod_loaded() {
    module=${1//-/_} # replace any dashes with underscore
    if lsmod | grep "${module}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

build_kmods() {
return 0;
    if [ $(kvc_c_env) == "kubernetes" ]; then
        return 0
    fi

    # Check to see if it's already built
    if [ ! -z "$(kvc_c_images $IMAGE --quiet 2>/dev/null)" ]; then
        display_message "build_kmods" "The ${IMAGE} kernel module container is already built"
    else
        build_kmod_container
    fi

    # Sanity checks for each module to load
    for module in ${KMOD_NAMES}; do
        display_message "build_kmods" "Doing Sanity Check for: $module"
        module=${module//_/-} # replace any underscores with dash
        # Sanity check to make sure the built kernel modules were really
        # built against the correct module software version
        # Note the tr to delete the trailing carriage return
        x=$(kvc_c_run $IMAGE modinfo -F version "/lib/modules/${KVC_KVER}/extra/yfs/${module}.ko" | \
                                                                            tr -d '\r')
        display_message "build_kmods" "  ... KMOD_SOFTWARE_VERSION:  ${x} and comparing to ${KMOD_SOFTWARE_VERSION}"
        if [ "${x}" != "${KMOD_SOFTWARE_VERSION}" ]; then
            display_message "build_kmods"  "Module version mismatch within container. rebuilding ${IMAGE}"
            build_kmod_container
        fi
        # Sanity check to make sure the built kernel modules were really
        # built against the desired kernel version
        x=$(kvc_c_run $IMAGE modinfo -F vermagic "/lib/modules/${KVC_KVER}/extra/yfs/${module}.ko" | \
                                                                        cut -d ' ' -f 1)
        display_message "build_kmods" "  ... KVC_KVER:  ${x} and comparing to ${KVC_KVER}"
        if [ "${x}" != "${KVC_KVER}" ]; then
            display_message  "build_kmods" "Module not built against ${KVC_KVER}. rebuilding ${IMAGE}"
            build_kmod_container
        fi
    done
}

load_kmods() {
    display_message "load_kmods" "Loading kernel modules using the kernel module container..."
    display_message "load_kmods" "IMAGE:  ${IMAGE}"
    if [ ! -f /usr/bin/dracut ]; then
      touch /usr/bin/dracut
    fi
    chmod +x /usr/bin/dracut

    module="yfs"
    if is_kmod_loaded ${module}; then
        display_message "load_kmods" "Kernel module ${module} already loaded"
    else
        display_message "load_kmods" "ABOUT TO find ..."
        find /lib/modules/*/extra/yfs | grep .ko | weak-modules --add-modules --verbose --no-initramfs | tee >/tmp/LOAD_MODULES
        EXIT_CODE=$?
        display_message "load_kmods" "Exit Code: $EXIT_CODE" 

        display_message "load_kmods" "ABOUT TO modprobe -v yfs"
        insmod  /lib/modules/*/extra/yfs/yfs.ko >/tmp/INSMOD 2>/tmp/INSMOD_2 
        EXIT_CODE=$?
        display_message "load_kmods" "Exit Code: $EXIT_CODE" 

        display_message "load_kmods" "ABOUT TO afsd memcache"
        afsd   >/tmp/AFSD  2>/tmp/AFSD_2
        EXIT_CODE=$?
        display_message "load_kmods" "Exit Code: $EXIT_CODE" 
    fi

    display_message "load_kmods" "COMPLETE"
}

unload_kmods() {
    display_message "unload_kmods" "Unloading kernel modules..."
    module="yfs"
    if is_kmod_loaded ${module}; then
        # display_message "unload_kmods" "About to umount /afs"
        # unmount /afs
        # EXIT_CODE=$?
        display_message "unload_kmods" "Exit Code: $EXIT_CODE"

        display_message "unload_kmods" " modprobe -r yfs"
        modprobe -r yfs
        display_message "unload_kmods" " Returned from modprobe -r yfs"
        EXIT_CODE=$?
        display_message "unload_kmods" "Exit Code: $EXIT_CODE"
    else
        display_message "unload_kmods" "Kernel module ${module} already unloaded"
    fi

    # display_message "unload_kmods" "Dawdling 30 sec...."
    # sleep 30

    display_message "unload_kmods" "COMPLETED"  
}

wrapper() {
    display_message "wrapper" "Running userspace wrapper using the kernel module container..."
    # TODO kvc_c_run --privileged $IMAGE $@
}
