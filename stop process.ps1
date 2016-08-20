$ProcessID = get-process | Select-Object Id, pm, processname | Sort-Object PM -Descending | select-object -first 1
stop-process -id $ProcessID.id -Force -Confirm

