#!/bin/bash

echo "################################################"
echo " setup_samstrtENV started ..."
echo "################################################"
echo " "

clear
export who=`whoami`
SCRIPTDIRECTORY="$(pwd)"
clear

# output logDir
DATE=`date '+%F_%R'`
LOGDIR=./log/samstrtENV
LOGFILE=$LOGDIR/$DATE.log

source_dir='/usr/local/src'

chefdk_url='https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chefdk-0.4.0-1.x86_64.rpm'
chefdk_path='/opt/chefdk/embedded/bin'

recipe_url='https://github.com/myoshimura080822/galaxy_sam_strt_settingenv.git'
recipe_dir='galaxy_sam_strt_settingenv'

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

chefdk_prep()
{
    echo -e ">>>>> start chefdk_prep ..."
    echo " " 
    cd $source_dir
    if [ -d $chefdk_path ];then
        echo -e "chefdk already downloaded."
    else
        echo -e "Download and Installing ..."
        yum -y install $chefdk_url

        if [ ! `echo $PATH | grep -e $chefdk_path` ] ; then
            PATH=$PATH:$chefdk_path
            export PATH
        fi
    fi
    echo " "
    echo -e ">>>>> end of chef_prep ..."
}

exec_chef_solo()
{
    echo -e ">>>>> start exec_chef_solo ..."
    echo " "
    cd $source_dir
    if [ -d $recipe_dir ];then
        git clone https://github.com/myoshimura080822/galaxy_sam_strt_settingenv.git
        cd $recipe_dir
        chef-solo -c solo.rb -j ./localhost.json
    else
        echo -e "galaxy-cookbook already downloaded."
    fi
    echo " "
    echo -e ">>>>> end of exec_chef_solo ..."
}

r_prep()
{
    echo -e ">>>>> start r_prep ..."
    echo " "

    R --vanilla < install_samstrt.R

    echo " "
    echo -e ">>>>> end of r_prep ..."
}

nginx_prep()
{
    echo -e ">>>>> start nginx_prep ..."
    echo " "
    if [ ! -f /etc/nginx/conf.d ]; then
        yum -y install nginx
        chkconfig nginx on
    else
        echo "nginx already installed."
    fi
    echo " "
    echo -e ">>>>> end of nginx_prep ..."
}

main()
{
    c=0
    while [ $c -le 0 ]
    do
        r_prep
        echo
        chefdk_prep
        echo
        exec_chef_solo
        echo
        #nginx_prep
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
echo " setup_samstrtENV all done." 
echo "################################################"
