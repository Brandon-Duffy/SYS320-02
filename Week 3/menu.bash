#!/bin/bash

# Storyline: Menu  for admin, vpn, and security functions

function invalid_opt() {

 echo ""
 echo "Invalid Option"
 echo ""
 sleep 2

}

function menu() {

    # clears the screen
    clear

    echo "[1] Admin Menu"
    echo "[2] Security Menu"
    echo "[3] Exit"
    read -p "Please enter choice above: " choice

    case "$choice" in

	1) admin_menu
	;;

	2) security_menu
	;;

	3) exit 0
	;;

	*)
	     invalid_opt
             # Call the main menu
             menu
	;;
    esac

}

function admin_menu() {


    echo "[L]ist Running Processes"
    echo "[N]etwork Sockets"
    echo "[V]PN Menu"
    echo "[4] Exit"
    read -p "Please enter a choice above: " choice
  
    case "$choice" in

	L|1) ps -ef |less
	;;
	N|n) netstat -an --inet |less
	;;
	V|v) vpn_menu
	;;
	4) exit 0
	;;

	*)
	   invalid_opt
	;;

    esac

admin_menu

}

function security_menu() {
    clear
    echo "[1] List open network sockets"
    echo "[2] Check if any user besides root has a UID of 0"
    echo "[3] Check the last 10 logged in users"
    echo "[4] See currently logged in users"
    echo "[5] Return to main menu"
    read -p "Please enter a choice above: " choice

    case "$choice" in
        1)
            netstat -an --inet
        ;;
        2)
            # Finds if all users with UID 0 except root
            awk -F: '($3 == "0") {print $1}' /etc/passwd | grep -v root
            if [[ $? -eq 1 ]]; then
                echo "No user other than root has UID 0"
            fi
        ;;
        3)
            # This command will show the last 10 logged in users
            last -n 10
        ;;
        4)
            # This command will display currently logged in users
            who
        ;;
        5)
            menu
        ;;
        *)
            invalid_opt
            security_menu
        ;;
    esac
    # Wait for user input before showing menu again
    read -p "Press any key to return to security menu..." 
    security_menu
}

function vpn_menu() {

    echo "[A]dd a peer"
    echo "[D]elete a peer"
    echo "[B]ack to admin menu"
    echo "[M]ain menu"
    echo "[E]xit"
    read -p "Please select an option: " choice

    case "$choice" in

    A|a) 

     bash peer.bash
     tail -6 wg0.conf |less

    ;;
    D|d)
	# Create  prompt for the user
	 # Caall the mnage-user.bash and pass the proper switches aand argument
	 # to delete the user
    ;;
    B|b) admin_menu
    ;;
    M|m) menu
    ;;
    E|e) exit 0
    ;;
    *)
	invalid_opt
    ;;

    esac
vpn_menu
}





menu
}
