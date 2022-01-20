# duplic

It is a simple project making use of *duplicity* https://en.wikipedia.org/wiki/Duplicity_(software) software suite. It allows a single point for making a backup copy for users in the Linux system.<br>

# Configuration

## General idea

There are two configration point: at the user level and at the root user reponsible for making a backup copy.<br>
* At the user level, there is a specification of directories to be backuped, a *--include* parameter for *duplicity* command.
* At the root user level, there is a specification of backup destination and *crontab* job. 

So the user is providing *what* is backuped and the root user is defining *where* and *when*.

## Installation

The tools is executed by *root* user. <br>

> git clone https://github.com/stanislawbartkowski/duplic.git

## Configuration

*Template* folder contains sample example of configuration files to be configured.

> cp template/* . <br>

> vi resource.rc<br>

The *resource.rc* file contains a list of users to be backuped and list of backup destinations.

| Variable | Description | Sample
| ---- | ---- | ---- |
| DUPLICITY | Path for *duplicity* script | DUPLICITY=/var/lib/snapd/snap/bin/duplicity
| LISTOFUSER | List of space separated users id. The user must exist in the system | "sbartkowski wiki"
| LOGDIR | Log directory | /tmp/dupllog
| LISTOFDEST | List of space separated backup destination names. The namea are arbtrary and should be followed by destination specification | "file remoteserver"
| "destname" | The variable should exist in the LISTOFDEST variable. Contains the destination specification expected by *duplicity* | file="file:///tmp/local"

## Execution

>./run.sh /dest/<br>
<br>
*run.sh* requires a single parameter, the destination name. The destination name is expected to be one of the name on *LISTOFDEST* list. It makes a backup copy for all users specified in *LISTOFUSER* list.
