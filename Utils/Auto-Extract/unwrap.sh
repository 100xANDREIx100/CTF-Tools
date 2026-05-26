#!/usr/bin/env bash
file="$1"

if [ -z "$file" ]; then
	echo "please provide a file as an argument"
	exit 1
fi

if [ ! -f "$file" ]; then
	echo "The file $file does not exist"
	exit 1
fi

file_type=$(file -b --mime-type "$file")

case "$file_type" in
	application/zip)
		unzip "$file"
		;;
	application/gzip)
		tar -xzf "$file" || gunzip "$file"
		;;
	application/x-tar)
		tar -xf "$file"
		;;
	application/x-bzip2)
		tar -xjf "$file" || bunzip2 "$file"
		;;
	application/x-7z-compressed)
        7z x "$file"
        ;;
    application/x-xz)
        tar -xJf "$file" || unxz "$file"
        ;;
	application/x-rar|application/vnd.rar)
        unrar x "$file" || 7z x "$file"
        ;;
    application/zstd)
        tar -I zstd -xf "$file" 2>/dev/null || unzstd "$file"
        ;;
    application/x-lzma)
        tar --lzma -xf "$file" 2>/dev/null || unlzma "$file"
        ;;
	application/x-cpio)
        cpio -idv < "$file"
        ;;
    application/vnd.debian.binary-package)
        dpkg-deb -x "$file" . || ar x "$file"
        ;;
    application/x-brotli)
        brotli -d "$file"
        ;;
	application/x-iso9660-image)
        7z x "$file"
        ;;
    application/vnd.ms-cab-compressed)
        cabextract "$file" || 7z x "$file"
        ;;
	*)
		echo "Unrecognized or unsupported file. Exiting."
		exit 1;
		;;
esac

