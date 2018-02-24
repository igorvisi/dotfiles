
# Getting notifieD WHEN LONG-RUNNING ZSH PROCESSES COMPLETE
# https://reddit.com/r/linux/comments/1pooe6/zsh_tip_notify_after_long_processes/
# THIS CAN BE DISTURBING !!!!
#   _CMD_START_DATE=$(date +%s) and_CMD_NAME=$1 must be defined on preexec function
long-command-done-notify(){
	if ! [[ -z $_CMD_START_DATE ]]; then
		_CMD_END_DATE=$(date +%s)
		_CMD_ELAPSED_TIME=$(($_CMD_END_DATE-$_CMD_START_DATE))
		_CMD_NOTIFY_THRESHOLD=60

		if [[ $_CMD_ELAPSED_TIME -gt $_CMD_NOTIFY_THRESHOLD ]]; then
			notify-send --icon=terminal "$_CMD_NAME done !" 
		fi
	fi
}
