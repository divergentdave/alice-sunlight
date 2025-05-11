#!/bin/bash
set -e
trap 'echo $0: error on line ${LINENO}' ERR

TOPSRCDIR="$(realpath "$(dirname "$0")")"
export ALICE_HOME="$TOPSRCDIR/alice"
PATH="$PATH:$TOPSRCDIR/alice/bin"
source "$TOPSRCDIR/.venv/bin/activate"

rm -rf checker_logs

# Build
(cd sunlight/cmd/verifier; go build .)

# Check possible execution traces with the verifier.
alice-check --traces_dir=traces_dir \
    --log_dir=checker_logs \
    --checker=./sunlight/cmd/verifier/verifier \
    --ignore_mmap=true

# We can ignore mmap()'d files because SQLite only uses the -shm file for
# synchronization and caching, and "The shm file does not contain any database
# content and is not required to recover the database following a crash."
