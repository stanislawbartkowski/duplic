source `dirname $0`/resource.rc

LOGFILE=$LOGDIR/myduplicity.log
DUPLDIR=dupl
RESFILE=dupl.rc

# ===============================================

log() {
    local -r mess="$1"
    echo "$mess" >>$LOGFILE
    echo "$mess"
}

logfail() {
    local -r mess="$1"
    log "$mess"
    log "FAILURE - cannot continue"
    exit 4
}

required_var() {
    local -r VARIABLE=$1
    [ -z "${!VARIABLE}" ] && logfail "Need to set environment variable: $VARIABLE"    
}

required_listofvars() {
    while true; do
        var=$1
        [ -z "$var" ] && break
        required_var $var
        shift
    done
}

onthelist() {
    local -r word=$1
    local -r list=$2
    for w in ${list//,/ }; do
        [ $w == $word ] &&  return
    done
    logfail "$word is not on the list:  $list"
}

printhelp() {
    echo "dupl.sh /what/"
    echo ""
    echo "/what/"
    for value in $LISTOFDEST; do
        echo "   $value"
    done
    exit 4
}


checkuser() {
    local -r user=$1
    if ! id $user >/dev/null; then logfail "$user does not exist"; fi    
}

existfile() {
    local -r FILENAME=$1
    [ -f $FILENAME ] || logfail "$FILENAME does not exist"
}

verify() {
    local -r WHAT=$1
    required_listofvars LISTOFUSERS LOGDIR LISTOFDEST
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
    FULL="--full-if-older-than 1M"
    export PASSPHRASE=$PASSPHRASE 
    SUDO=
    if [ -n "$ISSUDO" ]; then
        SUDO="sudo --preserve-env=PASSPHRASE"
    fi
    log "dupl $DUHOME $DEST"
    $SUDO duplicity -v 5  $DUHOME $DINCLUDE  --exclude '**' $FULL --allow-source-mismatch "$DEST" >>$OUTLOG
}

removeoldbackup(){
    local -r DEST=$1
    local -r OUT=$2
    local -r ISSUDO=$r3
    export PASSPHRASE=$PASSPHRASE 
    if [ -n "$ISSUDO" ]; then
        SUDO="sudo --preserve-env=PASSPHRASE"
    fi
    log "Try to remove $DEST"
    $SUDO duplicity remove-older-than 2M --force $DEST >>$OUT
}


dupluser() {
    local -r what=$1
    local -r user=$2
    local -r home=`eval echo ~$user`
    local -r dupldir=$home/$DUPLDIR
    log "$yser $home $what"
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
    mkdir -p $LOGDIR
    for user in $LISTOFUSERS; do dupluser $what $user; done
}

run $1
