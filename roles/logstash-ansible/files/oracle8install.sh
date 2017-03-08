#!/bin/bash 
set -e


#Update this variable to change th downloaded Java Version
JAVA_DOWNLOAD_VERSION="8u121"
JAVA_MAJOR_VERSION="8"
JAVA_MINOR_VERSION="121"
TMPDIR="/tmp"

#set temporary download location
if [[ -d $TMPDIR ]]; 
then
	cd "$TMPDIR" || { printf "Failed to cd to %s, EXITING.\n" "$TMPDIR" ;exit 1; }
else
	mkdir -p "$TMPDIR" || { printf "Directory %s does not exist , attempt to create it failed.\n EXITING!!\n" "$TMPDIR" ;exit 1; }
	cd "$TMPDIR" || { printf "Failed to cd to %s, EXITING.\n" "$TMPDIR" ;exit 1; }

fi

#download JDK
case $(uname -m) in

x86_64)

if [[ $PWD == $TMPDIR ]];
then
	wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_DOWNLOAD_VERSION-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-$JAVA_DOWNLOAD_VERSION-linux-x64.tar.gz" || { printf "Failed to download JDK, Exiting.\n" ; exit 1; }

java_download_filepath="$TMPDIR/jdk-$JAVA_DOWNLOAD_VERSION-linux-x64.tar.gz"

else
	printf "Expecting to be in directory /tmp ,current directory is %s instead.\n Exiting!!!\n" "$PWD"
	exit 1	
fi
;;

i686|i386)
if [[ $PWD == $TMPDIR ]];
then

	wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_MAJOR_VERSIONu$JAVA_MINOR_VERSION-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-$JAVA_MAJOR_VERSIONu$JAVA_MINOR_VERSION-linux-i586.tar.gz" || { printf "Failed to download JDK, Exiting.\n" ; exit 1; }

java_download_filepath="$TMPDIR/jdk-$JAVA_MAJOR_VERSIONu$JAVA_MINOR_VERSION-linux-i586.tar.gz"

else
	printf "Expecting to be in directory /tmp ,current directory is %s instead.\n Exiting!!!\n" "$PWD"
        exit 1
fi 
;;

*)

 printf "Unknown Arch %s, Exiting!!!\n" "$(uname -m)"
 exit 1
;;

esac

#extract java archivce
if [[ ! -d /opt/jdk ]];
then
	mkdir -p /opt/jdk || { printf "Failed to mkdir /opt/jdk , Exiting!!!\n" ; exit 1; }
	tar x -C /opt/jdk -f "$(basename $java_download_filepath)" || { printf "Failed to extract file %s to /opt/jdk/ , Exiting!!!\n" "$java_download_filepath" ; exit 1; }
else

tar x -C /opt/jdk -f "$(basename $java_download_filepath)" || { printf "Failed to extract file %s to /opt/jdk/ , Exiting!!!\n" "$java_download_filepath" ; exit 1; }

fi

update-alternatives --install /usr/bin/java java "/opt/jdk/jdk1.$JAVA_MAJOR_VERSION.0_$JAVA_MINOR_VERSION/bin/java" 100 || { printf "Failed to create symlink for java with update-alternatives , Exiting!!!\n" ; exit 1; 
update-alternatives --install /usr/bin/javac javac "/opt/jdk/jdk1.$JAVA_MAJOR_VERSION.0_$JAVA_MINOR_VERSION/bin/javac" 100 || { printf "Failed to create symlink for javac with update-alternatives , Exiting!!!\n" ; exit 1;

exit 0
