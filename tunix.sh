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
	printf "\n*** Search/Play Songs ***\n"
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
	echo
}

function main_login() {
	echo
}

function main_nologin() {
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

	#printf "\n##################################################\n#                                                #\n#    Welcome to tunix, a Unix-based music        #\n#    player! You are currently not logged in.    #\n#    What would you like to do?                  #\n#                                                #\n#    ----------------------------------------    #\n#                                                #\n#    (1) Search/Play                             #\n#    (2) Register                                #\n#    (3) Log in                                  #\n#    (Enter) Quit                                #\n#                                                #\n##################################################\n\n"
	read option
	while [ ! -z "$option" ]; do
		case "$option" in
			1)
				play
				;;
			2)
				register
				;;
			3)
				main_login
				;;
			*)
				printf "Invalid option.\n"
		esac
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
		read option
	done
	printf "Shutting down...\n"
	exit 0
}

# Start application
main_nologin