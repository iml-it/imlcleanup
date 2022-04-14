# Features #

In the /etc/imlcleanup.d/ folder can be several configurations - one per cleanup job.

The cleanup script loops over them and executes each profile:

* file deletion > N days of files with given file masks
* optional: limit folder depth for scan
* optional: delete empty folders
* optional: run as given user
* supports a dry run

The config files have a very sinple syntax. It is easy to creat by Ansible or puppet.
