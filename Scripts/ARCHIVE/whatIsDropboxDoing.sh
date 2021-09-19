dropbox status
ls -lhat /proc/`pgrep dropbox`/fd | egrep -v "\-> socket:" | egrep -v "\-> pipe:" | egrep -v "\-> anon_inode" | egrep -v "/dev/null" | egrep -v "\-> /dev/*" | grep -v '\/\.dropbox\/'

