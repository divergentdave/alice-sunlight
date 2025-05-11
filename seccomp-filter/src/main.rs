//! This program uses a seccomp BPF to return an ENOSYS error when the clone3 syscall is used.
//! The patched version of strace does not support this syscall. If glibc gets ENOSYS when calling
//! clone3, it falls back to clone2, which is supported by this version of strace.

use std::{
    collections::BTreeMap, env::consts::ARCH, os::unix::process::CommandExt, process::Command,
};

use libc::{SYS_clone3, ENOSYS};
use seccompiler::{BpfProgram, SeccompAction, SeccompFilter};

fn main() {
    let filter = SeccompFilter::new(
        BTreeMap::from([(SYS_clone3, vec![])]),
        SeccompAction::Allow,
        SeccompAction::Errno(ENOSYS.try_into().unwrap()),
        ARCH.try_into().unwrap(),
    )
    .unwrap();
    let program = BpfProgram::try_from(filter).unwrap();
    seccompiler::apply_filter_all_threads(&program).unwrap();

    let mut args = std::env::args_os().skip(1);
    let program = args.next().unwrap();
    let program_args = args.collect::<Vec<_>>();
    let error = Command::new(program).args(program_args).exec();
    panic!("exec failed: {error}");
}
