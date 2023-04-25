#!/bin/bash

user=""

function play_songs() {
	paths="$(sed -r 's/^.* \(([0-9]+)\)/songs\/\1.mp3/g' <<< $1)"
	read -p "Would you like to play these song(s)? ([y]es/[n]o/[s]huffle) " ans
	while [ -n "$ans" ]; do
		case "$ans" in
			"y")
				echo "$paths" | xargs mpv
				;;
			"s")
				echo "$paths" | xargs mpv --shuffle
				;;
			*)
				printf "Song(s) were not played.\n"
				break
		esac
		read -p "Would you like to play these song(s) again? ([y]es/[n]o/[s]huffle) " ans
	done
}

function play() {
	clear
	printf "*** Search/Play Songs ***\n"
	printf "To search songs by title and artist, use \"[title];[artist]\".\n"
	printf "To search songs by title or artist alone, replace the other search term with *.\n"
	printf "To search songs by ID, use \"[ID]\".\n"
	printf "Otherwise, press [Enter] to return to the main menu.\n"
	IFS=";"
	echo
	read -p "What song(s) would you like to find? " title artist
	while [ -n "$title" ]; do
		if [ -n "$artist" ]; then
			result="$(grep -iE "^.*$title.* by .*$author.*" catalog.txt)"
		else
			result="$(grep -iE "^.* \(.*$title.*\)$" catalog.txt)"
		fi
		if [ -z "$result" ]; then
			printf "No results found for $title."
		else
			printf "$result"
			printf "\n\n"
			play_songs "$result"
		fi
		echo
		read -p "What song(s) would you like to find? " title artist
	done
	IFS=" "
}

function register() {
	clear
	printf "*** Register an Account ***\n"
	printf "Please enter a unique username and a password containing at least 8 characters, including an uppercase letter, a lowercase letter, and a number. Both the username and password may only contain alphanumeric characters.\n"
	read -p "Enter username: " username
	while [[ ! "$username" =~ ^[A-Za-z0-9]+$ ]] || [ -n "$(cut -d, -f2 < users.txt | grep -iE "$username")" ]; do
		read -p "Username is invalid or already taken. Please try again: " username
	done
	read -sp "Enter password: " password
	while [[ ! "$password" =~ ^[A-Za-z0-9]+$ ]] || [ -z "$(echo "$password" | grep -E ".{8,}" | grep -E "[A-Z]+" | grep -E "[a-z]+" | grep -E "[0-9]+")" ]; do
                echo
		read -sp "Password is invalid. Please try again: " password
        done
	#let id_new="1 + $(cut -d, -f1 < users.txt | sort -n | tail -1)"
	printf "$username,$password\n" >> users.txt
	printf "\nSuccessfully created user $username."
	user="$username"	
}

function login() {
	clear
	printf "*** Log in to Your Account ***\n"
	read -p "Enter username: " username
	read -sp "Enter password: " password
	lookup="$(grep -iE "^$username,$password$" users.txt)"
	if [ -z "$lookup" ]; then
		echo
		read -p "Failed to log in. Invalid username or password. Press [Enter] to continue."
		return 1
	else
		printf "\nSuccessfully logged in as $username.\n"
		user="$username"
		return 0
	fi
}

function search_playlists() {
	echo
}

function edit_playlists() {
	echo
}

function message_login() {
	clear
	printf "--------------------------------------------------\n"
        printf "Welcome to tunix, a Unix-based music player!\n"
        printf "You are currently logged in as: $user\n"
        printf "What would you like to do?"
        printf "\n--------------------------------------------------\n"
        printf "(1) Search/Play\n"
        printf "(2) Search playlists\n"
        printf "(3) Edit playlists\n"
        printf "(Enter) Log out"
        printf "\n--------------------------------------------------\n"
}

function main_login() {
	message_login
	read option
        while [ ! -z "$option" ]; do
                case "$option" in
                        1)
                                play
				message_login
                                ;;
                        2)
                                search_playlists
				message_login
                                ;;
                        3)
                                edit_playlists
				message_login
                                ;;
                        *)
                                printf "Invalid option. Please try again.\n"
                esac
                read option
        done
	user=""
        printf "Logging out...\n"
}

function message_nologin() {
	clear
	printf "\n--------------------------------------------------\n"
	printf "Welcome to tunix, a Unix-based music player!\n"
	printf "You are currently not logged in.\n"
	printf "What would you like to do?"
	printf "\n--------------------------------------------------\n"
	printf "(1) Search/Play\n"
	printf "(2) Register\n"
	printf "(3) Log in \n"
	printf "(Enter) Quit"
	printf "\n--------------------------------------------------\n"
}

function main_nologin() {
	message_nologin
	#printf "\n##################################################\n#                                                #\n#    Welcome to tunix, a Unix-based music        #\n#    player! You are currently not logged in.    #\n#    What would you like to do?                  #\n#                                                #\n#    ----------------------------------------    #\n#                                                #\n#    (1) Search/Play                             #\n#    (2) Register                                #\n#    (3) Log in                                  #\n#    (Enter) Quit                                #\n#                                                #\n##################################################\n\n"
	read option
	while [ ! -z "$option" ]; do
		case "$option" in
			1)
				play
				message_nologin
				;;
			2)
				register
				main_login
				message_nologin
				;;
			3)
				login
				if [ "$?" -eq 0 ]; then
					main_login
				fi
				message_nologin
				;;
			*)
				printf "Invalid option. Please try again.\n"
		esac
		read option
	done
	printf "Shutting down...\n"
	exit 0
}

# Start application
main_nologin
