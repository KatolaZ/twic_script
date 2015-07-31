# twic_script
A bash script to maintain an update SCID database of chess games downloaded from The Week In Chess (TWIC) 

==============================

  This simple bash script helps maintaining an updated database of
  chess games for SCID, based on the famous "The Week In Chess" game
  collection made available at
   
  http://www.theweekinchess.com/
 
  Games are distributed as zipped png files, which are uploaded weekly
  on http://www.theweekinchess.com/zips/ (Should that URL change at some 
  point in the future, you will just need to update the ADDR variable 
  below)

  *SYNOPSIS*

     ./twic_script.sh --help

     ./twic_script.sh [<start_issue> [<end_issue> [<pgnfile>]]]
  
  When called with "--help" as first argument, the script outputs
  a *minimal* help.

  Otherwise, if called with a start_issue (an integer, default to the 
  first issue to be downloaded, as specified into ${IDFILE}, or to 
  the first known online issue of TWIC, number 210, if ${IDFILE} does
  not exist), it will start downloading the TWIC issues from start_issue
  up to the latest (or up to end_issue, if provided). The zips are stored 
  into ${ZIPDIR} (default to "./zips"), while the png database is 
  maintained into ${PNGFILE} (default to ${DBDIR}/twic.png), or into the 
  file provided by the user as third argument. 

  The new pgn files are concatenated at the end of ${PNGFILE}, and then the
  SCID database is rebuilt (this can take a while...).

  The script maintains a record of the last downloaded issue, into the
  file ${IDFILE} (default to ${ZIPDIR}/.last_id), so that it is sufficient
  to call it regularly (e.g., as a user cron job) with no arguments in order
  to have an updated DB of chess games. 

  *DEPENDENCIES*
  
  twic_script.sh depends on:
  
  - wget (to download the zip files)
  - unzip (well, what do you think we are using it for?)
  - pgnscid (a program provided by scid to convert a pgn file into a SCID
             .si4 game DB)

  **** IMPORTANT NOTE ****
 
  BEWARE!!! IF YOU REMOVE ${PNGFILE}, THE CORRESPONDING SCID DB FILE WILL 
  BE OVERWRITTEN BY THE FIRST RUN OF THIS SCRIPT!!!

