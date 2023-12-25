## Task

### Story

Your college has developed a script to upload files from terminal to https://free.keep.sh Unfourtenetly, he has left the company. **The script isn't working now**. Your team asked for a new functionality to download uploaded files.

Create a script which will upload and download file from transfer.sh. Add a description in the beggining of the script and comment the code. Please also follow the Bash Style Guide.

## Checks

### Upload

Upload should support uploading multiple files, as in example:

```bash
user@laptop:~$ ./transfer.sh test.txt test2.txt
Uploading test.txt
...
Transfer File URL: https://free.keep.sh/Mij6ca/test.txt
Uploading test2.txt
...
Transfer File URL: https://free.keep.sh/Msfddf/test2.txt
```

### Download

Add a download flag `-d` which would download single file from the transfer.sh to the specified directory:
Progress bar should be in output. (Hint: check flags)

> :warning: Create a function for downloading files: `singleDowload` and for returning the result: `printDownloadResponse`

```bash
user@laptop:~$ ls
test test.txt transfer.sh

user@laptop:~$ ./transfer.sh -d ./test Mij6ca test.txt
Downloading test.txt
...
Success!
```

### Help

Add a help flag `-h` to output the help message with decription, how to work with the script:

```bash
user@laptop:~$ ./transfer.sh -h
Description: Bash tool to transfer files from the command line.
Usage:
  -d  ...
  -h  Show the help ...
  -v  Get the tool version
Examples:
<Write a couple of examples, how to use your tool>
./transfer.sh test.txt ...
```

### Version

Add a flag to get your script version:

```bash
user@laptop:~$ ./transfer.sh -v
0.0.1
```
