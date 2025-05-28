#!/bin/bash

read -p "Enter the YouTube URL: " url
read -p "Enter the artist name: " artist
read -p "Enter the song name: " song
read -p "Enter seconds to trim from start (or press enter for no trimming): " start_time
read -p "Enter seconds to trim from end (or press enter for no trimming): " end_time

# Create songs directory if it doesn't exist
mkdir -p "$HOME/Documents/songs"

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
output_file="$HOME/Documents/songs/${artist} - ${song}.mp3"

# If either start_time or end_time is provided, trim the audio
if [ ! -z "$start_time" ] || [ ! -z "$end_time" ]; then
    # Get the total duration of the file
    total_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$downloaded_file")
    
    # Calculate the end time
    if [ ! -z "$end_time" ]; then
        end_time_absolute=$(echo "$total_duration - $end_time" | bc)
    else
        end_time_absolute=$total_duration
    fi
    
    # Build the ffmpeg command
    trim_cmd="ffmpeg -i \"$downloaded_file\""
    
    if [ ! -z "$start_time" ]; then
        trim_cmd="$trim_cmd -ss $start_time"
    fi
    
    if [ ! -z "$end_time" ]; then
        trim_cmd="$trim_cmd -to $end_time_absolute"
    fi
    
    trim_cmd="$trim_cmd -c copy \"$temp_dir/trimmed.mp3\""
    
    # Execute the trim command
    eval $trim_cmd
    
    # Then add metadata and artwork to the trimmed file
    ffmpeg -i "$temp_dir/trimmed.mp3" -i "$temp_dir/artwork.jpg" -map 0:0 -map 1:0 -metadata artist="$artist" -metadata title="$song" -codec copy "$output_file"
else
    # Just add metadata and artwork without trimming
    ffmpeg -i "$downloaded_file" -i "$temp_dir/artwork.jpg" -map 0:0 -map 1:0 -metadata artist="$artist" -metadata title="$song" -codec copy "$output_file"
fi

# Clean up temporary files
rm -rf "$temp_dir"

# Open the file in Apple Music
open -a Music "$output_file"

