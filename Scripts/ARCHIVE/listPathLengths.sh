# Windows hates lot path names, so use this to list files from "here down" with their path length
find -type f | awk '{ printf "%d %s\n", length ($0), $0  }'|sort -n

