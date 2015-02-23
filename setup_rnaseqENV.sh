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

sailfish_name='Sailfish-0.6.3-Linux_x86-64'
sailfish_file='Sailfish-0.6.3-Linux_x86-64.tar.gz'
sailfish_source='https://github.com/kingsfordgroup/sailfish/releases/download/v0.6.3/'$sailfish_file
sailfish_path=$source_dir'/'$sailfish_name
git 
galaxy_path='/usr/local/galaxy/galaxy-dist'
galaxy_ini='universe_wsgi.ini'
galaxy_dep_dir='dependency_dir'
galaxy_admin='galaxy@galaxy.com'


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
        echo $PATH 
        echo PATH=\$PATH:$samtools_path/bin >> /etc/bashrc
        echo export PATH >> /etc/bashrc
        source /etc/bashrc
    else
        echo -e "samtools PATH already setting."
    fi

    echo " "
    echo -e ">>>>> end of samtools_prep ..."
}

sailfish_prep()
{
    echo -e ">>>>> start sailfish_prep ..."
    echo " " 
    cd $source_dir

    if [ -d $sailfish_path ];then
        echo -e "sailfish already downloaded."
    else
        echo -e "Download and Installing ..."
        wget $sailfish_source
        tar zxvf $sailfish_file
    fi

    if [ ! `echo $PATH | grep -e $sailfish_path/bin` ] ; then
        echo $PATH 
        echo PATH=\$PATH:$sailfish_path/bin >> /etc/bashrc
        echo export PATH >> /etc/bashrc
        source /etc/bashrc
    else
        echo -e "sailfish PATH already setting."
    fi

    if [ ! `echo $LD_LIBRARY_PATH | grep -e $sailfish_path/lib` ] ; then
        echo $LD_LIBRARY_PATH 
        echo LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$sailfish_path/lib >> /etc/bashrc
        echo export LD_LIBRARY_PATH >> /etc/bashrc
        source /etc/bashrc
    else
        echo -e "sailfish-lib in LD_LIBRARY_PATH already setting."
    fi

    echo " "
    echo -e ">>>>> end of sailfish_prep ..."
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
        sailfish_prep
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
