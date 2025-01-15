# Program         : Login to terminal Program    [ Shell Script sh/bash/zsh ]
# Programmer Name : Bibhas Das			 [ MCA ]

# Requirements    : { md5sum, grep, cat, echo, tr, ffmpeg, ip, awk, read, cut, ps, iwlist, sleep, clear, trap,
# 		      wc, chmod, ls, upower, pgrep, date, free, curl, mkdir git }
# LOC		  : 619

# Date of Start	  : 10 July 2024                 [ Ovaral idia and overal Password locking and Trap setup ]
# Next Edit       : 9 Aug 2024, 1:58 AM     	 [ Function modulation and Message contents ] 
# Next Edit       : 10 Aug 2024, 4:50 PM       	 [ Auto Login Feature : Pendrive ]
# Next Edit	  : 17 Aug 2024, 20:58 PM        [ Auto login features : Bluetooth, Wifi ]
# Last Edit       : 18 Aug 2024, 15:59 PM        [ Auto Lock feature using background excecutable program ]

# Description     : This is a Shell script that ensure a locking features on oppening of a terminal window. While opening 
#                   a new window or tab on terminal It will ask a password if right password is entered then only the 
#                   terminal command prompt will open else It will give a certain chances and finally signout automaticly
#                   if wrong password entered. It has also a automatic login features that helps to signin automaticly 
#                   using known pendrive(attached) or Bluetooth(connected) or known wifi/ Hostpot (Just neeed present in 
#                   range). Login with a correct password or known device The main terminal command prompt will open with
#                   some system information like system name, battery, IP, MAC and others. It will also maintain a log 
#                   file and also capable to click images and video of users on iligal try of login. It basically gives 
#                   you a better securuty on terminal and a attractive look on linux terminal user. Thnak you.  

# Total files/dir : ~/.password_hashes.csv, ~/.TerminalSecurity/ , ~/.autolock, ~/.Secrect/



#Global vairable declaration and assignation

firstChar=$(echo "${USER:0:1}" | tr '[:lower:]' '[:upper:]')
user="${firstChar}${USER:1}"

# Define color codes
blue="\033[34m"
brown="\033[33m"
green="\033[32m"
black="\033[30m"
purple="\033[35m"
lightblue="\033[36m"
white="\033[37m"
red="\033[31m"
reset="\033[0m"

#files and directories
p_hash="$HOME/.password_hashes.csv"
terminalSecurityDir="$HOME/.TerminalSecurity"
autolock_file="$HOME/.autolock"
secrectDir="$HOME/.Secrect"





#for debuging messages
DEBUG=$1
if test "$DEBUG" == "-d"
then 
	DEBUG=1
else
	DEBUG=0
fi

debug()
{
	if test $DEBUG -eq 1
	then
		echo $*
		sleep 1
	fi
}






log()
{
	datetime=$(date "+%d-%m-%Y-%H-%M-%S-%N")
	if test $# -gt 0
	then
		echo "$datetime : $*" >> $terminalSecurityDir/login_attempts.log
		debug "log stored : $*"
	fi
}	


