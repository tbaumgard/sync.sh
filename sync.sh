#!/bin/sh
# Sync a file or directory with another file or directory using rsync.
# Author: Tim Baumgard
# License: 3-Clause BSD

# ------------------------------------------------------------------------------
# Customize these functions to fit the platform and desired preferences.

# $1 = path to file or directory to be opened
opener() {
	open "$1"
}

# $1 source file or directory
# $2 destination file or directory
differ() {
	diff -u -r \
		--exclude='.Trash*' \
		--exclude='.DS_Store' \
		"$2" "$1"
}

# $1 = delete flag
# $2 = commit flag
# $3 = source file or directory
# $4 = destination file or directory
syncer() {
	rsync -av $1 $2 \
		--omit-dir-times \
		--checksum \
		--progress \
		--stats \
		--exclude '.Trash*' \
		--exclude '.DS_Store' \
		"$3" "$4"
}

# ------------------------------------------------------------------------------

script="$(basename "$0")"
source=""
destination=""
deleteFlag=""
commitFlag="--dry-run"
runDiff=""
runOpen=""

usage() {
	printf "%s\n\n" "Usage: $script [options] --source path/to/source --destination path/to/destination"
	printf "%s\n" "--help"
	printf "%s\n\n" "Display the help message and exit."
	printf "%s\n" "--source path/to/source"
	printf "%s\n\n" "Path to the source file or directory."
	printf "%s\n" "--destination path/to/destination"
	printf "%s\n\n" "Path to the destination file or directory."
	printf "%s\n" "--delete"
	printf "%s\n\n" "Delete files and directories in the destination that aren't in the source."
	printf "%s\n" "--commit"
	printf "%s\n\n" "Commit the changes to the destination. If not specified, a dry run is performed."
	printf "%s\n" "--diff"
	printf "%s\n\n" "Run diff against the source and destination instead of rsync. The destination must exist."
	printf "%s\n" "--open"
	printf "%s\n\n" "Open the source and destination. The destination is only opened if it exists."
}

error() {
	printf "ERROR: %s\n" "$1" >&2
	exit 1
}

while :; do
	case $1 in
		--delete) deleteFlag="--delete" ;;
		--commit) commitFlag="" ;;
		--diff) runDiff="true" ;;
		--open) runOpen="true" ;;

		-h|-\?|--help)
			usage
			exit 0
			;;
		--source)
			if [ -f "$2" -o -d "$2" ]; then
				source="$2"
				shift
			else
				error "The --source option must be an existing file or directory."
			fi
			;;
		--destination)
			if [ ! -z "$2" ]; then
				if [ ! -e "$2" -a ! -w "$(dirname "$2")" ]; then
					error "The --destination option must have a writable parent directory if it doesn't exist."
				elif [ -e "$2" -a ! -w "$2" ]; then
					error "The --destination option must be writable."
				fi

				destination="$2"
				shift
			else
				error "The --destination option can't be empty."
			fi
			;;
		*)
			break
	esac

	shift
done

if [ -z "$source" ]; then error "A source must be specified."; fi
if [ -z "$destination" ]; then error "A destination must be specified."; fi

# Make sure there's a trailing slash on the source if it's a directory to make
# rsync consider the contents rather the directory itself. See rsync(1).
if [ -d "$source" ]; then
	source=${source%/}
	source="$source/"
fi

if [ ! -z "$runOpen" ]; then
	opener "$source"

	if [ -e "$destination" ]; then
		opener "$destination"
	fi
elif [ ! -z "$runDiff" ]; then
	if [ -e "$destination" ]; then
		differ "$source" "$destination"
	else
		error "diff can't be used when the destination doesn't exist."
	fi
else
	syncer "$deleteFlag" "$commitFlag" "$source" "$destination"
fi
