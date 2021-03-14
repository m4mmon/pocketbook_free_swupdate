#!/bin/bash

file=$1
if [ ! -f "$file" ]
then
   echo "Usage: $0 <file>"
   exit 1
fi

# get tar archive offsets

tar_begin_offset=()

while read pos xxxxx
do
   tar_begin_offset+=("$pos")
done < <(strings -a -t d $file | grep "tmp/dragon")


# last index, we'll use it soon

last_index=$(( ${#tar_begin_offset[@]} - 1 ))

# for each found

for idx in "${!tar_begin_offset[@]}"
do
   # get offset

   curr_offset=${tar_begin_offset[$idx]}

   # build extraction command line

   cmdline="dd if=${file} of=${file}_part${idx}.tar bs=4096 iflag=skip_bytes,count_bytes skip=${curr_offset}"

   # if not last item

   if [ $idx -ne $last_index ]
   then
      # compute size

      next_idx=$(( $idx + 1 ))
      next_offset=${tar_begin_offset[$next_idx]}

      # by substracting current offset from next one

      count=$(( $next_offset - $curr_offset ))
      cmdline="$cmdline count=${count}"
   fi

   # extract portion of file

   $cmdline

done
