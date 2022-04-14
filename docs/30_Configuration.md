
# Configuration Files #

## Example ##

First of all an example:

```text
dir = /your/starting/path
filemask = *.log,*.gz
maxage = 180
maxdepth =
deleteemptydirs = 1
runas = root
```

## Syntax ##

* Variable name starts in first column (no starting spaces)
* followed by space + "=" + space
* followed by value without any quoting

## Variables ##

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

## My First Config File ##

To start make a copy of the example file in /etc/imlcleanup.d/ and name it _[your-task].conf_.
The extension *.conf will be scanned by default. 

Remark:
It means by renaming a config to .bak (or whatever) is a simple way to disable a job.
