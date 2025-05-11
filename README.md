# Overview

This repository provides a test harness to investigate the durability of the
Sunlight CT log's local filesystem backend. It uses the ALICE tool from [this
paper][paper], with modifications.

[paper]: https://www.usenix.org/conference/osdi14/technical-sessions/presentation/pillai 

This requires Go, Python 2, Rust, a C compiler, and the usual associated build
tools. Run the following commands to compile utilities and prepare
dependencies.

```bash
git clone --recursive https://github.com/divergentdave/alice-sunlight.git
cd alice-sunlight
./setup.sh
```

The test harness can be run by executing the following two commands.

```bash
./run_workload.sh
./run_checker.sh
```

# Initial directory state

For now, initial log creation is excluded from testing. The files in
`initial_dir/` were prepared as follows:

* Certificates and keys were generated with `mkcert`, stored in `pki/`, and
  certificates were copied over.
* The secret seed was initialized to 32 NUL bytes.
* The log's public key was derived from the secret seed using
  `sunlight-keygen`.
* The data directory was created.
* Separate configuration files were written for Sunlight and for the
  workload/verifier programs. The latter uses a simplified configuration
  format, with only one log, and some fields removed.
* The checkpoints database was created using `sqlite3`, and the table was
  created manually.
* Sunlight was run once to create the cache database, and to store the first
  checkpoint.
* Both databases were `VACUUM`'d using `sqlite3`, to clean up the `-shm` and
  `-wal` files, and to move data from the write-ahead log into the main file.
