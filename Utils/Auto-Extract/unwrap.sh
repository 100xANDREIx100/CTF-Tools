#!/usr/bin/env bash
file="$1"

if [ -z "$file" ]; then
	echo "please provide a file as an argument"
	exit 1
fi

if [ ! -f "file" ]; then
	echo "The file $file does not exit"
	exit 1
fi

file_type=$(file -b --mime-type "$file")

case "file_type" in
	application/zip)
		unzip "file"
		;;
	application/gzip)
		tar -xzf "file" || gunzip "file"
		;;
	*)
		echo "Unrecognized or unsupported file. Exiting."
		exit 1;
		;;
esac

