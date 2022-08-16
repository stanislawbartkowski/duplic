#!/bin/bash

source `dirname $0`/common/commonproc.sh

source `dirname $0`/resource.rc

DUPLDIR=dupl
RESFILE=dupl.rc

printhelp() {
    echo "dupl.sh /what/"
    echo ""
    echo "/what/"
    for value in $LISTOFDEST; do
        echo "   $value"
    done
    exit 4
}


verify() {
    local -r WHAT=$1
    required_listofvars LISTOFUSERS LOGDIR LISTOFDEST DUPLICITY
    [ -z "$WHAT" ] && printhelp

    onthelist $WHAT "$LISTOFDEST"
    required_listofvars $LISTOFDEST

    # check list of users
    for user in $LISTOFUSERS; do checkuser $user; done
}

# ==============

rundupl() {
    local -r DUHOME=$1
    local -r DEST=$2
    local -r OUTLOG=$3
    local -r ISSUDO=$4
    FULL="--full-if-older-than $FULLC"
    export PASSPHRASE=$PASSPHRASE
    export FTP_PASSWORD=secret
    SUDO=
    if [ -n "$ISSUDO" ]; then
        SUDO="sudo --preserve-env=PASSPHRASE"
    fi
    log "dupl $DUHOME $DEST"
    log "$SUDO $DUPLICITY -v 5  $DUHOME $DINCLUDE  --exclude '**' $FULL --allow-source-mismatch $DEST"
    $SUDO $DUPLICITY -v 9  $DUHOME $DINCLUDE  --exclude '**' $FULL --allow-source-mismatch "$DEST" >>$OUTLOG
    local -r RES=$?
    [ $RES -ne 0 ] && logfail "Non zero exit code $RES"
    [ $RES -eq 0 ] && log "Success"
}

removeoldbackup(){
    local -r DEST=$1
    local -r OUT=$2
    local -r ISSUDO=$r3
    export PASSPHRASE=$PASSPHRASE
    export FTP_PASSWORD=secret
    if [ -n "$ISSUDO" ]; then
        SUDO="sudo --preserve-env=PASSPHRASE"
    fi
    log "Try to remove $DEST older than $REMOVEC"
    $SUDO $DUPLICITY remove-older-than $REMOVEC --force $DEST >>$OUT
    local -r RES=$?
    [ $RES -ne 0 ] && logfail "Non zero exit code $RES"
    [ $RES -eq 0 ] && log "Success"
}


dupluser() {
    local -r what=$1
    local -r user=$2
    local -r home=`eval echo ~$user`
    local -r dupldir=$home/$DUPLDIR
    log "$user $home $what"
    [ -d $dupldir ] || logfail "$dupldir does not exist"
    local -r rcfile=$dupldir/$RESFILE
    existfile $rcfile
    unset PASSPHRASE
    unset DINCLUDE
    source $rcfile
    required_listofvars PASSPHRASE DINCLUDE
    local -r dest="${!what}/dupl.$user"
    local -r out=$LOGDIR/$user-$what.out
    rundupl $home $dest $out 
    removeoldbackup $dest $out
}

run() {
    local -r what=$1
    verify $what
    log "=========================="
    log "`date`"
    log $DUPLICITY
    mkdir -p $LOGDIR
    for user in $LISTOFUSERS; do dupluser $what $user; done
}


definevars() {
    FULLC=${FULLC:-1M}
    REMOVEC=${REMOVEC:-3M}
}

definevars

run $1
