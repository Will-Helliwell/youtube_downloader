#!/bin/bash

read -p "Enter the YouTube URL: " url
read -p "Enter the artist name: " artist
read -p "Enter the song name: " song

# Create a temporary directory for our files
temp_dir=$(mktemp -d)

# Download the audio and save with a temporary name
yt-dlp -x --audio-format mp3 -o "$temp_dir/temp_%(id)s.%(ext)s" "$url"

# Download the thumbnail and convert to jpg
yt-dlp --skip-download --write-thumbnail -o "$temp_dir/thumbnail" "$url"
thumbnail_file=$(ls -t "$temp_dir/thumbnail"* | head -n1)
ffmpeg -i "$thumbnail_file" "$temp_dir/artwork.jpg"

# Get the downloaded file names
downloaded_file=$(ls -t "$temp_dir/temp_"* | head -n1)

# Add metadata and artwork, then rename the file
ffmpeg -i "$downloaded_file" -i "$temp_dir/artwork.jpg" -map 0:0 -map 1:0 -metadata artist="$artist" -metadata title="$song" -codec copy "$HOME/Downloads/${artist} - ${song}.mp3"

# Clean up temporary files
rm -rf "$temp_dir"

