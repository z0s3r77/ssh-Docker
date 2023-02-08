#!/bin/bash
echo "----------------------------------";
echo "Checking if it's Docker installed on the LocalHost...";
echo "----------------------------------";
if [ $(whoami) != "root" ]; then


	echo " -------------------------------- ";
	echo "You must to be ROOT";
	echo "Execute "sudo -i" and turn to exec the program";
	echo " -------------------------------- ";
	exit 1

else

	echo " ---------------------------------";
	echo " Running Script ";
	echo " ---------------------------------";


fi

sleep 2

if [ $(command -v docker) ]
then
	echo " ";
   	echo "-----------------------------------";
    	echo "Docker is installed.."
    	echo "-----------------------------------";
	echo " ";
else
	read -p "Docker is not installed, do you want to install it?(y/n)" answer
	if [ $answer = "y" ]
	then
		echo "Instaling Docker....";
		echo "-----------------------------------"; 
		sudo apt  update -y 1>/dev/null
		echo  ' ##########                (25%)\r';
		sleep 1
		sudo apt-get install docker.io -y 1>/dev/null
	       	echo  ' ################          (65%)\r';	
		sudo apt-get install docker -y 1>/dev/null
		echo  ' ######################### (100%)\r';

	else
		echo "  ";
		echo "Good Bye ;-)";
		echo " ";
		exit
	fi
    
fi
echo " ";
echo "------------------------------";
read -p "Do you have a container running with port 22 openned?(y/n)" answer
echo "------------------------------";
echo " ";
if [ $answer = "y" ]
then
	echo "Listing contairners with port 22 opened.....";
	echo " ";
	docker ps  --format "ID: {{.ID}} , NAME: {{.Names}} ,  IMAGE: {{.Image}} , PORTS:  {{.Ports}}" | grep --color=never "22/tcp" | grep -e NAME -e IMAGE -e ID -e PORTS
	echo " ";
	echo "--------------------------------";
	echo "Give me the following data about the container:" 
	read -p "Container id: " container
	read -p "User for ssh: " user
	read -p "Password for ssh: " password
	echo "--------------------------------";
	echo "Installing openssh-server at the container";
	echo " ";
	docker exec -it $container apt-get update -y 1>/dev/null
	echo  ' #######                   (25%)\r'
	docker exec -it $container apt-get install openssh-server -y 1>/dev/null
	echo  ' ############              (50%)\r'
	docker exec -it $container apt-get install systemctl -y 1>/dev/null
	echo  ' ###################       (75%)\r'
	docker exec -it $container systemctl status ssh 1>/dev/null
	echo  ' ##########################(100%)\r'
	sleep 1
	echo "--------------------------------- "
	echo "Adding user and password to container";
	docker exec -it $container adduser $user 
	echo " "
	echo " "
	echo "Starting openssh-server......"
	docker exec -it $container service ssh start 1>/dev/null
	echo "--------------------------------";
	read -p "Do you want to connect to the container?(y/n): " answ

if [ $answ = "y" ]
then
	ip=$(docker inspect --format {{".NetworkSettings.IPAddress"}} $container)
	ssh $user@$ip
else
	echo "  ";
	echo "--------------------------------";
	echo "openssh-server is now installed at the container $container , with the user $user, don't forget your password ;-)";
	echo "--------------------------------";
	echo " ";
fi

else
	echo " ";
	clear
	echo " ";
	read -p "What do you want to do?:
	1) Create a ubuntu container and open 22
	2) Expose port 22 in some container 
	" answ

case $answ in
"1")
	echo "Opción 1";
;;
"2")
	echo " " ;
	echo "--------------------------------";
	echo " Listing all containers.....";
	echo "--------------------------------";
	echo " ";
	docker ps  --format "ID: {{.ID}} , NAME: {{.Names}} ,  IMAGE: {{.Image}} , PORTS:  {{.Ports}}" | grep --color=never "22/tcp" | grep -e NAME -e IMAGE -e ID -e PORTS
	echo " ";
	echo "--------------------------------";
        echo "Give me the following data about the container:" 
        read -p "Container id: " container
        read -p "User for ssh: " user
        read -p "Password for ssh: " password
        echo "--------------------------------";
	echo " ME explotó la cabeza ";

;;
esac




	echo "---------------------------------";
	echo "Running a Docker container with Ubuntu image and port 22 opened..."
	echo "---------------------------------";
 
fi
