# https://unix.stackexchange.com/a/308899
for f in $(find . -type l ); do echo -n $(realpath $f) && echo -n "|" && echo $f ; done | grep -v "^$(pwd)" | cut -d \| -f 2