# Function to display messages with color
message() 
{
    local color=''
    local string=$1
    if [ -n "$2" ]; then
        case $2 in
            "red") color=$red ;;
            "green") color=$green ;;
            "black") color=$black ;;
            "white") color=$white ;;
            "blue") color=$blue ;;
            "purple") color=$purple ;;
            "brown") color=$brown ;;
            "lightblue") color=$lightblue ;;
            *) ;;
        esac
    fi

    echo -e "${color}\n\t\c"
    for (( i=0; i<${#string}; i++ )); do
        sleep .02
        echo -e "${string:$i:1}\c"
    done
    echo -e "${reset}\c"
}



lock()
{
	log "________Start Lock_________"
	datetime=$(date "+%d-%m-%Y-%H-%M-%S-%N")
	nohup ffmpeg -f v4l2 -i /dev/video0 -vframes 1 "$terminalSecurityDir/img-$datetime.jpg"&
	log "Login failed. User's face : img-$datetime.jpg"
	clear
	message "Message : Sorry sir this terminal can't give you the permission to log in" "red"
	message "Reason  : Suspesious login attempt" "blue"
	echo
	message "__Actions taken__" "brown"
	message "[1] Log saved" "green"
	message "[2] Sessions and caches are cleared" "green"
	message "[3] New salt added with password" "purple"
	message "[4] Suspecious person's face is captured" "purple"
	message "[5] Self destroing login session in 15 seconds" "red"
	echo
	echo
	sleep 2
	nohup ffmpeg -f v4l2 -i /dev/video0 -t 8 "$terminalSecurityDir/vid-$datetime.mp4"&
	log "User's video : img-$datetime.mp4"
	message "[*] Terminal security system reactivated" "lightblue"
	echo
	echo
	sleep 5
	gnome-session-quit --logout --no-prompt 
}



welcome()
{
	debug "fetching all the hardware information..."
	HOST=$(hostname)
	st=$(grep -E '^(ID|ID_LIKE)=' /etc/os-release)
	os=$(echo "$st" | grep '^ID=' | cut -d '=' -f 2)
	dist=$(echo "$st" | grep '^ID_LIKE=' | cut -d '=' -f 2)


	device=$(hostnamectl|grep "Hardware Model:"|cut -d ":" -f 2)
	battery=$(upower -i $(upower -e | grep battery) | grep percentage | awk '{print $2}')  
	

	mac=$(ip link show | grep -i ether | awk '{print $2}')
 
	ram=$(free -h | grep Mem: | awk '{print $4}')
	Date=$(date "+%A, %d %B %Y, %I:%M %p.")
	process=$(pgrep -c .)
	
	temp=$(awk '{print $1/1000 "°C"}' /sys/class/thermal/thermal_zone0/temp) 
	
	ip=$(ip -4 addr show | awk '/^[0-9]+: / {iface=substr($2, 1, length($2)-1)} /inet / {split($2, a, "/"); if (iface != "lo") print a[1], iface}')
	if test -z "$ip"
	then
		ip="127.0.0.1 lo"
	fi
	response=$(curl -s --max-time 3 http://ip-api.com/json)
	if test -n "$response"
	then
		public_ip=$(echo "$response" | grep -oP '"query":\s*"\K[^"]+')
		country=$(echo "$response" | grep -oP '"country":\s*"\K[^"]+')
		region=$(echo "$response" | grep -oP '"regionName":\s*"\K[^"]+')
		city=$(echo "$response" | grep -oP '"city":\s*"\K[^"]+')
		isp=$(echo "$response" | grep -oP '"isp":\s*"\K[^"]+')
		latitude=$(echo "$response" | grep -oP '"lat":\s*\K[^,]+')
		longitude=$(echo "$response" | grep -oP '"lon":\s*\K[^,]+')
		timezone=$(echo "$response" | grep -oP '"timezone":\s*"\K[^"]+')
	fi

	echo  -e "$blue\n\t$Date$reset"
	echo -e "\n\tWelcome again $user, This is a $device device, loaded $dist based $os OS."
	echo -e "$green\tBattery is $battery left, $SHELL shell is running, with $HOST hostname.$reset"
	echo -e "$green\tRAM is left $ram, CPU's current tempurature : $temp, current running processes : $process$reset"
	echo -e "\tYour current Local IP-Interface : $ip, MAC : $mac$reset"
	if test -n "$response"
	then
		echo -e "\tYour Public IP : $public_ip, ISP : $isp, From $city in $country - $region"
		echo -e "$green\tApproximate Latitude : $latitude, Longitude : $longitude , Time Zone : $timezone$reset"
	fi

	debug "Updating The log file.."
	
	if test $lock_start -ne $lock_end -o $login_start -ne $login_end
	then
		echo -e "$red\n\t☣️  There is a unknown login attempt found$reset ☣️"
		echo -e "\tDo you want to ignore the problem? Y/N (Default=N) : \c"
		read ch
		if test "$ch" = "Y" -o "$ch" = "y"
		then
			#action to resolve
			log "________Ignored by Owner_______"
			
			if test $lock_start -ne $lock_end
			then
				log "________End Lock_________"
			elif test $login_start -ne $login_end
			then
				log "________End Login_________"
			fi
			echo -e "$green\tOkey $user terminal security is reset$reset 👍"	
		else
			echo -e "$green\tOkey $user please visit : $terminalSecurityDir$reset"
		fi
	fi
	echo
}	
	
	
 	
	
autoLock() 
{	
	debug "code is genarated for .autolock"
	
	code="found=0
	
	usb_key=\$(cat \$p_hash|head -2|tail -1)
	wifi_key=\$(cat \$p_hash|head -3|tail -1)
	bluetooth_key=\$(cat \$p_hash|head -4|tail -1)
	
	checkKnownDevice(){
	
	if test \$(echo \$wifi_key|wc -c) -eq 33
	then
		for device in /dev/disk/by-uuid/*; do
			device_name=\$(echo \$device | awk -F'/' '{print \$NF}')
			device_hash=\$(echo \$device_name | md5sum |cut -c 1-32)
			
			if [ "\$device_hash" == "\$usb_key" ]
			then
				found=1
				break 
			fi
		done
	fi
	
	
	if test \$found -eq 0
	then
		if test \$(echo \$bluetooth_key|wc -c) -eq 33
		then
    		connectedBluetoothHash=\$(bluetoothctl devices Connected | cut -d \" \" -f 2- | md5sum | cut -c 1-32);
    		if [ \"\$connectedBluetoothHash\" = \"\$knownBluetoothHash\" ]; then 
        		found=2
    		fi
    	fi
	fi;

	
	if test \$found -eq 0
	then
		if test \$(echo \$wifi_key|wc -c) -eq 33
		then
			for i in \$(iwlist scan 2>/dev/null | grep "Address"); do
				mac_address=\$(echo "\$i" | rev | cut -d ' ' -f 1 | rev | tr -d ' ')
		
				if test \$(echo \$mac_address|wc -c) -le 16 
				then
					continue
				fi
				key=\$(echo "\$mac_address" | md5sum | cut -c 1-32)
				
				if [ "\$key" = "\$wifi_key" ]; then
				     found=3
				     break 2
			    fi
			 done
		 fi
	fi
	}
	
while [ true ]; do
	checkKnownDevice
	if [ \$found -eq 0 ]; then 
    		echo \"Warning : Device is disconnected. Please connect trusted devices in 15 seconds\";
		sleep 20
		checkKnownDevice
		if [ \$found -eq 0 ]; then
			gnome-session-quit --logout --no-prompt 
		fi
	fi
	sleep 5
done"

	debug "autolock file is overwrriten"	
	
	echo "$code" > $autolock_file
	chmod +x $autolock_file
    
    debug "checking if teh autolock file is already running or not"
	process=$(ps -u $USER -f|grep $autolock_file | wc -l)
	if [ $process -lt 2 ]
	then
		debug "autolock file not running so restarting it's process"
		#echo "The autolock mecanishm is started"
		sh $autolock_file&
	fi
}	
	
	
	
	
autoLogin()
{	

	found=0 # Flag for checking a known device for auto login
	
	#get pendrive stick name
	usb_key=$(cat $p_hash|head -2|tail -1)
	
	debug "cheking is the pendrive is already configered or not"
	
	if test $(echo $usb_key|wc -c) -eq 33
	then
		debug "scaning for pendrive stick"
		for device in /dev/disk/by-uuid/*; do
			device_name=$(echo $device | awk -F'/' '{print $NF}')  # Extracts just the UUID
			device_hash=$(echo $device_name | md5sum |cut -c 1-32)
			
			if [ "$device_hash" == "$usb_key" ]
			then
				debug "pendrive strick is found and tries for login automatic"
				found=1  # Set uid to 1 if hashes match
				break  # Exit loop once a match is found
			fi
		done
	else
		debug "Skiping the usb login"
	fi
	
	
	
	debug "scaning for bluetooth devices"
	if test $found -eq 0
	then
		bluetooth_key=$(cat $p_hash|head -4|tail -1)
		if test $(echo $bluetooth_key|wc -c) -eq 33
		then
			debug "scaning connected blutooth devices"
			connectedBluetoothHash=$(bluetoothctl devices Connected | cut -d " " -f 2- | md5sum | cut -c 1-32)
			if [ "$connectedBluetoothHash" = "$bluetooth_key" ]
			then
				found=2	
				debug "trusted bluetooth device is found and tries to login"
			fi
		else
			debug "skiping Bluetooth login"
		fi
	fi




	debug "scaning for trusted wifi device's mac address"
	if test $found -eq 0
	then
		debug "fetching the wifi hash"
		wifi_key=$(cat $p_hash|head -3|tail -1)
		
		debug "checking if wifi is configered or not"
		if test $(echo $wifi_key|wc -c) -eq 33
		then
			debug "now searching if trusted wifi is present ot not"
			
			for i in $(iwlist scan 2>/dev/null | grep "Address"); do # Scan for WiFi addresses
				mac_address=$(echo "$i" | rev | cut -d ' ' -f 1 | rev | tr -d ' ')
		
				if test $(echo $mac_address|wc -c) -le 16 
				then
					continue
				fi
				key=$(echo "$mac_address" | md5sum | cut -c 1-32) # Generate hash of the MAC address
				
				# Check if the generated hash matches my hash in the file
			  
			    if [ "$key" = "$wifi_key" ]; then
			    	debug "trusted wifi device is found now tries to login"
			        found=3
			        break 2 # Exit both loops
			    fi
				
			done
		else
			debug "skiping the wifi login"
		fi
	fi



	
	debug "login trial process completed"
	
	if test $found -eq 1 # cheking for known pendrive is connected or not
	then
		log "Login success by usb key"
		clear
		autoLock
		welcome
		exit
	elif test $found -eq 2 # cheking for known Bluetooth device is connected or not
	then 
		log "Login success by known Bluetooth Device"
		clear
		autoLock
		welcome
		exit
	elif test $found -eq 3 # cheking for known Wifi device is present or not in range
	then
		log "Login success by known Wifi"
		clear
		autoLock
		welcome
		exit
	fi
	
}



__main__()
{
	debug "stating main function"
	
	if test -f $terminalSecurityDir/login_attempts.log
	then
		lock_start=$(cat $terminalSecurityDir/login_attempts.log | grep -E "________Start Lock_________" | wc -l)
		lock_end=$(cat $terminalSecurityDir/login_attempts.log | grep -E "________End Lock_________" | wc -l)
		login_start=$(cat $terminalSecurityDir/login_attempts.log | grep -E "________Start Login_________" | wc -l)
		login_end=$(cat $terminalSecurityDir/login_attempts.log | grep -E "________End Login_________" | wc -l)
	else
		lock_start=0
		lock_end=0
		login_start=0
		login_end=0
	fi

	debug "privet directory is creating and append permissions"
	mkdir -p $terminalSecurityDir
	chmod +wr $terminalSecurityDir
	

	# Trap interrupt signals
	
	debug "Signal jamming for no intrupt"
	
	trap '' SIGINT SIGQUIT SIGTSTP
	
	password_hash=$(cat $p_hash|head -1) # for first hash (password)
	
	debug "starting autologin"
	
	#auto login function
	autoLogin;
	
	
	if test -f $terminalSecurityDir/login_attempts.log
	then
		if test $lock_start -ne $lock_end
		then
			echo -e "$red\n\tSecurity alert !!! [ Attempt to guess password ]$reset"
			echo -e "\tTerminal security is active. Please login with security stick"
			sleep 10
			autoLogin;
			#echo "Sign out"
			gnome-session-quit --logout --no-prompt
			exit
		fi
		
		if test $login_start -ne $login_end
		then
			echo -e "$red\n\tSecurity alert !!! [ Incomlete logging session ]$reset"
			echo -e "\tTerminal security is active. Please login with security stick"
			sleep 10
			autoLogin;
			#echo "Close terminal"
			ps aux | grep '[t]erminal' | awk '{print $2}' | xargs kill -9
			exit
		fi
	fi

	log "________Start Login_________"
	#How many try an user can (Default=5)
	try=5
	iter=1
	while [ $iter -le $try ]
	do
		clear
		if test $iter -gt 1
		then
			echo
			message "It is your $iter chance to login. Be carefull"
		else
			message "Welcome $user"
			    message "Nice to see you again. The whole system is okey. You can proceed." "green"
		    	message "Make sure you internet conncetion is extablished and enjoy our survices." "green"
		    	message "Thank You"
		fi

		echo 
		message "$user, please type your password: " "brown"
		read -s -t 20 -n 16 password; 
		
		if test -z "$password" ; then echo; message "No password provided" "red"; 
		
		else
		#echo -e "\n\tPassword entered: $password"
		
		#convert plain password to hash
		passwd=$(echo $password|md5sum|cut -c 1-32)

		if test $passwd = $password_hash
		then
			log "Login success entering correct password"
			clear
			welcome
			log "________End Login_________"
			break
		else
			echo
			message "Wrong password" "red"
			log "Attempt to login with the password [$password]"
		fi
		fi

		sleep 3
		iter=`expr $iter + 1`
	done

	if test $iter -ge $try
	then
		log "________End Login_________"
		lock
	fi

	# Reset trap to default behavior
	trap - SIGINT SIGQUIT SIGTSTP
}


create_password_hash_file()
{
	message "Choose a password for terminal(max:16) : " "brown"
	read -s -n 16 _pass1;
	message "Comfirm your password(max:16) : "
	read -s -n 16 _pass2
	if test "$_pass1" = "$_pass2"
	then
		echo "$(echo $_pass1 | md5sum | cut -c 1-32)" > $p_hash
	else
		message "Passwords are missmatched" "red"
		sleep 1
		clear
		create_password_hash_file
	fi
	message "Password is stored successfully" "green"
	
	
	message " "
	message "Are you want to setup pendrive key ? (y/n): "
	read ch
	
	if test "$ch" = "y" -o "$ch" = 'Y'
	then
		message "You should insert your any pendrive to PC first" "brown"
		while [ true ]
		do
			ls -l /dev/disk/by-uuid/
			d_list=$(ls -l /dev/disk/by-uuid/)
			message "Type only the pendrive's name or 'r' for reload: "
			read ch
			c=$(echo $d_list|grep " $ch ")
			c=$(echo $c|wc -c)
			debug "length of input pendrive : $c"
			
			if [ $c -gt 1 ]
			then
				echo $ch|md5sum|cut -c 1-32 >> $p_hash
				break
			fi
		done
	message "Pendrive stick is added successfully" "green"
	else
		debug "dummy data inserted"
		echo "" >> $p_hash
	fi
	
	
	message " "
	message "Are you want to setup trusted wifi ? (y/n): "
	read ch
	if test "$ch" = "y" -o "$ch" = 'Y'
	then
		message "You should turn on wifi or mobile hostpot as a wifi"
		while [ true ]
		do
			iwlist scan > /dev/null 2>&1
			iwlist scan 2>/dev/null | grep -E "Address|ESSID"
			w_list=$(iwlist scan 2>/dev/null | grep -E "Address|ESSID")
			message "Just type the 17 chracter your trusted wifi's MAC address or r for reload : "
			read w_mac
			ch=$(echo $w_list|grep " $w_mac ")
			ch=$(echo $ch|wc -c)
			
			if test $ch -ge 17
			then
				echo $w_mac|md5sum|cut -c 1-32 >> $p_hash
				break
			fi
		done
		message "Trusted wifi is added successfully" "green"
	else
		debug "dummy data inserted"
		echo "" >> $p_hash
	fi
	
	
	message " "
	message "Are you want to setup trusted blutooth device? (y/n): "
	read ch
	if test "$ch" = "y" -o "$ch" = 'Y'
	then
		debug "You should pair and connected to the blutooth only one device"
		while [ true ]
		do
			connectedBluetooth=$(bluetoothctl devices Connected | cut -d " " -f 2-)
			if test $(echo $connectedBluetooth|wc -c) -ge 17
			then
				message "$connectedBluetooth : Is it your device?(y/n) " "brown"
				message "If not reload it with 'r': "
			
				read ch
				if test "$ch" = "y" -o "$ch" = 'Y'
				then
					connectedBluetoothHash=$(echo $connectedBluetooth|md5sum|cut -c 1-32)
					echo $connectedBluetoothHash >> $p_hash
					break
				fi
			else
				message "Blutooth device is not connect in 5 seconds" "purple"
				sleep 5
			fi
		done
		message "Trusted blutooth device is registered successfully" "green"
	
	else
		debug "dummy data inserted"
		echo "" >> $p_hash
	fi
	
	debug "All password hashes are stored in a file"
	
}








####################################################################################################################

#program starts from here


# Check if the file exists

if [ -e "$p_hash" ]
	then
		# Check if the file is empty
		if [ ! -s "$p_hash" ] 
		then
		    rm $p_hash
		    exit
		#else all is good
		fi
else

    debug "coping itself to the home folder"
	mv $0 $HOME/.askpass
	debug "assiging permissions"
	chmod +x $HOME/.askpass

	debug "secrect directory is creating and append permissions"
	mkdir -p $secrectDir
	chmod 777 $secrectDir
	
	debug "secrect commands directory is creating and append permissions"
	mkdir -p $secrectDir/commands
	chmod 777 $secrectDir/commands
	
	debug "secrect note directory is creating and append permissions"
	mkdir -p $secrectDir/notes
	chmod 777 $secrectDir/notes

	debug "Checking if the commands directory exists and is empty or not"

	if [ -d "$secrectDir/commands" ]; then
		if [ -z "$(ls -A "$secrectDir/commands")" ]; then
		    debug "The directory exists but is empty. Cloning the repository..."
		    git clone https://github.com/Bibhas-Das/Commands-Notes.git
			chmod -R 777 Commands-Notes
		    
		    mv Commands-Notes/*.txt "$secrectDir/notes"
		    mv Commands-Notes/* "$secrectDir/commands"
		    mv Commands-Notes/.banner "$secrectDir/commands" #exception
		    rm -r Commands-Notes
		    chmod +x "$secrectDir/commands/"*
		else
		    debug "The directory exists and is not empty."
		fi
	else
		debug "The directory does not exist. Creating the directory and cloning the repository..."
		mkdir -p "$secrectDir/commands"
		git clone https://github.com/Bibhas-Das/Commands-Notes.git
		chmod -R 777 Commands-Notes
		
		mv commands/*.txt "$secrectDir/notes"
		mv Commands-Notes/* "$secrectDir/commands"
		mv Commands-Notes/.banner "$secrectDir/commands" #exception
		rm -r Commands-Notes
		chmod +x "$secrectDir/commands/"*
	fi

	
	debug "setup autorun process"
	
	if [ -e ".bashrc" ]
	then
		debug "bashrc file has changed"
		echo "export PATH=\$PATH:$secrectDir/commands" >> $HOME/.bashrc
		echo "./.askpass" >> $HOME/.bashrc
	fi
	
	if [ -e ".zshrc" ]
	then
		debug "zshrc file has changed"
		echo "export PATH=\$PATH:$secrectDir/commands" >> $HOME/.zshrc
		echo "./.askpass" >> $HOME/.zshrc
	fi
	
	if [ -e ".fishrc" ]
	then
		debug "fishrc file has changed"
		echo "export PATH=\$PATH:$secrectDir/commands" >> $HOME/.fishrc
		echo "./.askpass" >> $HOME/.fishrc
	fi
	
    message "Error: Password file is missing" "red"
    sleep 3
    if test -e $autolock_file
    then
    	rm $autolock_file
    fi
    create_password_hash_file
fi


__main__
