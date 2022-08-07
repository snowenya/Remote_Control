#!/bin/bash
#Remote control script
#This script is created to communicate with a remote server and execute tasks anonymously, tool check will be performed before execution. 
#There are 3 parts to the script: 1)Welcome banner 2)Checking for tools:curl,nipe and sshpass 3)Execution

#1) Welcome banner: If user does not have figlet and lolcat to view the banner, an installation will be prompted (optional)

function welcomebanner()
{
WEL=$(figlet -f isometric3.flf Welcome! -c -w100 | lolcat) 
if [[ ! $WEL ]]
then 
echo "**Oops, you do not have the files and tools needed to see the banner"
read -p "Would you like to install them to view it? (Y/N), (selecting no will not affect the execution of the rest of the script): " IFIGNLOLCAT
	if [[ "$IFIGNLOLCAT" == "Y" ]]
	then 
	echo "Installing figlet and font file.."
	cd ~
	sudo apt-get update -y
	sudo apt-get install -y figlet
	sudo updatedb
	sudo wget http://www.figlet.org/fonts/isometric3.flf -P /usr/share/figlet
	echo "Installing lolcat.."
	cd ~
	wget https://github.com/busyloop/lolcat/archive/master.zip
	unzip master.zip
	cd lolcat-master/bin
	sudo gem install lolcat
	sudo updatedb
	welcomebanner
	else
	echo "Continuing script.."
	fi
else
figlet -f isometric3.flf Welcome! -c -w100 | lolcat
fi
}
welcomebanner 	#colourfulbanner
echo
echo "Welcome, this script willl check and execute the tools you need to become anonymous for remote control."
sleep 3
echo

#2) Check for tools that you need (curl, nipe and sshpass)
echo "**We will start checking if you have the tools to get things running.. "
echo
sleep 2
echo "Some tools that you will need in this script are: curl, nipe and sshpass"
sleep 3
echo
#2a) Checking if curl is installed, if not, install curl
echo "**(1/3) Checking if you have curl.."
function curlcheck()
{ CHKCURL=$(which curl)
	if [[ ! $CHKCURL ]] #if no curl, installation will be prompted ((https://bash.cyberciti.biz/guide/Logical_Not_!)
	then 
	echo 'Oops! curl is not installed.'
	read -p 'Would you like to install curl? (Y/N)? ' CURLINSTALL
		if [ "CURLINSTALL" == "Y" ]
		then 
		echo 'Installing curl..'
		sudo apt install curl
		sudo updatedb
		curlcheck
		else
		echo 'You cannot continue if curl is not installed. Rechecking whether your curl is installed..'
		curlcheck
		fi
	else
	echo 'Yay! curl is installed. Proceeding to check the next tool'
	fi
}
curlcheck 	#runinstallcurl
echo
sleep 3
#2b) Checking if Nipe is installed, if not install Nipe
echo "**(2/3) Checking if you have Nipe.."
function nipecheck()
{
	CHKNIPE=$(locate nipe.pl) #if no nipe, installation will be prompted
	if [[ ! $CHKNIPE ]]
	then 
	echo 'Ooops! Nipe is not installed.'
	read -p 'Would you like to install Nipe (Y/N)? ' NIPEINSTALLYN
		if [ "$NIPEINSTALLYN" == "Y" ]
		then 
		echo 'Installing nipe..'
		git clone https://github.com/htrgouvea/nipe ~/nipe
		cd ~/nipe
		sudo cpan install Try::Tiny Config::Simple JSON
		sudo perl nipe.pl install
		sudo updatedb #need to update database, if not locate doesn't work
		nipecheck
		else 
		echo "You cannot continue if Nipe is not installed. Rechecking whether your Nipe is installed.."
		nipecheck
		fi
	else
	echo 'Yay! Nipe is installed.. Proceeding to check the next tool~'
	fi
}
nipecheck 	#runinstallnipe
echo
sleep 3

#2c) Checking if sshpass is installed, if not, install sshpass
echo "**(3/3) Checking if you have sshpass.."
function sshpasscheck()
{ CHKSSHPASS=$(which sshpass)
	if [[ ! $CHKSSHPASS ]] #if no sshpass, installation will be prompted
	then 
	echo 'Oops! sshpass not installed.'
	read -p 'Would you like to install sshpass? (Y/N)? ' SSHPASSINSTALL
		if [ "$SSHPASSINSTALL" == "Y" ]
		then 
		echo 'Installing sshpass..'
		sudo apt install sshpass
		sudo updatedb
		sshpasscheck
		else
		echo 'You cannot continue if sshpass is not installed. Rechecking whether your sshpass is installed..'
		sshpasscheck
		fi
	else
	echo 'Yay! sshpass is installed.'
	fi
}
sshpasscheck	#runinstallsshpass

#3a) Becoming anonymous
echo "Now that you have the tools installed, let's proceed to make you anonymous!"
echo
sleep 3
read -p "Tell me your country code! (e.g. SG for Singapore): " CC 
#Check if the connection is anonymous, if not, run nipe
function ANON()
{ echo "**Checking if you are anonymous.."
CNTRY=$(curl -s ifconfig.io/country_code)
#-s		silent mode

if [ "$CNTRY" == "$CC" ] #Comparing country code to determine anonymity, if country code of external ip matches entered country code = not anonymous
then

	echo "This is your current IP country code: $CNTRY"
	echo "Oops, you are NOT anonymous!"
	echo "We will run Nipe to get you anonymous"
	cd ~/nipe
	sudo perl nipe.pl start
	sudo perl nipe.pl restart
	ANON
else 
	echo "This is your current IP country code: $CNTRY"
	echo "You are anonymous, awesome!"

fi
}
ANON 	#check anonymous

echo
sleep 3
#3b) Connect automatically to the VPS and execute tasks
function sshandtasks()
{
echo "**We will now communicate via SSH to execute some tasks."
read -p "Please enter the server's IP address: " IP
read -p "Please enter the username: " USER
read -p "Please enter the password: " PW

#sshpass to enter server with password
##stricthostkeychecking=0 removes authentication process and automatically accepts any key
#nmap scanning ip for nmap.org (45.33.32.156) and whois google.com
#Here document https://bash.cyberciti.biz/guide/Here_documents

sshpass -p$PW ssh -o StrictHostKeyChecking=no $USER@$IP << HERE
echo "Here's the directory you are in:"
pwd
sleep 1
echo "Here are the current files in the directory:"
sleep 3
ls
sleep 3
echo "**We will now execute nmap and save the results into XML file"
sleep 3
nmap 45.33.32.156 -oX nmapscan.xml
echo "nmap scan is done"
echo "**We will now execute whois and save it in a file"
sleep 3
whois google.com > whoisresults
echo "Here are the files (including those you created) in the server:"
sleep 3
ls
echo "We have completed the tasks & we will now end the SSH session.."
sleep 3
HERE


}
sshandtasks	 #connect and execute

sleep 3
echo "Stopping Nipe service.."
cd ~/nipe
sudo perl nipe.pl stop
echo "You've reached the end of the script~"
figlet -f isometric3.flf Goodbye! -c -w100 | lolcat



