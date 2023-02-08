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
   echo "-----------------------------------";
    echo "Docker is installed.."
    echo "----------------------------------";
else
	read -p "Docker is not installed, do you want to install it?(y/n)" answer
	if [ $answer = "y" ]
	then
		echo "Instaling Docker....";
		echo "-----------------------------------";
		echo "Updating repositories...."; 
		sudo apt  update -y 1>/dev/null
		sleep 1
		echo "Installing docker....";
		sudo apt-get install docker.io -y 1>/dev/null 
		sudo apt-get install docker -y 1>/dev/null

	else
		echo "Good Bye ;-)";
	fi
    
fi

echo "------------------------------";
read -p "Do you have a container running with port 22 openned?(y/n)" answer
echo "------------------------------";
if [ $answer = "y" ]
then
	echo "Listing all contairners.....";
	echo " ";
	docker ps  --format "ID:   {{.ID}}   ,    NAME:     {{.Names}}  ,  IMAGE:     {{.Image}}"
	echo " ";
	echo "--------------------------------";
	echo "Give me the following data about the container:" 
	read -p "Container id: " container
	read -p "User for ssh: " user
	read -p "Password for ssh: " password
	echo "--------------------------------";
	echo "Installing openssh-server at the container";
	docker exec -it $container apt-get update -y 1>/dev/null
	docker exec -it $container apt-get install openssh-server -y 1>/dev/null
	echo "Installing systemctl and showing openssh status";
	docker exec -it $container apt-get install systemctl -y 1>/dev/null
	docker exec -it $container systemctl status ssh
	sleep 1
	echo "Adding user and password to container";
	
	docker exec -it $container adduser $user 
	
	echo "Starting openssh-server......"
	docker exec -it $container service ssh start 
	ip=$(docker inspect --format {{".NetworkSettings.IPAddress"}} $container)
	echo "--------------------------------";
	read -p "Do you want to connect to the container?: " answ
	ssh $user@$ip

	if [ $answ = "y"]
	then
		ssh $user@$ip
	else
		echo "$ip, $user, $password , $container";
	fi

else
	echo "---------------------------------";
	echo "Running a Docker container with Ubuntu image and port 22 opened..."
	echo "---------------------------------";
	sudo docker run 
fi
