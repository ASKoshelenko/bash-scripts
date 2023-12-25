#!/bin/bash

function format_name() {
    local first_name last_name
    read -r first_name last_name <<<"$(echo "$1" | tr '[:upper:]' '[:lower:]')"
    first_name=$(tr '[:lower:]' '[:upper:]' <<<"${first_name:0:1}")${first_name:1}
    last_name=$(tr '[:lower:]' '[:upper:]' <<<"${last_name:0:1}")${last_name:1}

    if [[ $last_name == *-* ]]; then
        hyphen_pos=$(expr index "$last_name" "-")
        last_name=${last_name:0:hyphen_pos}$(tr '[:lower:]' '[:upper:]' <<<"${last_name:$hyphen_pos:1}")${last_name:$hyphen_pos+1}
    fi
    echo "$first_name $last_name"
}

function generate_email() {
    local alias=$1
    local location_id=$2
    local domain="@abc.com"
    email=${alias}

    if check_alias "${alias}" "${alias_array[@]}"; then
        email=${email}${location_id}
    fi

    email=${email}${domain}
    echo "$email"
}

# to bedzie czeck alias
function check_alias() {
    local alias="$1"
    shift
    local alias_array=("$@")

    local count=0

    for element in "${alias_array[@]}"; do
        if [[ "$element" == "$alias" ]]; then
            ((count++))
        fi
    done

    if ((count > 1)); then
        return 0 # Alias appears more than once, return true
    else
        return 1 # Alias appears zero or one time, return false
    fi
}

# funcja na tworzenie aliasa
function create_email_alias() {
    local first_name="${1%% *}"
    local last_name="${1#* }"

    alias=$(echo "${first_name:0:1}${last_name}" | tr '[:upper:]' '[:lower:]')
    echo "$alias"
}

if [ $# -ne 1 ]; then
    echo "Usage: $0 <accounts.csv>"
    exit 1
fi

alias_array=()

input_file=$1
output_file="accounts_new.csv"

read -r header <"$input_file"
echo "$header" >"$output_file"

skip_header=true

# while, który przeleci przez csv, stworzy aliasy i doda je do arraya
while IFS=',' read -r id location_id name title email department; do
    if $skip_header; then
        skip_header=false
        continue
    fi

    alias_array+=("$(create_email_alias "$name")")
done <"$input_file"

skip_header=true

while IFS= read -r line; do
    if $skip_header; then
        skip_header=false
        continue
    fi

    if [[ $line =~ \".*\" ]]; then
        title_with_quotes=$(echo "$line" | grep -o '".*"')
        #echo $title_with_quotes
    fi

    IFS=',' read -r id location_id name title email department <<<"$line"

    formated_name=$(format_name "$name")
    formated_email=$(generate_email "$(create_email_alias "$name")" "$location_id")

    if [[ -n $title_with_quotes ]]; then
        title="$title_with_quotes"
    fi

    title_with_quotes=""

    echo "$id,$location_id,$formated_name,$title,$formated_email,$department" >>"$output_file"
done <"$input_file"

skip_header=true

echo "processing done. $output_file created."
