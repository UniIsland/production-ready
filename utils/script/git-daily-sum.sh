function git-daily-sum {
	NEXT=$(date +%F)
	expr match "$1" '^[0-9]\+$' > /dev/null && len="$1" || len="7"
	echo "CHANGELOG"
	echo ----------------------
	git log --all --no-merges --format="%cd" --date=short | sort -u -r | head -n $len | while read DATE ; do
		[ $DATE == $NEXT ] && continue
		echo
		echo "[$DATE] - [$NEXT]"
		GIT_PAGER=cat git log --all --no-merges --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --since=$DATE --until=$NEXT
		NEXT=$DATE
		echo
	done
}

