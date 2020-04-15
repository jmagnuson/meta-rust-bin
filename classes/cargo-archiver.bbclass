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
    #after = "do_populate_sysroot"
    after = "cargo-bin-cross-${TARGET_ARCH}:do_populate_sysroot"

    pn = d.getVar('PN')
    cpu = '${TARGET_ARCH}'

    #if bb.data.inherits_class('cargo', d) and bb.utils.contains('INHERIT', 'archiver', 'true', 'false', d):
    if bb.data.inherits_class('cargo', d):
        ar_src = d.getVarFlag('ARCHIVER_MODE', 'src')

        if ar_src == "original":
            after = "do_ar_original"
        elif ar_src == "patched":
            after = "do_ar_patched"
        elif ar_src == "configured":
            after = "do_ar_configured"

        bb.build.addtask("do_deploy_cargo_archives", before, after, d)
        d.appendVarFlag('do_deploy_archives', 'depends', ' %s:do_deploy_cargo_archives' % pn)
        d.appendVarFlag('do_deploy_cargo_archives', 'depends', ' cargo-bin-cross-%s:do_populate_sysroot' % cpu)
}
