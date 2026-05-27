#!/usr/bin/env bash

VERBOSE=false

unwrap(){

	local file="$1"

	if [ ! -f "$file" ]; then
		echo "The file $file does not exist"
		return
	fi

	local file_type=$(file -b --mime-type "$file")

	if [[ "$file_type" != application/* ]]; then
		if [ "$VERBOSE" = true ]; then
            echo "[+] Reached final file: $file ($file_type)"
        fi
		return
	fi

	if [ "$VERBOSE" = true ]; then
        echo "[*] Branch: $file_type -> Extracting '$file'"
    fi

	local before
	before=$(ls -A)

	case "$file_type" in
		application/zip)
			unzip -q "$file" && rm "$file"
			;;
		application/gzip)
			tar -xzf "$file" 2>/dev/null && rm "$file" || gunzip "$file"
			;;
		application/x-tar)
			tar -xf "$file" 2>/dev/null && rm "$file"
			;;
		application/x-bzip2)
			tar -xjf "$file" 2>/dev/null && rm "$file" || bunzip2 "$file"
			;;
		application/x-7z-compressed)
			7z x "$file" >/dev/null 2>&1 && rm "$file"  
			;;
		application/x-xz)
			tar -xJf "$file" 2>/dev/null && rm "$file" || unxz "$file"
			;;
		application/x-rar|application/vnd.rar)
			unrar x "$file" >/dev/null 2>&1 || 7z x "$file" >/dev/null 2>&1
			rm -f "$file"
			;;
		application/zstd)
			tar -I zstd -xf "$file" 2>/dev/null && rm "$file" || unzstd "$file"
			;;
		application/x-lzma)
			tar --lzma -xf "$file" 2>/dev/null && rm "$file" || unlzma "$file"
			;;
		application/x-cpio)
			cpio -idv < "$file" >/dev/null 2>&1
			rm -f "$file"
			;;
		application/vnd.debian.binary-package)
			dpkg-deb -x "$file" . >/dev/null 2>&1 || ar x "$file" >/dev/null 2>&1
			rm -f "$file"
			;;
		application/x-brotli)
			brotli -d "$file" >/dev/null 2>&1
			rm -f "$file"
			;;
		application/x-iso9660-image)
			7z x "$file" >/dev/null 2>&1
			rm -f "$file"
			;;
		application/vnd.ms-cab-compressed)
			cabextract -q "$file" >/dev/null 2>&1 || 7z x "$file" >/dev/null 2>&1
			rm -f "$file"
			;;
		*)
			echo "[-] Unrecognized or unsupported file type: $file_type. Stopping here."
			return
			;;
	esac

	local after
    after=$(ls -A)

	while IFS= read -r current; do
        [ -z "$current" ] && continue
        
        if ! printf "%s\n" "$before" | grep -Fxq "$current"; then
            if [ -d "$current" ]; then
                for inner in "$current"/*; do
                    [ -e "$inner" ] && unwrap "$inner"
                done
            elif [ -f "$current" ]; then
                unwrap "$current"
            fi
        fi
    done <<< "$after"
}
while getopts "v" opt; do
    case ${opt} in
        v ) 
            VERBOSE=true 
            ;;
        \? ) 
            echo "Usage: $0 [-v] <file>"
            exit 1 
            ;;
    esac
done

shift $((OPTIND -1))

init="$1"

if [ -z "$init" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

if [ ! -f "$init" ]; then
    echo "The file $init does not exist"
    exit 1
fi

unwrap "$init"
ls
