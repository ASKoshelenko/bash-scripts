#!/bin/bash

currentVersion="0.0.1"

show_help() {
    printf "  %-20s %s\n" "Description:" "Bash tool to transfer files from the command line."
    printf "Usage:"
    printf "  %-20s %s\n" "-d <directory> <file_id> <file_name>" "Download a single file from transfer.sh to the specified directory."
    printf "  %-20s %s\n" "-h" "Show this help message."
    printf "  %-20s %s\n" "-v" "Get the tool version."
    printf "  %-20s %s\n" "Examples:" "./transfer.sh test.txt ..."
}

show_version() {
    echo $currentVersion
}

httpSingleUpload() {
    response=$(curl --upload-file "$1" "https://free.keep.sh") || {
        echo "Failure!"
        return 1
    }
}

printUploadResponse() {
    file_link=$(echo "$response" | grep -o 'https://free.keep.sh/[^[:space:]]*')
    echo "$response" | sed '$d'
    echo "Transfer File URL: $file_link"
}

singleUpload() {
    filePath=${1//\~/$HOME}
    if [ ! -f "$filePath" ]; then {
        echo "Error: invalid file path"
        return 1
    }; fi
    tempFileName=$(echo "$1" | sed "s/.*\///")
    echo "Uploading $tempFileName"
    httpSingleUpload "$filePath"
}

singleDownload() {
    directory="$1"
    file_id="$2"
    file_name="$3"

    if [ ! -d "$directory" ]; then
        mkdir -p "$directory" || {
            echo "Error: Failed to create directory $directory"
            return 1
        }
    fi

    echo "Downloading $file_name"
    response=$(curl -L "https://free.keep.sh/$file_id/$file_name" >"$directory/$file_name") || {
        echo "Failure!"
        return 1
    }
}

printDownloadResponse() {
    echo "$response"
    echo "Success!"
}

while getopts ":d:hv" opt; do
    case $opt in
    d)
        directory="$OPTARG"
        ;;
    h)
        show_help
        exit 0
        ;;
    v)
        show_version
        exit 0
        ;;
    \?)
        echo "Invalid option: -$OPTARG"
        exit 1
        ;;
    esac
done

shift $((OPTIND - 1))

# Check if -d flag is provided to trigger the download
if [[ -n "$directory" ]]; then
    if [[ $# -eq 2 ]]; then
        file_id="$1"
        file_name="$2"
        singleDownload "$directory" "$file_id" "$file_name"
        printDownloadResponse
    else
        echo "Invalid number of arguments for -d flag."
        exit 1
    fi
elif [[ $# -gt 0 ]]; then
    # If no -d flag, assume it's an upload operation
    for file in "$@"; do
        singleUpload "$file" || exit 1
        printUploadResponse
    done
else
    # If no flags or arguments provided, show help message
    show_help
    exit 1
fi