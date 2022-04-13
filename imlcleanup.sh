#!/bin/bash
# ======================================================================
#
# IML CLEANUP SCRIPT
#
# remove outdated files and remove empty directories
# by reading config files from /etc/imlcleanup.d
#
# ----------------------------------------------------------------------
# 2018-06-18  <axel.hahn@iml.unibe.ch> v1.0
# 2018-06-19  <axel.hahn@iml.unibe.ch> v1.1  parameter support
# 2022-03-11  <axel.hahn@iml.unibe.ch> v1.2  shell fixes; update message if dir does not exist
# 2022-03-13  <axel.hahn@iml.unibe.ch> v1.3  Fix: do not delete start dir while deleting empty subdirs
# ======================================================================

# ----------------------------------------------------------------------
# VARS
# ----------------------------------------------------------------------

confdir=/etc/imlcleanup.d
sConfFiles="$confdir/*.conf"
tmperrorfile=/tmp/imlcleanup.err
typeset -i bDryrun=0


cmdFiles="rm -f"
cmdDirs="rmdir"

# ----------------------------------------------------------------------
# FUNCTIONS
# ----------------------------------------------------------------------

# helper function - read a variable
# function requires $mycfgfile that is used in the loop of main part
function getValue(){
        cat "${mycfgfile}" | grep "^$1\ = " | cut -f 3- -d " "
}

# show help
function usage(){
        echo "Syntax: $(basename $0) [options]"
        echo "    -d             dryrun;  show results but no deletion"
        echo "    -f [filename]  process given conf file instead of all in $confdir/"
        echo "    -h             this help"
        echo
}

# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------
cat <<endofheader
 _______ _______ _____        ______ __
|_     _|   |   |     |_     |      |  |.-----.---.-.-----.--.--.-----.
 _|   |_|       |       |    |   ---|  ||  -__|  _  |     |  |  |  _  |
|_______|__|_|__|_______|    |______|__||_____|___._|__|__|_____|   __|
                                                                |__|
endofheader

while getopts ":d :f: :h" o; do
    case "${o}" in
        d)
            bDryrun=1
            cmdFiles="ls -l"
            cmdDirs="ls -ld"
            echo "INFO: dryrun is active. Just showing the files; no deletion"
            ;;
        f)
            sConfFiles=${OPTARG}
            ls -l $sConfFiles  >/dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "ERROR: -f [$sConfFiles]"
                echo "           ^"
                echo "           |"
                echo "           +-- the given filename seems to be wrong"
                echo
                exit 1
            fi
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            echo "ERROR: Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        *)
            # usage
            ;;
    esac
done
shift $((OPTIND-1))

rm -f $tmperrorfile 2>/dev/null

ls -l $sConfFiles  >/dev/null 2>&1
if [ $? -ne 0 ]; then
        echo SKIP nothing to do.
        echo The directory $confdir does not exist or has no *conf files. But this is no error.
        echo
        exit 0
fi

echo "INFO: reading configs from $sConfFiles"
ls -1 $sConfFiles | while read -r mycfgfile
do
        echo
        echo ">>>>>>>>>> PROCESSING $mycfgfile ..." | tee -a $tmperrorfile
        echo
        # cat $mycfgfile
        mydirs=$(getValue dir)
        filemasks=$(getValue filemask)
        typeset -i iAge
        iAge=$(getValue maxage)
        typeset -i iMaxDepth
        iMaxDepth=$(getValue maxdepth)

        bDeleteemptydirs=$(getValue deleteemptydirs)
        sRunAs=$(getValue runas)

        # ----- checks
        if [ -z "$mydirs" -o -z "$filemasks" -o -z "$iAge" ]; then
                echo ERROR: invalid config file $mycfgfile        | tee -a $tmperrorfile
                echo dir, filemask and maxage are required values | tee -a $tmperrorfile
                echo
        else
                # maxdepth for scanning
                depthParam=
                if [ $iMaxDepth -gt 0 ]; then
                        depthParam="-maxdepth $iMaxDepth"
                fi

                # split filemasks by "," and add -name params
                #   filemask = *.log,*.gz
                #   ... results in
                #   \( -name "*.log" -o -name "*.gz" \)
                maskParam="$(echo "${filemasks}" | sed 's#,#\" -o -name \"#g')"

                if [ $? -ne 0 ]; then
                        echo ERROR: user [$sRunAs] is unknown | tee -a $tmperrorfile
                else

                        # run as a given user
                        suPrefix="su - $sRunAs -c "

                        # split mydirs by "," and add loop
                        echo $mydirs | sed "s#,#\\n#g" | while read mydir
                        do
                                echo "-----> $mydir" | tee -a $tmperrorfile
                                echo
                                if [ ! -d "$mydir" ]; then
                                        echo ERROR: $mydir does not exist or is not a directory | tee -a $tmperrorfile
                                        echo Skipping this dir                                  | tee -a $tmperrorfile
                                else
                                        echo "[1] cleanup ${filemasks} older ${iAge} days" | tee -a $tmperrorfile
                                        set -vx
                                        $suPrefix "find ${mydir} $depthParam -type f \( -name \"${maskParam}\" \) -mtime +${iAge} -print -exec $cmdFiles {} \;" \
                                                2>>$tmperrorfile \
                                                || echo ERROR: cleanup of files failed \
                                                | tee -a $tmperrorfile
                                        set +vx

                                        if [ "$bDeleteemptydirs" = "1" ]; then
                                                echo [2] Delete empty dirs | tee -a $tmperrorfile
                                                set -vx
                                                ${suPrefix} "find ${mydir} ${depthParam} -mindepth 1 -depth -type d -empty -print -exec $cmdDirs {} \;" \
                                                        2>>$tmperrorfile \
                                                        || echo ERROR: cleanup of empty dirs failed \
                                                        | tee -a $tmperrorfile
                                                set +vx
                                        else
                                                echo [2] SKIP: no scan for empty directories | tee -a $tmperrorfile
                                        fi
                                fi
                                echo
                        done
                fi
        fi
done

echo ---------- DONE
typeset -i iErrors=$(grep "ERROR" $tmperrorfile | wc -l)
echo ERRORS: $iErrors
echo
if [ $iErrors -gt 0 ]; then
  echo places of found errors:
  cat $tmperrorfile
  echo
fi
rm -f $tmperrorfile
exit $iErrors
