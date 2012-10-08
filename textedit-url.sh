#!/bin/sh

# set these to debug
LOGERRORS=true
LOGFILE=~/textedit_url.log

# parse input
LILYURL=$1
$LOGERRORS && echo $LILYURL >> $LOGFILE
# textedit:///path/to/file:line:start:end
# strip 'textedit://'
LILYURL=${LILYURL:11}

# get position of second colon
INDEX=$( expr index $LILYURL : )
let "INDEXL = INDEX - 1" # subtract 1 to be left of '%'
# strip filename
FILENAME=${LILYURL:0:INDEXL}
LILYURL=${LILYURL:INDEX}

# check if file exists and is readable
if [ ! -f $FILENAME -o ! -r $FILENAME ]
then
	$LOGERRORS && echo "file $FILENAME does not exist, or is not readable" >> $LOGFILE
	exit 1
fi

# get position of third colon
INDEX=$( expr index $LILYURL : )
let "INDEXL = INDEX - 1"
# strip line number
LINENUM=${LILYURL:0:INDEXL}
LILYURL=${LILYURL:INDEX}

# get position of fourth colon
INDEX=$( expr index $LILYURL : )
let "INDEXL = INDEX - 1"
# strip start pos
STARTPOS=${LILYURL:0:INDEXL}
let "STARTPOS = STARTPOS + 1" # add 1 so vim selects correct character

# pass command to editor
KEYS="+:${LINENUM}:norm${STARTPOS}"
$LOGERRORS && echo $KEYS >> $LOGFILE
gvim --remote $KEYS $FILENAME

# focus editor
xdotool search --name $( basename $FILENAME ) windowactivate --sync

# if the file is being opened, it might take a while for the window
#+ title to change, so we repeat the focus after a bit
sleep 0.5s
xdotool search --name $( basename $FILENAME ) windowactivate --sync

