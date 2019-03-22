#!/bin/sh
##
## Automated Minecraft Bedrock Server Updater for Linux
## Created by Phosix, Feb 5, 2019
## Updated by Phosix, March 22, 2019
## https://www.reddit.com/r/MCPE/comments/b38wcn/automatically_update_bedrock_dedicated_server_for/
##

# Variables to be set as per end user preferences
# The directory holding your Bedrock server files
SERVER=${HOME}/server

# The directory where you want the server software downloaded to
DOWNLOAD=${HOME}/Downloads

# The Minecraft Bedrock Server download page
# If Minecraft.net ever goes away or changes, this will need to be changed to
# the current distribution location.
BASE_URL='https://minecraft.net/en-us/download/server/bedrock/'

################################################################################
################################################################################
## BEGIN CODE - DO NOT MODIFY UNLESS YOU KNOW WHAT YOU ARE DOING              ##
################################################################################
################################################################################

URL=`curl -L ${BASE_URL} 2>/dev/null| grep bin-linux | sed -e 's/.*<a href=\"\(https:.*\/bin-linux\/.*\.zip\).*/\1/'`

# Verify if the DOWNLOAD and SERVER destinations exist. Create if it doesn't
for check in "$DOWNLOAD" "$SERVER" ; do
  if [ ! -d ${check} ] ; then
    if [ -e ${check} ] ; then
      # Error out if it does exist but isn't a directory
      printf "\n%s is not a directory!\nPlease edit %s and change the line to point %s to the correct directory\n\n" "${check}" "$0" "${check}"
      exit 1
    fi
    mkdir -p ${$check}
  fi
done

# Check for a backup copy of any existing server properties.
# Make a backup copy if none exists.
if [ ! -e ${SERVER}/server.properties.bak ] ; then
  cp ${SERVER}/server.properties ${SERVER}/server.properties.bak
fi

# Check if a copy of the latest server exists in the DOWNLOAD directory
if [ ! -e ${DOWNLOAD}/${URL##*/} ] ; then
  # If it doesn't exist, retrieve the latest zip file and extract it to
  # the SERVER directory.
  curl ${URL} --output ${DOWNLOAD}/${URL##*/}
  cd ${SERVER}
  unzip -o ${DOWNLOAD}/${URL##*/} 2>&1 > /dev/null
  # Copy the server properties backup into place
  cp ${SERVER}/server.properties.bak ${SERVER}/server.properties
  # Remove older copies of the server
  find ${DOWNLOAD} -maxdepth 1 -type f -name bedrock-server\*.zip ! -newer ${DOWNLOAD}/${URL##*/} ! -name ${URL##*/} -delete

# If it does, do nothing. Either the software was downloaded manually and
# setup should be finished manually or it has already been updated.
else
  printf "\nServer is up to date, nothing to do.\n\n"
fi

exit 0
