# duplic

It is a simple project making use of *duplicity* https://en.wikipedia.org/wiki/Duplicity_(software) software suite. It allows a single point for making a backup copy for users in the Linux system.<br>

# Configuration

## General idea

There are two configration point: at the user level and at the root user reponsible for making a backup copy.<br>
* At the user level, there is a specification of directories to be backuped, a *--include* parameter for *duplicity* command.
* At the root user level, there is a specification of backup destination and *crontab* job. 

So the user is providing *what* is backuped and the root user is defining *where* and *when*.

## Installation

