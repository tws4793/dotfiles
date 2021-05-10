#!/usr/bin/env sh

sub_help(){
    echo "Usage: notebook <subcommand> [options]\n"
    echo "Subcommands:"
    echo "    start"
    echo "    stop"
    echo "    sh"
    echo "    location"
    echo ""
}

sub_start() {
    local devhome=$HOME/dev
    local nbhome="/home/jovyan/work"

    # local nbname = ${1:-notebook}
    
    podman run \
        --name ${1:-notebook} \
        --detach \
        --rm \
        --env GRANT_SUDO=yes \
        --env JUPYTER_ENABLE_LAB=yes \
        --env RESTARTABLE=yes \
        --env DISPLAY \
        --env NB_UID=$(id -u) \
        --env NB_GID=$(id -g) \
        --user root \
        --publish 8888:8888 \
        --volume $devhome:$nbhome \
        --workdir $nbhome \
        jupyter/tensorflow-notebook

    sleep 3s

    podman exec -it notebook bash -c \
        "sudo apt update; \
        sudo apt upgrade -y; \
        sudo apt install -y exiftool"
}

sub_stop() {
    podman stop notebook
}

sub_sh() {
    podman exec -it notebook bash
}

sub_location() {
    podman exec -it notebook jupyter server list
}

subcommand=$1
case $subcommand in
    "" | "-h" | "--help")
        sub_help
        ;;
    *)
        shift
        sub_${subcommand} $@
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' is not a know subcommand." >&2
            exit 1
        fi
        ;;
esac
