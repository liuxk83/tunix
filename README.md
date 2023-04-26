# tunix: A Unix-Based Music Player
*by Kevin Liu*

tunix is an `mpv`-based, command-line music player that allows users to download songs from online, play them, and form playlists from them.

## General

tunix allows users to create accounts for handling music. A user does not need to be logged in order to download, search for, or play songs. To play a song, the user can search for the song via either title/author or song ID. To download a song, the user must provide an appropriate title, author, and MP3 URL.

Once a user is logged in, they have the ability to create and delete playlists, as well as add or remove existing songs to/from these playlists. Each playlist may be set as public or private - public playlists can be viewed and played by any logged-in user, whereas private playlists can only be viewed and played by the creator themself. Thus, a user can only access playlists created by themself or public playlists, and these can be found by searching.

## Usage
To use tunix, run `tunix.sh` (for GNU users) or `tunix_mac.sh` (for MacOS users). Then, follow the instructions given by the program.

Note: tunix uses the `mpv` program to play audio. For more info on how to use `mpv`, see https://mpv.io/manual/master/.

## Contents
tunix is written entirely in Bash. We provide two different scripts: `tunix.sh` for GNU users, and `tunix_mac.sh` for MacOS users.

The songs are stored in the `songs` directory. We have provided five songs to start with:

1. Tobu - Candyland (http://youtube.com/tobuofficial), Released by NCS (https://www.youtube.com/NoCopyrightSounds)
2. DEAF KEV - Invincible [NCS Release]. Music provided by NoCopyrightSounds - Free Download/Stream (http://ncs.io/invincible), Watch (http://youtu.be/J2X5mJ3HDYE)
3. Frederic Chopin - Waltz in D flat major, Op. 64 no. 1 (performed by Olga Gurevich)
4. Antonio Vivaldi - Concerto in B minor, RV 580 (performed by the Modena Chamber Orchestra)
5. Edvard Grieg - Piano Concerto in A Minor, 1st mvt. (performed by the Skidmore College Orchestra)

The songs' information is stored in `catalog.txt`. We have also provided sample users in `users.txt` and playlists in `playlists.txt`.
