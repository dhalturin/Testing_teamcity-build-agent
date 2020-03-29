#!/bin/bash

source .env

PACKER_BIN=./packer/bin/packer
FORCE=false

msg_usage() {
    echo -e "Automate build images with TeamCity agents\n"
    echo -e "Usage: ${0} [options] [arguments]\n"
    echo -e "Example:\n"
    echo -e "\t\$ ${0} -p\n"
    echo -e "Some of the options include:"
    echo -e "\t-b\tBuilding images. Arguments: all / linux / windows"
    echo -e "\t-c\tClean up. Shutdown vault server"
    echo -e "\t-f\tUse this flag for rebuild images"
    echo -e "\t-h\tThis message"
    echo -e "\t-p\tPreparation before building images. Download packer"
    exit
}

color_g() {
    echo -e "\033[1;32m${@}\033[0m"
}

color_r() {
    echo -e "\033[1;31m${@}\033[0m"
}

msg_failure() {
    color_r "Error: ${@}"
    exit 1
}

build() {
    case ${1} in
        all) build_linux && build_windows ;;
        linux) build_linux ;;
        windows ) build_windows ;;
        *) msg_failure "Incorrect argument" ;;
    esac

    cleanup
}

build_linux() {
    find ./packer/json/linux -type f | sort | while read json; do
        IMAGE_PATH=$(jq -r '.variables.vm_output + "/" + .variables.vm_name' ${json})

        if [ "${FORCE}" = "true" ]; then
            echo "Removing directory: ${IMAGE_PATH}"

            rm -rfv ${IMAGE_PATH}
        fi

        if [ -d ${IMAGE_PATH} ]; then
            color_g "Skip file: ${json}, directory exists: ${IMAGE_PATH}"

            continue
        fi

        echo "Validation json file: ${json}"
        ${PACKER_BIN} validate ${json} || break

        echo "Building from json file: ${json}"
        ${PACKER_BIN} build ${json} || break
    done
}

build_windows() {
    echo build windows
}

check_command() {
    ERR=0

    for i in "${@}"; do
        echo -n "Checking ${i}.. "

        command -v ${i} > /dev/null

        if [ "${?}" -eq "0" ]; then
            color_g "exist"
        else
            color_r "not found"
            ERR=1
        fi
    done

    if [ "${ERR}" -eq "1" ]; then
        msg_failure "Not all commands were found"
    fi
}

download_packer() {
    if [ ! -f ${PACKER_BIN} ]; then
        echo -n "Downloading packer.. "

        curl -so  /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_${OS}_${ARCH}.zip
        if [ "${?}" -eq "0" ]; then
            color_g "success"
        else
            msg_failure "failure"
        fi

        echo -n "Unarchive packer.. "

        unzip /tmp/packer.zip -d ./packer/bin > /dev/null
        if [ "${?}" -eq "0" ]; then
            color_g "success"
        else
            msg_failure "failure"
        fi
    fi
}

prepare() {
    check_command curl unzip jq VBoxManage

    case $(uname -m) in
        x86_64) ARCH=amd64 ;;
        i386) ARCH=386 ;;
        *) msg_failure "Wrong architecture type" ;;
    esac

    OS=$(uname | tr '[:upper:]' '[:lower:]')

    download_packer
}

cleanup() {
    if [ -f ./vault/.pid_file ]; then
        cat ./vault/.pid_file | xargs kill
    fi
}

set_force() {
    FORCE=true
}

if [ -z "${*}" ]; then
    msg_usage
fi

while getopts ":b:cfhp" opt; do
    case $opt in
        b) build ${OPTARG} ;;
        c) cleanup ;;
        f) set_force ;;
        h) msg_usage ;;
        p) prepare ;;
        *) msg_failure "An unknown argument was received" ;;
    esac
done
