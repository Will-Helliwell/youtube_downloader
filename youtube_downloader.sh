#!/bin/bash

read -p "Enter the YouTube URL: " url
read -p "Enter the artist name: " artist
read -p "Enter the song name: " song

yt-dlp -x --audio-format mp3 -o "$HOME/Downloads/${artist} - ${song}.%(ext)s" "$url"

