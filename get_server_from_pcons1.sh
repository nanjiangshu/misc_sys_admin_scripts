#!/bin/bash

#============================================================
# Script: get_server_from_pcons1.sh
# Purpose: Rsync selected directories from pcons1
#============================================================

# Lockfile
LOCKFILE="/tmp/.get_server_from_pcons1.sh.lock"

# Backup and log directories
BACKUP_DIR="/mnt/storage/data/nanjiang/backup/from_pcons1.scilifelab.se"
LOG_DIR="/mnt/storage/data/nanjiang/log"
LOGFILE="$LOG_DIR/get_server_from_pcons1.log"

# Create directories if they don't exist
mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

#============================================================
# Function to log messages with timestamp
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

#============================================================
# Locking: prevent multiple runs
if [ -f "$LOCKFILE" ]; then
    log "Lockfile exists ($LOCKFILE). Exiting."
    exit 1
fi

# Create lockfile
date > "$LOCKFILE"

# Ensure lockfile is removed on exit
trap 'rm -f "$LOCKFILE"' INT TERM EXIT

#============================================================
# Setup
RUNDIR="$(dirname "$0")"
cd "$RUNDIR" || { log "Failed to cd to $RUNDIR"; exit 1; }

# Target host
TARGETHOST="pcons1"

# Rsync options
BASE_OPTS="--exclude=~* --exclude=*~ --exclude=.*.sw[mopn]"
EXCLUDE_OPTS="/var/www/frag1d /var/www/predzinc /var/www/pcons/PCONSMETA /var/www/pcons/CASP* /var/www/pcons/casp /var/www/pcons/test /var/www/pcons/data /var/www/pcons/share /var/www/pcons/download /var/www/pcons/bin /var/www/pcons/misc /var/www/pcons/bak tmp/[0-9a-zA-Z]* result/[0-9a-zA-Z]* static/md5 docroot/md5 debug/md5 release/md5 plots output svmouput .dump_tmp *.gz stat archive cached_job_finished_date.sqlite3_*"
EXCLUDE_OPTS2="topcons/uniref90_2014_5.fasta topcons/uniref90.mem.fasta* download/prodres_db download/pconsc2-vm.zip release/.dump_tmp tmbmodel-seq/BLAST/nr.*"

RSYNC_SSH="ssh -i ~/.ssh/id_rsa_backup -o StrictHostKeyChecking=no"

#============================================================
# Function to run rsync with logging
run_rsync() {
    local SRC="$1"
    local DEST_SUBDIR="$2"
    local INCLUDE="$3"

    # Full destination path
    local DEST="$BACKUP_DIR/$DEST_SUBDIR"
    mkdir -p "$DEST"

    local CMD="rsync -auvz -e \"$RSYNC_SSH\" $BASE_OPTS"

    for ex in $EXCLUDE_OPTS; do
        CMD+=" --exclude=\"$ex\""
    done
    for ex2 in $EXCLUDE_OPTS2; do
        CMD+=" --exclude=\"$ex2\""
    done

    # Include pattern if provided
    [ -n "$INCLUDE" ] && CMD+=" --include=\"$INCLUDE\" --exclude=\"**\""

    CMD+=" ${TARGETHOST}:$SRC $DEST"

    log "Running: $CMD"
    eval "$CMD" >> "$LOGFILE" 2>&1
    if [ $? -eq 0 ]; then
        log "Rsync from $SRC to $DEST finished successfully."
    else
        log "Rsync from $SRC to $DEST FAILED!"
    fi
}

#============================================================
# Run rsync for each directory
run_rsync "/server/" "server"
run_rsync "/etc/httpd/" "httpd"
run_rsync "/var/www/" "var/www"
run_rsync "/big/src/" "big/src" "*.sh"

#============================================================
# Cleanup
rm -f "$LOCKFILE"
log "Script finished."
