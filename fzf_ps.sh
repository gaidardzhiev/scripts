#!/bin/sh

ps axo pid,args ww --no-headers | \
	fzf --height=50% --layout=reverse --multi \
	--with-nth=1,2 \
	--preview="ps -p {1} -o pid,ppid,user,group,uid,%cpu,%mem,vsz,rss,stat,pri,nice,etime,start,time,tty,args ww --no-headers | awk '{
		print \"PID: \" \$1 \"\nPPID: \" \$2 \"\nUser: \" \$3 \"\nGroup: \" \$4 \"\nUID: \" \$5;
		print \"CPU%: \" \$6 \"\nMEM%: \" \$7 \"\nVSZ: \" \$8 \"\nRSS: \" \$9;
		print \"State: \" \$10 \"\nPriority: \" \$11 \"\nNice: \" \$12 \"\nElapsed: \" \$13;
		print \"Started: \" \$14 \"\nCPU Time: \" \$15 \"\nTTY: \" \$16 \"\nCommand: \" substr(\$0, index(\$0,\$17))
	}'" \
	--preview-window='right:50%,wrap' \
	--bind "k:execute-silent(echo {1} | xargs -r kill -9)+reload(ps axo pid,args ww --no-headers)" \
	--bind "q:abort"
