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


stop_process()
{
    PID=$(ps -ef | grep '[.]autolock' | grep -v grep | awk '{print $2}')

    # Check if a PID was found
    if [ -n "$PID" ]; then
        #echo "Killing .autolock process with PID: $PID"
        kill "$PID"
    fi
}


delete_files()
{
    # List of files and directories to delete
    items=(
        "$HOME/.config/autostart/autoexecute.desktop"
        "$HOME/.password_hashes.csv"
        "$HOME/.askpass"
        "$HOME/.autolock"
        "$HOME/.Secrect/commands"
        "$HOME/.Secrect/notes"
        "$HOME/.Secrect"
    )

    for item in "${items[@]}"; do
        if [ -e "$item" ]; then
            #echo "Deleting: $item"
            rm -rf "$item"
        fi
    done
    #echo "Cleanup complete."
}



delete_log_data() 
{
    SEC_DIR="$HOME/.TerminalSecurity"

    if [ -d "$SEC_DIR" ]; then
        #echo "Deleting contents of: $SEC_DIR"
        rm -rf "$SEC_DIR"
        #echo "Deleted: $SEC_DIR"
    fi
}



crean_footprint()
{
    # List of shell config files
    configs=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.fishrc")

    for file in "${configs[@]}"; do
        if [ -f "$file" ]; then
            #echo "Cleaning $file..."

            # Remove line that exports .Secrect/commands to PATH
            sed -i '/export[[:space:]]\+PATH=.*\.Secrect\/commands/d' "$file"

            # Remove any line containing .askpass (e.g., /home/username/.askpass)
            sed -i '/\.askpass/d' "$file"

            #echo "Updated: $file (backup saved as $file.bak)"
        fi
    done
}






message "[ TerminalPassword ]" "brown"
echo 
message "Make use you did not change any file or folder name. If you renamed any file then this uninstall program will fail" "purple"
echo 
message "Are you sure to uninstall (yes/no): " "blue"
read ch
if test "$ch" = "yes"
then
    message "Are you want to delete the logs file also (yes/no)? : " "blue"
    read com
    
    message "[ Uninstalling TerminalPassword ]" "red"
    sleep 3
    echo

    message "[ * ] Stopping running programs"
    stop_process
    sleep 4
    message "[ > ] Done" "green"
    message "[ * ] Removing all related files and folders"
    delete_files
    sleep 4
    message "[ > ] Done" "green"
    
  
    
    if test $com = "yes"
    then
        message "[ * ] Removing all logs"
        delete_log_data
        sleep 4
        message "[ > ] Done" "green"    
    fi

    message "[ * ] Cleaning all footprints"
    crean_footprint
    sleep 4
    message "[ > ] Done" "green"
    message "[ * ] Finalizing ..."
    sleep 4
    message "[ > ] Done" "green"
    sleep 4
    message "[ * ] Uninstalling [Done]"
    echo
    sleep 2
fi
message "[ * ] Thank you for uning this program" "brown"
echo
echo
