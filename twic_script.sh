#!/bin/bash
#
#
#  Copyright (C) 2011-2015 Vincenzo (KatolaZ) Nicosia <katolaz@yahoo.it>
# 
# 
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.  
# 
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  long with this program.  If not, see  <http://www.gnu.org/licenses/>.
# 
#
#
#  This simple script helps maintaining an updated database of chess games
#  for SCID, based on the famous The Week In Chess game collection made 
#  available at
#   
#  http://www.theweekinchess.com/
# 
#  Games are distributed as zipped png files, which are uploaded weekly
#  on http://www.theweekinchess.com/zips/ (Should that URL change at some 
#  point in the future, you will just need to update the ADDR variable 
#  below)
#
#  *SYNOPSIS*
#     ./twic_script.sh --help
#     ./twic_script.sh [<start_issue> [<end_issue> [<pgnfile>]]]
#  
#  When called with "--help" as first argument, the script outputs
#  a *minimal* help.
#
#  Otherwise, if called with a start_issue (an integer, default to the 
#  first issue to be downloaded, as specified into ${IDFILE}, or to 
#  the first known online issue of TWIC, number 210, if ${IDFILE} does
#  not exist), it will start downloading the TWIC issues from start_issue
#  up to the latest (or up to end_issue, if provided). The zips are stored 
#  into ${ZIPDIR} (default to "./zips"), while the png database is 
#  maintained into ${PNGFILE} (default to ${DBDIR}/twic.png), or into the 
#  file provided by the user as third argument. 
#
#  The new pgn files are concatenated at the end of ${PNGFILE}, and then the
#  SCID database is rebuilt (this can take a while...).
#
#  The script maintains a record of the last downloaded issue, into the
#  file ${IDFILE} (default to ${ZIPDIR}/.last_id), so that it is sufficient
#  to call it regularly (e.g., as a user cron job) with no arguments in order
#  to have an updated DB of chess games. 
#
#  *DEPENDENCIES*
#  
#  twic_script.sh depends on:
#  
#  - wget (to download the zip files)
#  - unzip (well, what do you think we are using it for?)
#  - pgnscid (a program provided by scid to convert a pgn file into a SCID
#             .si4 game DB)
#
#  **** IMPORTANT NOTE ****
# 
#  BEWARE!!! IF YOU REMOVE ${PNGFILE}, THE CORRESPONDING SCID DB FILE WILL 
#  BE OVERWRITTEN BY THE FIRST RUN OF THIS SCRIPT!!!
#


ZIPDIR="./zips"
DBDIR="./db"
IDFILE="${ZIPDIR}/.last_id"
### ADDR="http://www.chesscenter.com/twic/zips/"
ADDR="http://www.theweekinchess.com/zips/"
WOPTS=""
PGNFILE="${DBDIR}/twic.pgn"


if [ ! -d $ZIPDIR ]; then 
	echo "Creating folder \"${ZIPDIR}/\""
	mkdir ${ZIPDIR}
fi

if [ ! -d $DBDIR ]; then 
	echo "Creating folder \"${DBDIR}/\""
	mkdir ${DBDIR}
fi

## the first known issue of TWIC
i=210
## a very high number which will not be reached
last_i=$((9999))

if [ $# == 0 ]; then

    if [ -f ${IDFILE} ]; then
	LAST_ID=`cat ${IDFILE}`
    else
    	LAST_ID=`cd ${ZIPDIR}; ls * | sort | tail -1`
    	LAST_ID=`basename ${LAST_ID} .zip`
    fi
    if [ ${LAST_ID} ]; then 
        echo "Last id: ${LAST_ID}"
        i=$((${LAST_ID} + 1))

    fi
else

    if [ $1 == "--help" ]; then
        echo "Usage: $0 [<start_issue> [<end_issue> [ <pgnfile>] ] ]"
        exit 1
    elif [ $# -ge 2 ]; then
        last_i=$(($2))
  
    fi
    i=$1
fi


if [ $# == 3 ]; then 
    PGNFILE=$3
fi

echo -e "Downloading issues \033[31m$i \033[0mto \033[31m${last_i}\033[0m"
echo "Starting download from issue $i..."

DOWNLOADED=""
CONT="true"
while $CONT -eq "true"; do
    echo -ne "\033[33m downloading TWIC issue \033[31m$i\033[33m...."
    dest_name="twic${i}.zip"
    `wget -q $WOPTS $ADDR/twic${i}g.zip -O - > ${ZIPDIR}/twic${i}.zip`
    SIZE=`stat -c "%s" ${ZIPDIR}/${dest_name}`
    if [ ${SIZE} != "0" ]; then
        CONT="true"
        echo -e "\033[32m done!"
        DOWNLOADED="${DOWNLOADED} ${dest_name}"
        i=$(($i+ 1))
    else
        echo -e "\033[31m failed!"
        rm ${ZIPDIR}/${dest_name}
	#if [ -f ${IDFILE} ]; then
		echo $(($i -1)) > ${IDFILE}
	#fi
        CONT="false"
    fi
    if [ $i -gt ${last_i} ]; then
        CONT="false"
    fi
done

echo 
echo -e "\033[33m ---------------------------------"
echo 

echo -en "\033[31m Updating PGN file \033[32m$PGNFILE\033[31m...."
for fname in ${DOWNLOADED}; do 
    
    unzip -c $ZIPDIR/${fname} >> ${PGNFILE}
    
done

echo -e "\033[32m done! \033[0m"

echo 
echo -e "\033[33m ---------------------------------"
echo 

echo -e "\033[31m Rebuilding SCID DB....\033[33m"

pgnscid -f ${PGNFILE}

echo 
echo -e "\033[32m done! \033[0m"
echo 
echo -e "\033[33m --------------------------------- \033[0m"
echo 
