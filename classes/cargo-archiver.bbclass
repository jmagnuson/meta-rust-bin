inherit ${@bb.utils.contains('INHERIT', 'archiver', 'archiver', '', d)}
#inherit archiver

do_deploy_cargo_archives() {
    export SSH_AUTH_SOCK=${SSH_AUTH_SOCK}
    export SSH_AGENT_PID=${SSH_AGENT_PID}
    CARGO_HOME="${ARCHIVER_OUTDIR}/cargo_home" cargo vendor -v --manifest-path ${CARGO_MANIFEST_PATH} ${ARCHIVER_OUTDIR}/vendor
    tar -czf ${ARCHIVER_OUTDIR}/${PF}-vendor.tar.gz ${ARCHIVER_OUTDIR}/vendor
    rm -rf ${ARCHIVER_OUTDIR}/vendor
    rm -rf ${ARCHIVER_OUTDIR}/cargo_home
}

python() {
    before = "do_deploy_archives"
    after = None

    #if bb.data.inherits_class('cargo', d) and bb.utils.contains('INHERIT', 'archiver', 'true', 'false', d):
    if bb.data.inherits_class('cargo', d):
        bb.build.addtask("do_deploy_cargo_archives", before, after, d)
}
