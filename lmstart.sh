#!/usr/bin/env bash

readonly license="${1:-/license.dat}"

/usr/local/matlab/etc/lmstart -c ${license}
tail -f /var/tmp/lm_TMW.log
