#!/bin/bash

echo "################################################"
echo " setup_galaxyENV started ..."
echo "################################################"
echo " "

clear
export who=`whoami`
SCRIPTDIRECTORY="$(pwd)"
clear

# output logDir
DATE=`date '+%F_%R'`
LOGDIR=./log/galaxyENV
LOGFILE=$LOGDIR/$DATE.log

source_dir='/usr/local/src'

git230_source_url='https://www.kernel.org/pub/software/scm/git'
_git230_package='git-2.3.0'
_git230_gz_file='git-2.3.0.tar.gz'

zsh_source_url='http://sourceforge.net/projects/zsh/files/zsh/5.0.7'
_zsh_package='zsh-5.0.7'
_zsh_gz_file='zsh-5.0.7.tar.gz'

# methods
create_dir()
{
    if [ ! -d $1 ]; then
        echo -e "Creatind direcorty..."
        mkdir -pv $1
    else
        echo -e "$1 already exist...continuing"
    fi
}

install_packages()
{
    echo -e ">>>>> start install_packages ..."
    echo " "
    
    # Add preq-repos
    rpm -ihv http://ftp.riken.jp/Linux/fedora/epel/6/i386/epel-release-6-8.noarch.rpm

    yum -y update
    yum -y groupinstall 'Development Tools'
    yum -y install zlib-devel openssl-devel ncurses-devel libffi-devel libxml2-devel libcurl-devel curl-devel 
    yum -y install tree tar wget perl-ExtUtils-MakeMaker asciidoc xmlto curl libcurl libxml2
    yum -y installR

    echo " "
    echo -e ">>>>> end of install_packages ..."
}

git230_prep()
{
    echo -e ">>>>> start git230_prep ..."
    echo " " 
    cd $source_dir
    if [ -d $source_dir/$_git230_package ];then
        echo -e $_git230_package" already downloaded."
    else
        echo -e "Remove old version ..."
        yum remove -y git
        echo -e "Download and Installing ..."
        wget $git230_source_url/$_git230_gz_file &> /dev/null
        tar zxvf $_git230_gz_file
        cd $source_dir/$_git230_package
        ./configure --with-command-group=nagcmd --prefix=/usr/local
        make all
        make install
    fi
    echo " "
    echo -e ">>>>> end of git230_prep ..."
}

zsh_prep()
{
    echo -e ">>>>> start zsh_prep ..."
    echo " "
    cd $source_dir
    if [ ! -f /etc/zshrc ]; then
        echo -e "Download and Installing ..."
        wget $zsh_source_url/$_zsh_gz_file &> /dev/null
        tar zxvf $_zsh_gz_file
        cd $source_dir/$_zsh_package
        ./configure --without-tcsetpgrp
        make
        make install
    else
        echo "zsh already installed."
    fi
    echo " "
    echo -e ">>>>> end of zsh_prep ..."
}

vim_prep()
{
    echo -e ">>>>> start vim_prep ..."
    echo " "
    if [ ! -f /etc/vimrc ]; then
        yum -y install vim
    else
        echo "vim already installed."
    fi
    echo " "
    echo -e ">>>>> end of vim_prep ..."
}

main()
{
    c=0
    while [ $c -le 0 ]
    do
        install_packages
        echo
        git230_prep
        echo
        zsh_prep
        echo
        vim_prep
        echo
        (( c++ ))
    done
}

if [[ $who == "root" ]]; then
    create_dir $LOGDIR
    {
        main
    } >> $LOGFILE 2>&1
else
    echo -e "You must be root to run this script."
fi

echo " "
echo "################################################"
echo " setup_galaxyENV all done." 
echo "################################################"
