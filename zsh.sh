#!/bin/bash

install_common_packages() {
    # Common packages for all distributions
    apt_or_yum=$1
    $apt_or_yum -y update && $apt_or_yum -y upgrade
    $apt_or_yum -y install git vim net-tools zsh wget unzip
    wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O zsh-install.sh
    yes | bash zsh-install.sh
    rm -f zsh-install.sh
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc
    echo 'ENABLE_CORRECTION="true"' >> ~/.zshrc
    chsh -s $(which zsh)
}

install_poshthemes() {
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    chmod +x /usr/local/bin/oh-my-posh
    mkdir -p ~/.poshthemes
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
    unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
    chmod u+rw ~/.poshthemes/*.json
    rm ~/.poshthemes/themes.zip
    echo 'eval "$(oh-my-posh --init --shell zsh --config ~/.poshthemes/night-owl.omp.json)"' >> ~/.zshrc
}

main() {
    os=$(grep "^ID=" /etc/os-release | sed 's/ID=//g' | tr -d '"')
    
    if [[ "$os" == "ubuntu" || "$os" == "debian" ]]; then
        package_manager="apt"
    elif [[ "$os" == "centos" || "$os" == "almalinux" || "$os" == "rocky" || "$os" == "fedora" || "$os" == "rhel" ]]; then
        package_manager="yum"
    else
        echo "OS not supported"
        exit 1
    fi

    install_common_packages $package_manager

    read -p "Do you want to install poshthemes? [y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_poshthemes
    fi

    zsh
}

main