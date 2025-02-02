MODPATH=${0%/*}

# info
echo "- Apps caches from this module will be re-cleaned"
echo "  at the next boot."
echo " "

# rename
FILE=$MODPATH/cleaner.sh
if [ -f $FILE.txt ]; then
  mv -f $FILE.txt $FILE
fi


