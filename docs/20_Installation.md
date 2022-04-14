
# Installation #

## Download ##

1. Download the software and extract it to a folder - i.e. /opt/imlcleanup/
2. create new directory /etc/imlcleanup.d/ OR move directory ./etc/imlcleanup.d/ to /etc

## Security/ Hardening ##

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