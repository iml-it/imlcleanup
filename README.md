# IML CLEANUP #

## Introduction ##

For deleting files older N days in a start folder we oftened used several customized shell scripts using a find command.

The IML CLEANUP simply makes a splitting of logic and configuration data.
It is easier to generate a small config file (especially if you use automation tools like puppet, ansible or chef) then handling several cleanup scripts.

How to get it work:

* In the /etc/imlcleanup.d/ you can put (as many) configfiles you want
* a shell script loops over all config files and performs the actions of all conf files.
* you additionally need to create a cronjob to execute this script regulary (i.e. once per day)

## License ##

GNU General Public License version 3

Copyright (C) 2018  University of Bern; Institute of Medical Education

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Installation ##

### Download ###

1. Download the software and extract it to a folder - i.e. /opt/imlcleanup/
2. create new directory /etc/imlcleanup.d/ OR move directory ./etc/imlcleanup.d/ to /etc

### Security/ Hardening ###

We use the script on a webserver where several services and applications run. Developers and some users sometimes have shell access. The cleanup runs as root.

To prevent that users or applications generate a config file with destructive information we protect the files that they are accessible by root only.

For the installation directory

```shell
# chown -R root:root /opt/imlcleanup/
# chmod 0700 /opt/imlcleanup/imlcleanup.sh
```

For the config files:
```shell
# chown -R root:root /etc/imlcleanup.d/
# chmod 0700 /etc/imlcleanup.d/
# chmod 0600 /etc/imlcleanup.d/*
```

## Command Line Parameters ##

### -h: Help ##

The option -h shows a help:

```shell
Syntax: imlcleanup.sh [options]
    -d             dryrun;  show results but no deletion
    -f [filename]  process given conf file instead of all in /etc/imlcleanup.d
    -h             this help
```

### -f [filename]: Handle a single config file ##

By default all files in /etc/imlcleanup.d/*.conf will be executed.
To specify a single file - if you should have several configs there - you can use -f parameter.
This is useful with -d (dryrun).

### -d: Dryrun ##

Without parameter or -f [filename] delete actions will be performed.
For testing purposes you can use a dryrun to see the found files and empty directories.

## Configuration Files ##

### Example ###

First of all an example:

```text
dir = /your/starting/path
filemask = *.log,*.gz
maxage = 180
maxdepth =
deleteemptydirs = 1
runas = root
```

### Syntax ###

* Variable name starts in first column (no starting spaces)
* followed by space + "=" + space
* followed by value without any quoting

### Variables ###

| Variable          | Description                                | Required                                       |
| ---               | ---                                        | ---                                            |
| _dir_             | \{string\} your starting path for the scan | Y                                              |
| _filemask_        | \{string\} filemask(s)                     | Y                                              |
| _maxage_          | \{int\} max age of a file in days          | Y                                              |
| _maxdepth_        | \{int\} max recursion level                | n (empty is default = no restriction)          |
| _deleteemptydirs_ | \{bool\} flag (0 or 1)                     | n (0 is default = do NOT delete empty folders) |
| _runas_           | \{string\} unix user to run                | n (root is default)                            |


For _dir_ and _filemask_ you can set multiple values: use a comma "," to separate them.

The not required variables can be absent to use its default.

The _runas_ value can be used to switch into a user context. The scan + deletion then is limited to that user access. It is done with ``su - [username] -c [command]`` - so that user needs a login shell.

### My First Config File ###

To start make a copy of the example file in /etc/imlcleanup.d/ and name it _[your-task].conf_.
The extension *.conf will be scanned by default. 

Remark:
It means by renaming a config to .bak (or whatever) is a simple way to disable a job.

## Cronjob ##

In a cron.d config file or crontab of root you need to start the cleanup script for processing all configs at once.

As an example a file /etc/cron.d/imlcleanup can be one line to start it daily at 4:12 am.

```shell
$ cat /etc/cron.d/imlcleanup
12 4 * * *  root  /opt/imlcleanup/imlcleanup.sh >/var/log/last_cleanup.log 2>&1 
```
