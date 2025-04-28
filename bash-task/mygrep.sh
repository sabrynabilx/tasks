#!/bin/bash

show_help() {
    echo "Usage: $0 [options] search_string filename"
    echo "Options:"
    echo "  -n    Show line numbers"
    echo "  -v    Invert match (show non-matching lines)"
    echo "  --help Show this help message"
    exit 0
}

# Check if no arguments
if [[ $# -lt 1 ]]; then
    echo "Error: Too few arguments."
    show_help
    exit 1
fi

show_line_numbers=false
invert_match=false

# Parse options
while [[ "$1" == -* ]]; do
    if [[ "$1" == "--help" ]]; then
        show_help
    fi

    # Remove the first "-" and loop over each character
    option="${1#-}"
    for (( i=0; i<${#option}; i++ )); do
        case "${option:$i:1}" in
            n) show_line_numbers=true ;;
            v) invert_match=true ;;
            *) echo "Unknown option: -${option:$i:1}"; exit 1 ;;
        esac
    done
    shift
done

# Now expect search_string and filename
if [[ $# -lt 2 ]]; then
    echo "Error: Missing search string or filename."
    show_help
    exit 1
fi

search_string="$1"
filename="$2"

if [[ ! -f "$filename" ]]; then
    echo "Error: File '$filename' not found."
    exit 1
fi

line_number=0

# Read file line by line
while IFS= read -r line; do
    ((line_number++))

    # Check match (case-insensitive)
    if echo "$line" | grep -iq -- "$search_string"; then
        match=true
    else
        match=false
    fi

    # Invert if needed
    if $invert_match; then
        if $match; then
            match=false
        else
            match=true
        fi
    fi

    # Print if match
    if $match; then
        if $show_line_numbers; then
            echo "${line_number}:$line"
        else
            echo "$line"
        fi
    fi
done < "$filename"

