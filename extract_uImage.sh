#!/bin/sh

#Based on https://github.com/mb2020/qnap-utils/blob/master/extract_qnap_fw.sh

if [ $# -lt 1 ]; then
  echo "usage $0 path_to_extraced_uImage"
  exit
fi

#Path to uImage from the extracted QNAP OS img file
UIMAGE="$1"

if [ ! -f $UIMAGE ]; then
  echo "$UIMAGE does not exist"
  exit
fi

INITRAMFS="initramfs_qnap.cpio.gz"
IMAGE="uncompressed_uImage"

echo "converting and searching in $UIMAGE"
a=`od -t x1 -w4 -Ad -v $UIMAGE | grep '1f 8b 08 00' | awk '{print $1}'`
if [ ! -z "$a" ]; then
  echo "extracting '$UIMAGE'"
  dd if=$UIMAGE bs=1 skip=$a of=$IMAGE.gz status=none
  gunzip --quiet $IMAGE.gz || [ $? -eq 2 ]
  echo "- extracted and uncompressed $UIMAGE at offset $a to $IMAGE.gz"

  echo 'extracting initramfs'
  i=0
  for a in `od -t x1 -w4 -Ad -v $IMAGE | grep '1f 8b 08 00' | awk '{print $1}'`; do
    i=$((i+1))
    dd if=$IMAGE bs=1 skip=$a of=$IMAGE.part$i.gz status=none
    gunzip --quiet $IMAGE.part$i.gz || [ $? -eq 2 ] 
    echo "- extracted and uncompressed '$IMAGE.part$i' at offset $a"
  done

  if [ $i -gt 0 ]; then
    mv $IMAGE.part$i $INITRAMFS
    echo "- renamed '$IMAGE.part$i' to '$INITRAMFS'"
    i=$((i-1))
  fi

  echo "cleaning up"
  echo "- deleting $IMAGE"
  rm $IMAGE
  for n in $(seq 1 $i); do
    FILE=$IMAGE.part$n
    echo "- deleting $FILE"
    rm $FILE
  done
fi
