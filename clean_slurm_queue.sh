sudo scancel `squeue | awk '{print $1}' | grep -v JOBID`
