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
| DUPLICITY | Path for *duplicity* utility. If the script is to be executed as cron job, it is recommended to define a full path | DUPLICITY=/var/lib/snapd/snap/bin/duplicity
| LISTOFUSERS | List of space separated users id. The user must exist in the system | "sbartkowski wiki"
| LOGDIR | Log directory | /tmp/dupllog
| LISTOFDEST | List of space separated backup destination names. The namea are arbtrary and should be followed by destination specification | "file remoteserver". In every destination, the tool is creating *dupl.username* directory for backup containers.
| "destname" | The variable should exist in the LISTOFDEST variable. Contains the destination specification expected by *duplicity* | file="file:///tmp/local"

## Configuration for a user

The user specific file is expected to be *USERHOME*/dupl/dupl.rc

> vi  ~/dupl/dupl.rc<br>

| Variable | Description | Sample
| ---- | ----- | ----- |
| PASSPHRASE | Specific for *duplicity*. Used for backup encryption.  | PASSPHRASE=sbartkowski
| DINCLUDE | Parameter passed to *duplicity* tool. Contains all directories to be backuped | DINCLUDE="--include $DHOME/dupl --include $DHOME/.local/share/gnote --include $DHOME/projects --include $DHOME/.var/app/org.gnome.Gnote"

Example.<br>
Variable *DHOME* here is used only to simplify the setting of *DINCLUDE* variable.

```
PASSPHRASE=sbartkowski
DHOME=/home/sbartkowski
DINCLUDE="--include $DHOME/dupl --include $DHOME/.local/share/gnote --include $DHOME/projects --include $DHOME/.var/app/org.gnome.Gnote"
```

## Execution

>./run.sh /dest/<br>
<br>

The tool requires a single parameter, the destination name. The destination name is expected to be one of the name on *LISTOFDEST* list. It makes a backup copy for all users specified in *LISTOFUSERS* list.<br>

## Making a backup

The tool is running *duplicity* command for every user listed in the *LISTOFUSERS* variable. If the variable contains the names of three users, three *duplicity* is executed three times. The *duplicity* command is constructed using definitions found in command *resource.rc* file and user specific *userhome/dupl/dupl.rc* file.<br>

Example:

> cat resource.rc<br>
```
DUPLICITY=/usr/bin/duplicity

LISTOFUSERS="sbartkowski"
LOGDIR=/tmp/dupl
LISTOFDEST="file"
file="file:///tmp/local"
```

> cat ~/dupl/dupl.rc
```
PASSPHRASE=sbartkowski
DHOME=/home/sbartkowski
DINCLUDE="--include $DHOME/dupl --include $DHOME/.local/share/gnote --include $DHOME/projects --include $DHOME/.var/app/org.gnome.Gnote"
```

Command.

>./dupl.sh file<br>

Corresponding duplicity command.<br>
> /usr/bin/duplicity -v 5 /home/sbartkowski --include /home/sbartkowski/dupl --include /home/sbartkowski/.local/share/gnote --include /home/sbartkowski/projects --include /home/sbartkowski/.var/app/org.gnome.Gnote --exclude ** --full-if-older-than 1M --allow-source-mismatch file:///tmp/local/dupl.sbartkowski

Several remarks:<br>
* In the target backup directory, the tools is creating a specific for user *dupl.username* directory. Here *dupl.sbartkowski*
* Full, not incremental, backup every 1 N
* Important: after every run, the tools is removing all copies older then 2 months. Only last 2 months copies are stored.
