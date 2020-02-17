#!/bin/sh

#VALID_TITLE=
#VALID_STATUS=Playing

#busctl -j --user monitor org.mpris.MediaPlayer2.vlc | while read -r LINE;do
#	MEMBER=$(echo $LINE | jq -re '.member')
#	if [ "$MEMBER" = 'NameLost' ]; then
#		rm /tmp/cur_music
#	elif [ ! -f /tmp/cur_music ]; then
#		echo "$VALID_TITLE ($VALID_STATUS)" | tee /tmp/cur_music
#	fi
#	TITLE=$(echo $LINE | jq -re '.payload.data[1].Metadata.data."xesam:title".data')
#	if [ $? -eq 0 ];then
#		VALID_TITLE=$TITLE
#		echo "$VALID_TITLE ($VALID_STATUS)" | tee /tmp/cur_music
#	fi
#	PS=$(echo $LINE | jq -re '.payload.data[1].PlaybackStatus.data')
#	if [ $? -eq 0 ];then
#		VALID_STATUS=$PS
#		echo "$VALID_TITLE ($VALID_STATUS)" | tee /tmp/cur_music
#	fi
#done

playerctl metadata -F --format '{{ title }} {{ emoji(status) }}' | while read -r LINE;do
	if [ -z "$LINE" ];then
		rm /tmp/cur_music
	else
		echo $LINE > /tmp/cur_music
	fi
done
