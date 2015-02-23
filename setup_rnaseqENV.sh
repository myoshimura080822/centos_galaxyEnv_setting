#!/bin/bash

echo "################################################"
echo " setup_rnaseqENV started ..."
echo "################################################"
echo " "

clear
export who=`whoami`
SCRIPTDIRECTORY="$(pwd)"
clear

# output logDir
DATE=`date '+%F_%R'`
LOGDIR=./log/rnaseqENV
LOGFILE=$LOGDIR/$DATE.log

source_dir='/usr/local/src'

lib_dir='/usr/local/lib'
bam_dir='/usr/local/include/bam'

samtools_name='samtools-1.2'
samtools_file='samtools-1.2.tar.bz2'
samtools_source='https://github.com/samtools/samtools/releases/download/1.2/'$samtools_file
samtools_path=$source_dir'/'$samtools_name



recipe_url='https://github.com/myoshimura080822/galaxy_sam_strt_cookbooks.git'
recipe_dir='galaxy_sam_strt_cookbooks'

current_path=`pwd`

galaxy_path='/usr/local/galaxy/galaxy-dist'
galaxy_ini='universe_wsgi.ini'
galaxy_dep_dir='dependency_dir'
galaxy_admin='galaxy@galaxy.com'



chefdk_prep()
{
    echo -e ">>>>> start chefdk_prep ..."
    echo " " 
    cd $source_dir
    if [ -d $chefdk_path ];then
        echo -e "chefdk already downloaded."
    else
        echo -e "Download and Installing ..."
        wget $chefdk_url
        rpm -i $chefdk_rpm
        chef -v

        if [ ! `echo $PATH | grep -e $chefdk_path` ] ; then
            PATH=$PATH:$chefdk_path
            export PATH
        fi
    fi
    echo " "
    echo -e ">>>>> end of chef_prep ..."
}




nginx_prep()
{
    echo -e ">>>>> start nginx_prep ..."
    echo " "
    if [ ! -d /etc/nginx/conf.d ]; then
        yum -y install nginx
        chkconfig nginx on
    else
        echo "nginx already installed."
    fi
    
    if [ -f /etc/nginx/conf.d/default.conf ]; then
        mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf_bk
    fi
    cp ${current_path}/nginx_conf/default.conf /etc/nginx/conf.d/
    service nginx start    
    echo " "
    echo -e ">>>>> end of nginx_prep ..."
}

setting_galaxy()
{

    echo -e ">>>>> start setting_galaxy ..."
    echo " "
    
    if [ -d $galaxy_path ]; then
        if [ ! -d $galaxy_path/$galaxy_dep_dir ]; then
            mkdir $galaxy_path/$galaxy_dep_dir
        fi
        
        sed -i -e "s/#admin_users/admin_users/" $galaxy_path/$galaxy_ini
        sed -i -e "s/admin_users = \(.*\)/admin_users = $galaxy_admin/" $galaxy_path/$galaxy_ini
        sed -i -e "s/#tool_dependency_dir/tool_dependency_dir/" $galaxy_path/$galaxy_ini
        sed -i -e "s/tool_dependency_dir = \(.*\)/tool_dependency_dir = $galaxy_dep_dir/" $galaxy_path/$galaxy_ini
    else
        echo "galaxy-dist Dir not found."
    fi

    echo " "
    echo -e ">>>>> end of setting_galaxy..."
}




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

r_prep()
{
    echo -e ">>>>> start r_prep ..."
    echo " "

    R --vanilla < install_rnaseqENV.R

    echo " "
    echo -e ">>>>> end of r_prep ..."
}

python_prep()
{
    echo -e ">>>>> start python_prep ..."
    echo " "
    
    pip install python-dateutil
    pip install bioblend
    pip install pandas
    pip install grequests
    pip install GitPython

    pip install pip-tools
    pip-review

    echo " "
    echo -e ">>>>> end of python_prep ..."
}

samtools_prep()
{
    echo -e ">>>>> start samtools_prep ..."
    echo " " 
    cd $source_dir
    if [ -d $samtools_path ];then
        echo -e "samtools already downloaded."
    else
        echo -e "Download and Installing ..."
        wget $samtools_source
        tar jxvf $samtools_file
        cd $samtools_name
        make
        make install

        cp samtools /usr/local/bin/
    fi

    if [ ! -f $lib_dir/libbam.a ];then
        cp libbam.a $lib_dir
    else
        echo -e "samtools libbam.a already copied."
    fi

    if [ ! -d $bam_dir ];then
        mkdir $bam_dir
        cp *.h $bam_dir
    else
        echo -e "samtools bam-dir already exists."
    fi

    if [ ! `echo $PATH | grep -e $samtools_path/bin` ] ; then
        PATH=$PATH:$samtools_path/bin
        export PATH
        echo $PATH >> /etc/bashrc
        echo export PATH >> /etc/bashrc
    fi

    echo " "
    echo -e ">>>>> end of samtools_prep ..."
}


main()
{
    c=0
    while [ $c -le 0 ]
    do
        r_prep
        echo
        python_prep
        echo
        samtools_prep
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
echo " setup_rnaseqENV all done." 
echo "################################################"
