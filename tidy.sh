#!/bin/sh
#the script tells bash to use /dev/null instead of ~/.bash_history
#clears SSH_* vars otherwise any process we start gets a copy of our IP in /proc/self/environ
#commits suicide when exiting the shell

export HISTFILE=/dev/null
unset SSH_CONNECTION
unset SSH_CLIENT
alias exit='kill -9 $$'
rm -f tidy.sh
