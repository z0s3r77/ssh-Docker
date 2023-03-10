#!/bin/bash
#Comprobación de que el usuario es root
clear
echo "----------------------------------";
echo "Checking if it's Docker installed on the LocalHost...";
echo "----------------------------------";
if [ $(whoami) != "root" ]; then

	echo " -------------------------------- ";
	echo "You must to be ROOT";
	echo "Execute "sudo su" and turn to exec the program";
	echo " -------------------------------- ";
	exit 1

else

	echo " ---------------------------------";
	echo " Running Script ";
	echo " ---------------------------------";


fi
sleep 2


#Compración de que Docker está instalado
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




# A continuación pregunta si hay un contenedor iniciado con el puerto 22 abierto
####### En caso de haberlo, lista los contenedores, el usuario selecciona un contenedor y introduce un usuario y contraseña.
####### A continuación el script instala todo el arsenal y por último pregunta si el usuario quiere entrar o no al contenedor.
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
	clear
	echo "--------------------------------";
	echo "Starting openssh-server......"
	docker exec -it $container service ssh start 1>/dev/null
	echo "--------------------------------";
	read -p "Do you want to connect to the container?(y/n): " answ

	if [ $answ = "y" ]
	then
		ip=$(docker inspect --format {{".NetworkSettings.IPAddress"}} $container)
		ssh-keygen -f "/root/.ssh/known_hosts" -R "$ip"
		ssh $user@$ip
	else
		echo "  ";
		echo "--------------------------------";
		echo "openssh-server is now installed at the container $container , with the user $user, don't forget your password ;-)";
		echo "--------------------------------";
		echo " ";
	fi

else





# Este es el caso en el que usuario no tiene un contenedor con el puerto 22 abierto:
##### Se le pregunta, si quiere abrir el puerto 22 en un contenedor existente o si quiere crear un contenedor desde 0

	echo " ";
	clear
	echo " ";
	read -p "What do you want to do?:
	1) Create a ubuntu container and open 22
	2) Expose port 22 in some container 
	" answ

case $answ in
"1")
	
	echo "Give me the following data about the container:"
        read -p "Container Name: " name
        read -p "User for ssh: " user
        read -p "Password for ssh: " password
	echo "You must to write 'exit'";
	#Cambiar el puerto cada vez que se ejecute el script
	docker run -i -p 32771:22 --name $name ubuntu
	docker start $name 

	echo "--------------------------------- ";
        echo "Installing openssh-server at the container";
        echo " ";
        docker exec -it $name apt-get update -y 1>/dev/null
        echo  ' #######                   (25%)\r'
        docker exec -it $name apt-get install openssh-server -y 1>/dev/null
        echo  ' ############              (50%)\r'
        docker exec -it $name apt-get install systemctl -y 1>/dev/null
        echo  ' ###################       (75%)\r'
        docker exec -it $name systemctl status ssh 1>/dev/null
        echo  ' ##########################(100%)\r'
        sleep 1
        echo "--------------------------------- ";
        echo "Adding user and password to container";
        docker exec -it $name adduser $user
        echo " "
        echo " "
        echo "Starting openssh-server......"
        docker exec -it $name service ssh start 1>/dev/null
        echo "--------------------------------- ";
        read -p "Do you want to connect to the container?(y/n): " answ


	if [ $answ = "y" ]
	then
        	ip=$(docker inspect --format {{".NetworkSettings.IPAddress"}} $name)
		ssh-keygen -f "/root/.ssh/known_hosts" -R "$ip"
        	ssh $user@$ip
	else
        	echo "  ";
        	echo "--------------------------------";
        	echo "openssh-server is now installed at the container $name , with the user $user, don't forget your password ;-)";
        	echo "--------------------------------";
        	echo " ";
	fi
;;



#En este caso, se seleccionará un contenedor cualquiera y se le expondrá el puerto 22.
#Importante mencionar que durante el proceso, el servicio de Docker se detendrá.
"2")
	echo " " ;
	echo "--------------------------------";
	echo " Listing all containers.....";
	echo "--------------------------------";
	echo " ";
	docker ps -a  --format "ID: {{.ID}} , NAME: {{.Names}} ,  IMAGE: {{.Image}} , PORTS:  {{.Ports}}" | grep -e NAME -e IMAGE -e ID -e PORTS
	
	echo " ";
	echo "--------------------------------";
        echo "Give me the following data about the container:" 
        read -p "Container id: " container
        read -p "User for ssh: " user
        read -p "Password for ssh: " password
	read -p "Port from host: " port
        echo "--------------------------------";

	containerID=$(docker inspect --format {{".Id"}} $container)



	systemctl stop docker.socket
	systemctl stop docker

	content=$(echo $content)

	jq --arg port "$port" '.PortBindings |= . + {"22/tcp":[{"HostIp":"","HostPort":$port}]}' /var/lib/docker/containers/$containerID/hostconfig.json > temp.json && mv temp.json /var/lib/docker/containers/$containerID/hostconfig.json
	
	chmod 777 /var/lib/docker/containers/$containerID/config.v2.json

	jq '.Config.ExposedPorts |= . + {"22/tcp":{}}' /var/lib/docker/containers/$containerID/config.v2.json > temp3.json && mv temp3.json /var/lib/docker/containers/$containerID/config.v2.json


	systemctl start docker.socket	
	systemctl start docker
	
	docker start $containerID


	echo "---------------------------------";
	echo " ";
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
	echo "--------------------------------";
        echo "Starting openssh-server......"
        docker exec -it $container service ssh start 1>/dev/null
        echo "--------------------------------";
        read -p "Do you want to connect to the container?(y/n): " answ


	if [ $answ = "y" ]
	then
        	ip=$(docker inspect --format {{".NetworkSettings.IPAddress"}} $container)
    
		ssh-keygen -f "/root/.ssh/known_hosts" -R "$ip"
    		ssh $user@$ip
	else
        echo "  ";
        echo "--------------------------------";
        echo "openssh-server is now installed at the container $container , with the user $user, don't forget your password ;-)";
        echo "--------------------------------";
        echo " ";
	fi	

;;
esac


 
fi
