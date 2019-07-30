#!/bin/sh
# This is a helper shell script that creates the necessary SSH "shortcuts" to
# make your life easier in ECE.
#
# To use, simply run this script and pass in your Andrew ID as the argument.
#
# If you already have a .ssh/config, then this script will prepend the config to
# your existing file. If you have defined the Hosts "cmu" and/or "ece", then
# this script will have the effect of overwriting that. Should this not be
# intended, then it probably would be best if you configured your .ssh/config
# yourself :-)

FILENAME=~/.ssh/config

# Check that Andrew ID is given
if [ "$#" -ne 1 ]; then
    echo "You must provide your Andrew ID." >&2
    echo "    Usage: $0 ANDREW_ID" >&2
    exit 1
fi

ANDREWID="$1"

# Pick a random number in [0, 31], inclusive
NUM=`shuf -i 0-31 -n 1`

# Choose an ECE server at random
ECENUM=`printf "%03d" $NUM`
HOST=`printf "ece%s.campus.ece.cmu.local" $ECENUM`
echo "Creating SSH shortcut for $HOST."

PXYCMD='ssh -W %%h:%%p cmu'

# Prepend SSH setup if config exists, otherwise create it
if [ -e "$FILENAME" ]; then
TO_PREPEND=`printf "Host cmu
Hostname unix.andrew.cmu.edu

Host ece
Hostname $HOST
ProxyCommand $PXYCMD

Host ece.campus
Hostname $HOST

Host cmu ece
ForwardX11 yes
ForwardX11Trusted yes
Compression yes
User $ANDREWID

%s" "$(cat $FILENAME)"`
else
TO_PREPEND=`printf "Host cmu
Hostname unix.andrew.cmu.edu

Host ece
Hostname $HOST
ProxyCommand $PXYCMD

Host ece.campus
Hostname $HOST

Host cmu ece
ForwardX11 yes
ForwardX11Trusted yes
Compression yes
User $ANDREWID

"`
fi

printf "%s" "$TO_PREPEND" > $FILENAME

echo "SSH setup complete."

echo ""
echo "You may now SSH into a Unix machine by running (without the $):"
echo "    $ ssh cmu"
echo "and you can SSH into an ECE machine with:"
echo "    $ ssh ece"
echo ""
echo "Note that when SSHing into ECE, you will have to type your password *twice*"
echo ""
echo "If you are connected to campus VPN, then you can ssh using:"
echo "    $ ssh ece.campus"
echo "You won't need to type your password twice with this one."
