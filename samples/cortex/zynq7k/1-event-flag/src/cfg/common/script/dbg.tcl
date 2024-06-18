# connect
proc cn { } {
    connect -host localhost -port 3121
    targets -set -filter {name =~ "ARM* #0"}
}

# reload
proc rlbld { } {
    rst
    dow build/zed/sw/apu/bld/bld.elf
    con
}


proc rl { } {
    rst
    dow build/zed/sw/apu/bld/bld.elf
    bpadd load_img
    con
    while { [state] == "Running" } {

    }
    bpremove -all

    dow build/zed/sw/apu/cam/cam.elf

    con
}

