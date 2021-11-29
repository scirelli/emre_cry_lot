#!/usr/bin/env bash
set -e; set -u; set -o pipefail;
#set -x;

RECORD_COUNT="${1:-10}"
LIBBASE58='https://github.com/bitcoin/libbase58.git'
BASE58_INSTALL_DIR='/tmp/libbase58'

if [ `uname -s` != 'Darwin' ]; then echo 'Script requires MacOS'; exit 1; fi

if ! command -v base58 &> /dev/null
then
    brew list libgcrypt &> /dev/null || brew install libgcrypt
    brew list libtool &> /dev/null || brew install libtool
    if [ ! -d "$BASE58_INSTALL_DIR" ]; then
        git clone $LIBBASE58 "$BASE58_INSTALL_DIR"
    fi
    if [ ! -f "$BASE58_INSTALL_DIR/base58" ]; then
        pushd "$BASE58_INSTALL_DIR"
        # Generate the final build scripts
        ./autogen.sh
        # Build the CLI and library
        ./configure && make
        popd
    fi
    export PATH="$PATH:$BASE58_INSTALL_DIR"
fi

curl http://addresses.loyce.club/blockchair_bitcoin_addresses_and_balance_LATEST.tsv.gz \
    --request GET \
    --silent \
    --output - \
    | gunzip | cut -d $'\t' -f 1 | grep -f filter.txt | head -n $RECORD_COUNT \
    | base58
