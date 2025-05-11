#!/bin/bash
set -e

# Build ALICE's patched strace.
pushd alice/alice-strace
./configure
make
popd

# Build seccomp BPF utility.
#
# This is necessary with modern glibc and kernel versions. It causes clone3 to
# fail with ENOSYS. The patched version of strace is too old to handle clone3
# syscalls, and glibc can fall back to using clone2.
pushd seccomp-filter
cargo build --release
popd

# Set up python2 virtualenv and dependencies for ALICE.
python -m virtualenv --python=python2 .venv
.venv/bin/pip install -r alice/requirements.txt
