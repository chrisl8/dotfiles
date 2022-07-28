#!/bin/bash
# https://youtrack.jetbrains.com/issue/IDEA-276250/WSL2-The-Git-process-exited-with-the-code-1#focus=Comments-27-5739890.0-0

/usr/bin/git "$@"
STATUS=$?

if [[ $(find /run/WSL -printf "." | wc -c) -gt 20 ]]; then
	  for SOCKET in /run/WSL/*; do
		      if ! ss -elx | grep -q "$SOCKET"; then
			            rm "$SOCKET"
				        fi
					  done
fi

exit "$STATUS"
