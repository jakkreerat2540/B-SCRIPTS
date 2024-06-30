#!/bin/bash

install_ubuntu () {
    apt -y update && apt -y upgrade
    apt -y install git vim net-tools zsh  wget unzip
    wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    mv install.sh zsh-install.sh
    yes | bash zsh-install.sh
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(git)/plugins=( git zsh-syntax-highlighting zsh-autosuggestions)/g' ~/.zshrc
    echo 'ENABLE_CORRECTION=”true”' >> ~/.zshrc
    chsh -s $(which zsh)

}


install_centos () {
    yum -y update && yum -y upgrade
    yum -y install git vim net-tools zsh  wget unzip
    wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    mv install.sh zsh-install.sh
    yes | bash zsh-install.sh
    rm -rf install.sh
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    chsh -s $(which zsh)
    sed -i 's/plugins=(git)/plugins=( git zsh-syntax-highlighting zsh-autosuggestions )/g' ~/.zshrc
    echo "ENABLE_CORRECTION=”true”" >> ~/.zshrc
    zsh

}

install_poshthemes () {
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    chmod +x /usr/local/bin/oh-my-posh
    mkdir ~/.poshthemes
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
    unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
    chmod u+rw ~/.poshthemes/*.json
    rm ~/.poshthemes/themes.zip
    echo  'eval "$(oh-my-posh --init --shell zsh --config  /root/.poshthemes/night-owl.omp.json)" ' >> ~/.zshrc
}


main (){

    os=`cat /etc/os-release | grep  "^ID="`
    osversion=`echo $os |  sed 's/"//g' | sed 's/ID=//g'`
    if [ $osversion == "ubuntu" ]; then
        read -p "Do you want to install poshthemes? [y/n] " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_ubuntu
            install_poshthemes
        else
            install_ubuntu
        fi
    elif [ $osversion == "centos" ] || [ $osversion == "almalinux" ]; then
        read -p "Do you want to install poshthemes? [y/n] " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_centos
            install_poshthemes
        else
            install_centos
        fi
    elif [ $osversion == "rocky" ]; then
        read -p "Do you want to install poshthemes? [y/n] " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_centos
            install_poshthemes
        else
            install_centos
        fi
    elif [ $osversion == "fedora" ]; then
        read -p "Do you want to install poshthemes? [y/n] " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_centos
            install_poshthemes
        else
            install_centos
        fi
    elif [ $osversion == "debian" ]; then
        read -p "Do you want to install poshthemes? [y/n] " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_ubuntu
            install_poshthemes
        else
            install_ubuntu
        fi
    elif [ $osversion == "rhel" ]; then
        read -p "Do you want to install poshthemes? [y/n] " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_centos
            install_poshthemes
        else
            install_centos
        fi
    else
        echo "OS not supported"
    fi

}


main
