# IML CLEANUP #

## Introduction ##

Delete files older N days in a start folder we oftened used several customized shell scripts using a find command.

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
