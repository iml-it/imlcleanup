
# Command Line Parameters #

## -h: Help #

The option -h shows a help:

```shell
Syntax: imlcleanup.sh [options]
    -d             dryrun;  show results but no deletion
    -f [filename]  process given conf file instead of all in /etc/imlcleanup.d
    -h             this help
```

## -f [filename]: Handle a single config file ##

By default all files in /etc/imlcleanup.d/*.conf will be executed.
To specify a single file - if you should have several configs there - you can use -f parameter.
This is useful with -d (dryrun).

## -d: Dryrun ##

Without parameter or -f [filename] delete actions will be performed.
For testing purposes you can use a dryrun to see the found files and empty directories.

# Cronjob #

In a cron.d config file or crontab of root you need to start the cleanup script for processing all configs at once.

As an example a file /etc/cron.d/imlcleanup can be one line to start it daily at 4:12 am.

```shell
$ cat /etc/cron.d/imlcleanup
12 4 * * *  root  /opt/imlcleanup/imlcleanup.sh >/var/log/last_cleanup.log 2>&1 
```
