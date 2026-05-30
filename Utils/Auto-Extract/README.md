# Auto-Extract 

A robust, lightweight Bash script to automatically peel through deeply nested, multi-format archives. This is primarily used during CTF (Capture The Flag) Forensics and Misc challenges to bypass "Matryoshka doll" compression loops. It relies strictly on file signatures (MIME types) rather than file extensions to outsmart disguised files and intentional renaming tricks.

## 🚀 Setup

### 📥 Installation

You can download the script directly to your machine using `wget` or `curl`:

```bash
wget https://raw.githubusercontent.com/100xANDREIx100/CTF-Tools/refs/heads/main/Utils/Auto-Extract/unwrap.sh
```

This script requires standard Linux archiving utilities to handle the various formats. Install the comprehensive suite using a Debian/Ubuntu-based package manager (like on Kali or Parrot OS):

```bash
sudo apt update
sudo apt install unzip tar bzip2 p7zip-full xz-utils unrar zstd lzma cpio binutils brotli cabextract
```

Make sure the script is executable before running it:

```bash
chmod +x unwrap.sh
```

## ⚙️ Usage
Run the script by providing the target archive file. By default, it will recursively extract everything in the current directory with completely silent output until it hits the final, non-archive file.

```bash
./unwrap.sh [OPTIONS] <file>
```
Supported Formats: `zip`, `tar`, `gzip`, `bzip2`, `7z`, `xz`, `rar`, `zstd`, `lzma`, `cpio`, `deb`, `brotli`, `iso`, `cab`

### 🧹 Intermediate File Handling

Matryoshka challenges are notoriously designed to generate massive amounts of file bloat (e.g., a `.tar` inside a `.zip` inside a `.gz`). To prevent your local drive from filling up with hundreds of redundant archive layers, this script automatically cleans up the intermediate files as it traverses down the tree. It leaves behind only the final, uncompressed payload.


### Example 1: Standard Extraction
If you just want the final file without any terminal clutter:
```bash
./unwrap.sh challenge_100x.tar

# The script runs silently and leaves the final extracted file in your directory.
```
### Example 2: Verbose Mode & Workspace Isolation
CTF archives can sometimes be "zip bombs" or contain hundreds of loose files. Use the -o flag to create an isolated sandbox directory, and the -v flag to track exactly which compression branches the script takes.
```bash
./unwrap.sh -v -o ctf_workspace challenge.zip

[*] Initializing workspace directory: ctf_workspace
[*] Branch: application/zip -> Extracting 'challenge.zip'
[*] Branch: application/x-tar -> Extracting 'layer2.tar'
[*] Branch: application/gzip -> Extracting 'layer3.tar.gz'
[+] Reached final file: flag.txt (text/plain)
```
### Help Menu
For a quick reminder of the arguments and supported formats from the terminal, use the -h flag:
```bash
./unwrap.sh -h
```
## 🛠️ Under the Hood: MIME > Extensions

Challenge authors frequently use intentional misdirection, such as naming a compressed BZIP2 archive `flag.jpeg`, to break standard automated extraction loops. 

This script is built to ignore file extensions entirely. Instead, it relies on the `file --mime-type` command to inspect the actual file signature (magic bytes) at every single layer. By reading the underlying binary structure, the script identifies exactly what kind of archive it is dealing with and dynamically hands it off to the correct utility.
