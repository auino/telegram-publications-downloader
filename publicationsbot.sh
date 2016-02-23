#!/bin/bash

# 
# telegram-publications-downloader
# Author: Enrico Cambiaso
# Email: enrico.cambiaso[at]gmail.com
# GitHub project URL: https://github.com/auino/telegram-publications-downloader
# 

# --- --- --- --- ---
# CONFIGURATION BEGIN
# --- --- --- --- ---

# Your Telegram bot token
TOKEN='...'

# Should this bot reply to anyone?
OPENBOT=1

# If closed bot, what chat identifiers are used for filtering?
ALLOWED_CHATIDS=("")

# --- --- --- --- ---
#  CONFIGURATION END 
# --- --- --- --- ---

URL='https://api.telegram.org/bot'$TOKEN

FORWARD_URL=$URL'/forwardMessage'

MSG_URL=$URL'/sendMessage'
DOCUMENT_URL=$URL'/sendDocument'
ACTION_URL=$URL'/sendChatAction'

FILE_URL='https://api.telegram.org/file/bot'$TOKEN'/'
UPD_URL=$URL'/getUpdates?offset='
GET_URL=$URL'/getFile'
OFFSET=0
declare -A USER MESSAGE URLS CONTACT LOCATION

send_message() {
	local chat="$1"
	local text="$(echo "$2" | sed 's/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g')"
	local file="$(echo "$2" | sed '/myfilelocationstartshere /!d;s/.*myfilelocationstartshere //g;s/ mykeyboardstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g')"
	if [ "$file" != "" ]; then
		send_file "$chat" "$file"
		local sent=y
	fi
	if [ "$sent" != "y" ];then
		res=$(curl -s "$MSG_URL" -F "chat_id=$chat" -F "text=$text")
	fi
}

send_file() {
	[ "$2" = "" ] && return
	local chat_id=$1
	local file=$2
	local ext="${file##*.}"

	CUR_URL=$DOCUMENT_URL
	WHAT=document
	STATUS=upload_document

	send_action $chat_id $STATUS
	res=$(curl -s "$CUR_URL" -F "chat_id=$chat_id" -F "$WHAT=@$file" -F "caption=$3")
}

# typing for text messages, upload_photo for photos, record_video or upload_video for videos, record_audio or upload_audio for audio files, upload_document for general files, find_location for location

send_action() {
	[ "$2" = "" ] && return
	res=$(curl -s "$ACTION_URL" -F "chat_id=$1" -F "action=$2")
}

# download functions call format: downloadpdf_* $STARTINGURL $CHATID

downloadpdf_sciencedirect() {
	U=`curl -s -c /tmp/cookie_$2.txt -A "Mozilla/5 (Windows) Gecko" "$1"|grep '<a '|grep -o 'href=['"'"'"][^"'"'"']*['"'"'"]' |sed -e 's/^<a href=["'"'"']//' -e 's/["'"'"']$//'|awk -F'"' '{print $2}'|grep -e ^http|grep pdf|head -n 1`
	echo "Downloading PDF from $U"
	rm file_$2.pdf 2> /dev/null
	curl -s -b /tmp/cookie_$2.txt -A "Mozilla/5 (Windows) Gecko" -L "$U" -o /tmp/file_$2.pdf
}

downloadpdf_ieee() {
	USERAGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4"
	echo "IEEE: $1"
	N=`echo "$1"|awk -F'arnumber=' '{print $2}'|awk -F'&' '{print $1}'`
	U="http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=$N"
	echo "Downloading PDF from web page $U"
	U2=`curl -s -b /tmp/cookie_$2.txt -a /tmp/cookie_$2.txt -A "$USERAGENT" -L "$U" -e "$U" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"|grep "<frame"|grep pdf|awk -F'src=' '{print $2}'|awk -F'"' '{print $2}'`
	echo "Downloading PDF from $U2"
	rm file_$2.pdf 2> /dev/null
	curl -s -b /tmp/cookie_$2.txt -A "$USERAGENT" -e "$U" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" -L "$U2" -o /tmp/file_$2.pdf
	echo "Downloaded $U2"
}

process_client() {
	# User
	USER[FIRST_NAME]=$(echo "$res" | egrep '\["result",0,"message","chat","first_name"\]' | cut -f 2 | cut -d '"' -f 2)
	USER[LAST_NAME]=$(echo "$res" | egrep '\["result",0,"message","chat","last_name"\]' | cut -f 2 | cut -d '"' -f 2)
	USER[USERNAME]=$(echo "$res" | egrep '\["result",0,"message","chat","username"\]' | cut -f 2 | cut -d '"' -f 2)

	[ "${URLS[*]}" != "" ] && {
		curl -s ${URLS[*]} -o $NAME
		send_file "${USER[ID]}" "$NAME" "$CAPTION"
		rm "$NAME"
	}
	[ "${LOCATION[*]}" != "" ] && send_location "${USER[ID]}" "${LOCATION[LATITUDE]}" "${LOCATION[LONGITUDE]}"
	case $MESSAGE in
		'/help')
			send_message "${USER[ID]}" "This is bashbot, the Telegram bot written entirely in bash."
			;;
		'/start')
			send_message "${USER[ID]}" "Hi..."
			;;
		'')
			;;
		*)
			CMD=`echo $MESSAGE|awk '{print $1}'`
			case $CMD in
				'/download')
					U=`echo $MESSAGE|awk '{print $2}'`
					CHATID="${USER[ID]}"
					echo "$MESSAGE $CHATID"
					if [ "$OPENBOT" == "1" ] || [[ " ${ALLOWED_CHATIDS[@]} " =~ "${CHATID}" ]]; then
						echo "Downloading from web page $U"
						DOMAIN=`echo $U|awk -F/ '{print $3}'`
						SUPPORTED=0
						if [[ $DOMAIN == *"sciencedirect.com"* ]]; then
							SUPPORTED=1
							downloadpdf_sciencedirect "$U" "$CHATID"
						fi
						if [[ $DOMAIN == *"ieee.org"* ]]; then
							SUPPORTED=1
							downloadpdf_ieee "$U" "$CHATID"
						fi
						if [ $SUPPORTED -gt 0 ]; then
							send_file "$CHATID" "/tmp/file_$CHATID.pdf" "$U"
						else
							send_message "$CHATID" "Service not supported"
						fi
						rm /tmp/cookie_$CHATID.txt 2> /dev/null
						rm /tmp/file_$CHATID.pdf 2> /dev/null
					fi
					;;
				*)
					send_message "${USER[ID]}" "$MESSAGE"
					;;
			esac
	esac
}

while true; do {
	res=$(curl -s $UPD_URL$OFFSET | ./JSON.sh -s)
	# Target
	USER[ID]=$(echo "$res" | egrep '\["result",0,"message","chat","id"\]' | cut -f 2)
	# Offset
	OFFSET=$(echo "$res" | egrep '\["result",0,"update_id"\]' | cut -f 2)
	# Message
	MESSAGE=$(echo "$res" | egrep '\["result",0,"message","text"\]' | cut -f 2 | cut -d '"' -f 2)

	OFFSET=$((OFFSET+1))
	if [ $OFFSET != 1 ]; then
		process_client&
	fi
}; done

