#!/bin/bash

read -p "Enter the YouTube URL: " url
read -p "Enter the artist name: " artist
read -p "Enter the song name: " song

# Download the audio and save with a temporary name
yt-dlp -x --audio-format mp3 -o "$HOME/Downloads/temp_%(id)s.%(ext)s" "$url"

# Get the downloaded file name
downloaded_file=$(ls -t "$HOME/Downloads/temp_"* | head -n1)

# Add metadata and rename the file
ffmpeg -i "$downloaded_file" -metadata artist="$artist" -metadata title="$song" -codec copy "$HOME/Downloads/${artist} - ${song}.mp3"

# Remove the temporary file
rm "$downloaded_file"

