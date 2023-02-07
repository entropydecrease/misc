#!/bin/bash

# aria2c -c 'https://tehlsvodhls02.vhallyun.com/vhallyun/vhallhls/ls/s_/27/lss_27f054bb/lss_27f054bb/20220724084900103860/livestream000015.ts'
#
[ -s record.m3u8 ] || aria2c -c 'https://tehlsvodhls02.vhallyun.com/vhallyun/vhallrecord/lss_27f054bb/20220724124221_a018e830/record.m3u8?token=2A75182F_MjE3MTIwOTg2XzYzRUI1N0Q2X1lUQXhPR1U0TXpBX2FtOXBibDgzTWpBeE9UUXdORElfdm9k'

# file names in .ts file is like '/vhallyun/vhallhls/ls/s_/27/lss_27f054bb/lss_27f054bb/20220724084900103860/livestream000015.ts'
# but the final url should be 'https://tehlsvodhls02.vhallyun.com/vhallyun/vhallhls/ls/s_/27/lss_27f054bb/lss_27f054bb/20220724084900103860/livestream000015.ts'
# so we need to add 'https://tehlsvodhls02.vhallyun.com' as prefix
Root=https://tehlsvodhls02.vhallyun.com


# calculate which file should be downloaded and make a url list
# -----------------------------------------------------------
[ -s url_list.txt ] || \
	grep -v '^#EXTM3U' record.m3u8 | grep -v '^#EXT-X' \
	| tr -d '\n' | sed 's/#EXTINF:/\n/g' | grep -v '^$' | sed 's/,/\t/' \
	| awk '{i+=$1; if (i >= 2000 && i <= 2050) print $2}' > url_list.txt

# download .ts files
# ------------------
cat url_list.txt | parallel -j 5 aria2c -c "${Root}"{}

# make file list for ffmpeg
# -------------------------
#
if [ ! -s ts.list ]
then
	for f in *.ts
	do
		echo "file	$f" >> ts.list
	done
fi

# merge 
# -----
#
ffmpeg -f concat -safe 0 -i ts.list -c copy output.mp4
