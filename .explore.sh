cd .sites
sites=`ls | fzf` && site=`cat $sites | fzf` && nohup rifle $site &
kill $KITTY_PID
