#!/usr/bin/bash
# Utilty script to handle install and update for rocm within a distrobox container init_hooks

REPO_UBUNTU="https://repo.radeon.com/amdgpu-install/6.3.3/ubuntu/noble/"
PACKAGE_UBUNTU="amdgpu-install_6.3.60303-1_all.deb"
REPO_ROCKY="https://repo.radeon.com/amdgpu-install/6.3.3/rhel/8.10/"
PACKAGE_ROCKY="amdgpu-install-6.3.60303-1.el8.noarch.rpm"
TEMP_DIR="/tmp/"
TEST_BIN="/usr/bin/rocminfo"

download_if_not_exists(){
    cd $TEMP_DIR
    if [ ! -f $2 ]; then
        echo "Download ${2} package not in cache"
        # Clear old amdgpu-install files if any exist in case we update
        sudo rm ./amdgpu-install*
        wget ${1}${2}
    else
        echo "${2} already in cache skip download"
    fi
}

install_rocm(){
    case $1 in
    "rocky")
        echo "Install ROCm for Rocky Linux"
        download_if_not_exists $REPO_ROCKY $PACKAGE_ROCKY
        sudo dnf install ${TEMP_DIR}$PACKAGE_ROCKY -y
        ;;
    "ubuntu")
        echo "Install ROCm for Ubuntu"
        download_if_not_exists $REPO_UBUNTU $PACKAGE_UBUNTU
        sudo apt install ${TEMP_DIR}$PACKAGE_UBUNTU -y
        ;;
    esac
}

install_rocm $1
# Always return 0 exit code to not break init_hooks
exit 0