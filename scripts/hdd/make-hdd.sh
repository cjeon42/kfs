#! /bin/bash

set -e

SYSROOT=$2
HDD=$1
HDD_SIZE_MB=512

SECTOR_SIZE=512
SECTOR_END=$(( $HDD_SIZE_MB * 1024 * 1024 / $SECTOR_SIZE ))

PART2_START=$(( $SECTOR_END / 3 ))
PART2_END=$(( $SECTOR_END - 1 ))

PART1_START=2048
PART1_END=$(( $PART2_START - 1 ))

truncate -s $HDD_SIZE_MB"MiB" $HDD

guestfish -a $HDD << EOF
run
part-init /dev/sda mbr
part-add /dev/sda p $PART1_START $PART1_END
part-add /dev/sda p $PART2_START $PART2_END
mkfs ext2 /dev/sda1 blocksize:1024
mkfs ext2 /dev/sda2
mount /dev/sda1 /
copy-in $SYSROOT /
glob mv /sysroot/* /
rmdir /sysroot
EOF
