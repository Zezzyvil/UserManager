#!/bin/sh

echo "Setup script running ...." 

LOGFILE=/var/log/UserManagerAppSetup.log
APP_ENV=webapp/.env

# detect Operating System
lsb_dist=$( echo "$(. /etc/os-release && echo "$ID")" )
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

echo "$lsb_dist platform detected"
#exit 1


#checks if command exists
command_exists() {
	command -v "$@" > /dev/null 2>&1
}

#installs docker-compose and pip that facilitates the installation
install_docker_compose(){
	#assert python is installed
	if ! command_exists python; then
		echo "Please install python and re-run script"
		exit 1
	fi

	#install pip if not installed
	if ! command_exists pip; then
		install_package python-pip
	fi

	#install docker-compose
		sudo pip install docker-compose
}

#sets up docker and docker-compose
docker_setup(){
	#install docker if not installed

    if ! command_exists docker
    	then
    	{
    	   wget -qO- https://get.docker.com/ | sh
    	}||{
    		echo "Platform not supported by docker installation script. Manually install docker and then run this script again"
    		exit 1
    	}
    	else
    		echo "docker installed at $(which docker)" >> $LOGFILE
    fi

    #install docker compose if not installed
    if ! command_exists docker-compose
        then
    	    install_docker_compose
        else 
        	echo "docker-compose installed at $(which docker-compose)" >> $LOGFILE

    fi
}

#installes a given package the right way for the distrinution
#takes one parameter, the package to install
install_package(){
	case "$lsb_dist" in
		centos|fedora)
			sudo yum install $1 -y
		;;
		*)
			{
			 sudo apt-get install $1 -y
			}||{
				echo "[x] error can't auto install packages: Manually install $1 and try again"
				echo "installing package for unknown platform $lsb_dist " >> $LOGFILE
				exit 1
			}

	esac
}

#create .env file 
{
cat > $APP_ENV << XEOF
PORT=3000
DB_URL='mongodb://db:27017/userManagerApp'
XEOF
}||{
	echo "Creating $APP_ENV [failed]: ensure webapp folder exists and is writeable"
	echo "Creating $APP_ENV [failed]" >> $LOGFILE
	exit 1
}

sudo chmod 666 $APP_ENV

#setup docker and docker-compose
docker_setup

sudo docker-compose -p myApp up