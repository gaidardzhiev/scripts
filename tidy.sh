#!/bin/sh -li
#the script tells bash to use /dev/null instead of ~/.bash_history
#clears SSH_* vars otherwise any process we start gets a copy of our IP in /proc/self/environ
#commits suicide when exiting the shell

set -o xtrace
export HISTFILE=/dev/null
unset SSH_CONNECTION
unset SSH_CLIENT
function commit_suicide {
cat > ~/.bashrc << EOF
alias exit='kill -9 $$'
EOF
rm $0
}
commit_suicide
