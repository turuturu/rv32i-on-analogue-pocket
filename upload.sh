#!/bin/sh
DRIVE_LETTER=f
CORE_NAME=turuturu.RV32I
DIST_DIR=dist/Cores/$CORE_NAME
TARGET_DIR=/mnt/$DRIVE_LETTER/Cores/$CORE_NAME
sudo mount -t drvfs $DRIVE_LETTER: /mnt/$DRIVE_LETTER/

if [ ! -d $TARGET_DIR ]; then
  mkdir $TARGET_DIR
fi
cp -v $DIST_DIR/* $TARGET_DIR/
sudo umount /mnt/$DRIVE_LETTER/
