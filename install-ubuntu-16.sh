#!/usr/bin/env bash
#===============================================================================
# Ubuntu 14.04LTS Docker Installation Script
#===============================================================================
# Maintainer: Matt Hartstonge <matt@mykro.co.nz>
# Description:
#   Checks that your kernel version is up to scratch, otherwise prints errors.
#   If Kernel is all good, will go ahead and do an automated install.
#
#-------------------------------------------------------------------------------

function install_repo_keys(){
    sudo apt-key adv \
        --keyserver hkp://p80.pool.sks-keyservers.net:80 \
        --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

    OS=$(lsb_release -cs)
    sudo touch /etc/apt/sources.list.d/docker.list
    if [ "$OS" == "precise" ]; then
        sudo echo "deb https://apt.dockerproject.org/repo ubuntu-precise main" \
            > /etc/apt/sources.list.d/docker.list
    fi
    if [ "$OS" == "trusty" ]; then

        sudo echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" \
            > /etc/apt/sources.list.d/docker.list
    fi
    if [ "$OS" == "vivid" ]; then
        sudo echo "deb https://apt.dockerproject.org/repo ubuntu-vivid main" \
            > /etc/apt/sources.list.d/docker.list
    fi
    if [ "$OS" == "wily" ]; then
        sudo echo "deb https://apt.dockerproject.org/repo ubuntu-wily main" \
            > /etc/apt/sources.list.d/docker.list
    fi
}

function install_docker(){
    printf "${COL_CYN}Installing apt keys...${COL_NUL}\n" \
    && install_repo_keys \
    && printf "${COL_GRN}apt keys installed!${COL_NUL}\n" \
    && printf "${COL_CYN}Installing additional virtual machine drivers...${COL_NUL}\n" \
    && sudo apt update \
    && sudo apt-get purge lxc-docker \
    || sudo apt-get install -y linux-image-extra-$(uname -r) \
    && printf "${COL_GRN}Additional virtual machine drivers installed!${COL_NUL}\n" \
    && printf "${COL_CYN}Installing Docker...${COL_NUL}\n" \
    && sudo apt-get update \
    && sudo apt-get install -y docker-engine \
    && printf "${COL_GRN}Docker Installed!${COL_NUL}\n" \
    && printf "${COL_MAG}Starting Docker...${COL_NUL}\n" \
    
    if ! sudo service docker start; then
        printf "${COL_CYN}Docker didn't seem to start..${COL_NUL}\n"
        printf "${COL_CYN}Try running 'service docker start' manually${COL_NUL}\n"
    else
        printf "${COL_GRN}Docker Started!${COL_NUL}\n"
        sudo docker run hello-world
    fi
}

function kernel_fail(){
    printf "$\n\n{COL_RED}Kernel Installed cannot run docker, please update kernel!${COL_NUL}\n\n"
    printf "Kernel Version Needed: ${COL_MAG}>3.10${COL_NUL}\n"
    printf "Kernel Version Current: ${COL_MAG}${KERNEL_MAJOR}.${KERNEL_MINOR}${COL_NUL}\n"
    exit 1
}

function verify_kernel(){
    if [ ${KERNEL_MAJOR} -le 2 ]; then
        kernel_fail
    fi
    if [ ${KERNEL_MAJOR} -eq 3 ]; then
        if [ ${KERNEL_MINOR} -le 12 ]; then
            kernel_fail
        fi
    fi
    printf "${COL_GRN}Kernel verified as: ${COL_MAG}${KERNEL_MAJOR}.${KERNEL_MINOR}${COL_NUL}\n\n"
}

function set_envars(){
    SCRIPT_VERSION="0.2"

    # Make some pretty printf statements
    COL_RED='\033[0;31m'
    COL_GRN='\033[0;32m'
    COL_MAG='\033[0;35m'
    COL_CYN='\033[0;36m'
    COL_NUL='\033[0m'

    # Get kernel information
    KERNEL_MAJOR="$(awk -F . '{print $1}' <<< "$(uname -r)")"
    KERNEL_MINOR="$(awk -F . '{print $2}' <<< "$(uname -r)")"
}

function welcome(){
    printf "\n\n${COL_GRN}+===================================+${COL_NUL}\n" \
    && printf "${COL_GRN}|   Docker Installer Version ${SCRIPT_VERSION}    |${COL_NUL}\n" \
    && printf "${COL_GRN}+===================================+${COL_NUL}\n\n"
}

function main(){
    set_envars
    welcome
    verify_kernel
    install_docker
}

main
