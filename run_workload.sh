#!/bin/bash
set -e
trap 'echo $0: error on line ${LINENO}' ERR

TOPSRCDIR="$(realpath "$(dirname "$0")")"
PATH="$PATH:$TOPSRCDIR/alice/bin:$TOPSRCDIR/alice/alice-strace"
source "$TOPSRCDIR/.venv/bin/activate"

# The workload directory is where the files created and modified by the
# application will be stored. The application will modify the workload directory
# and its contents.
rm -rf workload_dir
mkdir workload_dir
cp -R initial_dir/* workload_dir/

# The traces directory is for storing the traces that are recorded as the
# application runs.
rm -rf traces_dir
mkdir traces_dir

# Build
(cd sunlight/cmd/workload; go build .)

# Run the workload and collect traces.
./seccomp-filter/target/release/seccomp-filter \
    alice-record \
    --workload_dir workload_dir \
    --traces_dir traces_dir \
    ./sunlight/cmd/workload/workload \
    "$@"
