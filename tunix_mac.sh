#!/bin/bash

user=""
playlists=""

function play_songs() {
	paths="$(sed -r 's/^([0-9]+)$/songs\/\1.mp3/g' <<< $1)"
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

function search_songs() {
	clear
	printf "*** Search Songs ***\n"
	printf "To search songs by title and artist, use \"[title];[artist]\".\n"
	printf "To search songs by title or artist alone, replace the other search term with *.\n"
	printf "To search songs by ID, use \"[ID]\".\n"
	printf "Otherwise, press [Enter] to return to the main menu.\n"
	IFS=";"
	echo
	read -p "What song(s) would you like to find? " title artist
	while [ -n "$title" ]; do
		if [ -n "$artist" ]; then
			result="$(ggrep -iE "^.*$title.* by .*$author.*" catalog.txt)"
		else
			result="$(ggrep -iE "^.* \(.*$title.*\)$" catalog.txt)"
		fi
		if [ -z "$result" ]; then
			printf "No results found for $title."
		else
			printf "$result"
			printf "\n\n"
			ids="$(gsed -r 's/^.* \(([0-9]+)\)/\1/g' <<< $result)"
			play_songs "$ids"
		fi
		echo
		read -p "What song(s) would you like to find? " title artist
	done
	IFS=" "
}

function download_songs() {
	clear
	printf "*** Download Songs ***\n"
	printf "Please enter the title and artist of the song you want to download. Both the title and artist may only contain alphanumeric characters, spaces, commas, and periods.\n"
	read -p "Title: " title
	read -p "Artist: " artist
	if [[ ! "$title" =~ (^[A-Za-z0-9,. ]+$) ]]; then
		printf "\nInvalid title. Press [Enter] to continue."
		read
	elif [[ ! "$artist" =~ (^[A-Za-z0-9,. ]+$) ]]; then
		printf "\nInvalid artist. Press [Enter] to continue."
		read
	else
		read -p "Please enter the URL of the song file: " url
		printf "\nDownloading..."
		let id_new="1 + $(gsed -r 's/^.*\(([0-9]+)\)$/\1/g' catalog.txt | sort -n | tail -1)"
		cd songs
		wget -O "$id_new.mp3" "$url"
		cd ..
		printf "$title by $artist ($id_new)\n" >> catalog.txt
		printf "$title by $artist has been successfully downloaded and saved under the ID $id_new. Press [Enter] to continue."
		read
	fi
}

function register() {
	clear
	printf "*** Register an Account ***\n"
	printf "Please enter a unique username and a password containing at least 8 characters, including an uppercase letter, a lowercase letter, and a number. Both the username and password may only contain alphanumeric characters.\n"
	read -p "Enter username: " username
	if [[ ! "$username" =~ ^[A-Za-z0-9]+$ ]] || [ -n "$(cut -d, -f2 < users.txt | ggrep -iE "$username")" ]; then
		printf "\nUsername is invalid or already taken. Press [Enter] to continue.\n"
		read
		return 1
	else
		read -sp "Enter password: " password
		if [[ ! "$password" =~ ^[A-Za-z0-9]+$ ]] || [ -z "$(echo "$password" | ggrep -E ".{8,}" | ggrep -E "[A-Z]+" | ggrep -E "[a-z]+" | ggrep -E "[0-9]+")" ]; then
			printf "\nPassword is invalid. Press [Enter] to continue.\n"
			read
			return 1
        	else
			printf "$username,$password\n" >> users.txt
			printf "\nSuccessfully created user $username."
			user="$username"
			return 0
		fi
	fi	
}

function login() {
	clear
	printf "*** Log in to Your Account ***\n"
	read -p "Enter username: " username
	read -sp "Enter password: " password
	lookup="$(ggrep -iE "^$username,$password$" users.txt)"
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
	clear
	printf "*** Search Playlists ***\n"
	printf "To search playlists by name and creator, use \"[name];[creator]\".\n"
	printf "To search playlists by name or creator alone, replace the other search term with *.\n"
	printf "To play a playlist, identify its ID and enter \"play [ID]\".\n"
	printf "Otherwise, press [Enter] to return to the main menu.\n"
	printf "\nNote: Playlists created by other users will only appear in search results if they are public.\n"
	IFS=";"
	echo
	read -p "What playlist(s) would you like to find? " name creator
	while [ -n "$name" ]; do
		if [[ "$name" =~ (play [0-9]+) ]]; then
			id="$(gsed -r 's/^play ([0-9]+)/\1/' <<< "$name")"
			songs="$(ggrep -E "^$id,.*$" <<< "$playlists" | gsed -r 's/^.*,\(([0-9]*(,?[0-9]+)*),\)$/\1/' | sed -r 's/,/\|/g')"
			if [ -z "$songs" ]; then
				printf "\nNo results found for $id, or playlist is empty.."
			else
				printf "\nPlaylist $id found. Songs:\n"
				songs2="$(gsed -r 's/\|/\n/g' <<< "$songs")"
				ggrep -E "^.* \($songs\)$" catalog.txt
				echo
				play_songs "$songs2"
			fi
		else
			if [ -n "$creator" ]; then
				result="$(ggrep -E "^[0-9]+*,$name,$creator,.*$" <<< "$playlists")"
			else
				result="$(ggrep -E "^[0-9]*$name[0-9]*,.*$" <<< "$playlists")"
			fi
			if [ -z "$result" ]; then
				printf "No results found for $name."
			else
				gsed -r 's/^([0-9]+),([^,]*),([^,]*),([^,]*),.*$/\[ID: \1\] "\2" by \3 \(\4\)/g' <<< "$result"
			fi
		fi
		printf "\n"
		read -p "What playlist(s) would you like to find? " name creator
	done
	IFS=" "
}

function edit_playlists() {
	clear
	printf "*** Edit Playlists ***\n"
	printf "Your playlists:\n"
	my_playlists="$(ggrep -E "^[0-9]+*,[^,]*,$user,.*$" <<< "$playlists")"
	gsed -r 's/^([0-9]+),([^,]*),([^,]*),([^,]*),.*$/\[ID: \1\] "\2" by \3 \(\4\)/g' <<< "$my_playlists"
	echo
	printf "To view a playlist, use \"view [playlist ID]\".\n"
	printf "To add a song to a playlist, use \"add [song ID] [playlist ID]\".\n"
	printf "To remove a song from a playlist, use \"rm [song ID] [playlist ID]\".\n"
	printf "To create a new playlist, use \"create\".\n"
	printf "To delete a playlist, use \"del [playlist ID]\".\n"
	printf "Otherwise, press [Enter] to return to the main menu.\n"
	echo
	read option
	while [ -n "$option" ]; do
		if [[ "$option" =~ (^view [0-9]+$) ]]; then
			id_pl="$(gsed -r 's/^view ([0-9]+)$/\1/' <<< "$option")"
			if [ -z "$(ggrep -E "^$id_pl,.*,\([0-9]+,.*\)$" <<< "$my_playlists")" ]; then
				printf "Error: Playlist $id_pl does not exist, is empty, or is not owned by you.\n"
			else
				printf "Playlist $id_pl contains the following songs:\n"
				songs="$(ggrep -E "^$id_pl,.*$" <<< "$my_playlists" | gsed -r 's/^.*,\(([0-9]*(,?[0-9]+)*),\)$/\1/' | gsed -r 's/,/\|/g')"
				songs2="$(gsed -r 's/\|/\n/g' <<< "$songs")"
				ggrep -E "^.* \($songs\)$" catalog.txt
			fi
		elif [[ "$option" =~ (^add [0-9]+ [0-9]+$) ]]; then
			id_song="$(gsed -r 's/^add ([0-9]+) [0-9]+$/\1/' <<< "$option")"
			id_pl="$(gsed -r 's/^add [0-9]+ ([0-9]+)$/\1/' <<< "$option")"
			if [ -z "$(ggrep -E "^$id_pl,.*$" <<< "$my_playlists")" ]; then
				printf "Error: Playlist $id_pl does not exist or is not owned by you.\n"
			elif [ -z "$(ggrep -E "^.* \($id_song\)$" catalog.txt)" ]; then
				printf "Error: Song $id_song does not exist.\n"
			elif [ ! -z "$(ggrep -E "^$id_pl,.*,[^0-9]*$id_song,(.*)$" <<< "$my_playlists")" ]; then
				printf "Error: Song $id_song already exists in playlist $id_pl.\n"
			else
				gsed -r "s/^$id_pl,(.*),\((.*)\)$/$id_pl,\1,\(\2$id_song,\)/" -i playlists.txt
				printf "Song $id_song successfully added to playlist $id_pl.\n"
			fi
		elif [[ "$option" =~ (^rm [0-9]+ [0-9]+$) ]]; then
			id_song="$(gsed -r 's/^rm ([0-9]+) [0-9]+$/\1/' <<< "$option")"
			id_pl="$(gsed -r 's/^rm [0-9]+ ([0-9]+)$/\1/' <<< "$option")"
			if [ -z "$(ggrep -E "^$id_pl,.*$" <<< "$my_playlists")" ]; then
				printf "Error: Playlist $id_pl does not exist or is not owned by you.\n"
			elif [ -z "$(ggrep -E "^.* \($id_song\)$" catalog.txt)" ]; then
				printf "Error: Song $id_song does not exist.\n"
			elif [ ! -z "$(ggrep -E "^$id_pl,.*,[^0-9]*$id_song,(.*)$" <<< "$playlists")" ]; then
				gsed -r "s/^$id_pl,(.*),\((.*,?)$id_song,(.*)\)$/$id_pl,\1,\(\2\3\)/" -i playlists.txt
				printf "Song $id_song successfully removed from playlist $id_pl.\n"
			else
				printf "Error: Song $id_song does not exist in playlist $id_pl.\n"
			fi
		elif [[ "$option" == "create" ]]; then
			read -p "Please enter a name for the playlist (alphanumeric characters only): " pl_name
			if [[ ! "$pl_name" =~ ^[A-Za-z0-9]+$ ]]; then
				printf "\nName is invalid."
				break
			else
				echo
				read -p "Please indicate whether the playlist will be [public/private]: " pl_status
				if [ "$pl_status" != "public" ] && [ "$pl_status" != "private" ]; then
                                	printf "\nResponse is invalid."
				else
					let id_new="1 + $(cut -d, -f1 < playlists.txt | sort -n | tail -1)"
					printf "$id_new,$pl_name,$user,$pl_status,()\n" >> playlists.txt
					printf "Playlist $pl_name by $user has been successfully created.\n"
				fi
			fi
		elif [[ "$option" =~ (^del [0-9]+$) ]]; then
			id_pl="$(gsed -r 's/^del ([0-9]+)$/\1/' <<< "$option")"
			if [ -z "$(ggrep -E "^$id_pl,.*$" <<< "$my_playlists")" ]; then
				printf "Error: Playlist $id_pl does not exist or is not owned by you.\n"
			else
				read -p "Are you sure you want to delete playlist $id_pl [y/n]? " ans
				if [ "$ans" == "y" ]; then
					gsed -r "s/^$id_pl,.*$//" -i playlists.txt
					printf "Playlist $id_pl by $user has been successfully deleted.\n"
				else
					printf "No action taken.\n"
				fi
			fi
		else
			printf "Invalid response."
		fi
		echo
		read -p "Please enter another command, or press [Enter] to return to the main menu: " option
		playlists="$(ggrep -E "^.*,.*,$user,.*$|^.*,.*,.*,public,.*$" playlists.txt | gsed -r 's/ /\n/g')"
		my_playlists="$(ggrep -E "^[0-9]+*,[^,]*,$user,.*$" <<< "$playlists")"
	done
}

function message_login() {
	clear
	printf "\n--------------------------------------------------\n"
        printf "Welcome to tunix, a Unix-based music player!\n"
        printf "You are currently logged in as: $user\n"
        printf "What would you like to do?"
        printf "\n--------------------------------------------------\n"
        printf "(1)     Search songs\n"
        printf "(2)     Search playlists\n"
        printf "(3)     Edit playlists\n"
	printf "(4)     Download songs\n"
        printf "(Enter) Log out"
        printf "\n--------------------------------------------------\n"
}

function main_login() {
	playlists="$(ggrep -E "^.*,.*,$user,.*$|^.*,.*,.*,public,.*$" playlists.txt | gsed -r 's/ /\n/g')"
	message_login
	read option
        while [ -n "$option" ]; do
                case "$option" in
			1)
                                search_songs
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
			4)
				download_songs
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
	printf "(1)     Search songs\n"
	printf "(2)     Register\n"
	printf "(3)     Log in \n"
	printf "(4)     Download songs \n"
	printf "(Enter) Quit"
	printf "\n--------------------------------------------------\n"
}

function main_nologin() {
	message_nologin
	read option
	while [ -n "$option" ]; do
		case "$option" in
			1)
				search_songs
				message_nologin
				;;
			2)
				register
				if [ "$?" -eq 0 ]; then
					main_login
				fi
				message_nologin
				;;
			3)
				login
				if [ "$?" -eq 0 ]; then
					main_login
				fi
				message_nologin
				;;
			4)
				download_songs
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
