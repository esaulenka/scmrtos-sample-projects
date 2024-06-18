#---------------------------------------------------t----------------------------
#
#    Build System Simulation support
#
#    Author: Harry E. Zhurov
#
#-------------------------------------------------------------------------------

import os
from pathlib import Path
from utils   import *

#-------------------------------------------------------------------------------
def compile_tb_pkg(target, source, env):
    trg     = target[0]
    trg_dir = str(trg.dir)

    worklib  = ' -work tb_pkg'
    uvm_lib  = ' -L ' + env['UVM_PATH']
    sv_seed  = ' +define+SV_SEED={}'.format(env['SV_SEED'])
    incdir   = ' +incdir+{}+{}'.format(env['BUILD_SRC_PATH'], os.path.join(env['SRC_SIM'], 'lib', 'tb'))
    pkg_src  = ' ' + os.path.join(env['SRC_SIM'], 'lib', 'tb', 'tb_lib.sv')
    defines  =  ' +define+' + '+'.join(env['PRJ_MACRODEFS'])

    defines += '' if not 'VLOG_DEFINES' in env.Dictionary() else env['VLOG_DEFINES']

    cmd = env['VLOGCOM'] + worklib + uvm_lib + sv_seed + incdir + defines + pkg_src
    print(cmd)

    msg = colorize('Compile testbench package', 'yellow')
    print(colorize('-'*80, 'yellow'))
    print(' '*20, msg, os.linesep)

    rcode = pexec(cmd, trg_dir)
    print(colorize('-'*80, 'yellow'))

    if rcode:
        return rcode

    return None

#-------------------------------------------------------------------------------
def create_test_header(target, source, env):
    trg = target[0]
    test_name = env['TEST_NAME']

    search_path   = [Path(p) for p in env['SIM_INC_PATH']]
    test_filename = test_name + '.svh'
    test_header   = None
    for p in search_path:
        if p.joinpath(test_filename).is_file():
            test_header = str(p.joinpath(test_filename))
            break

    if not test_header:
        print_error('E: cannot find test source "' + test_filename + '" while create test header in search path list:')
        for p in search_path:
            print_error('    ' + str(p))
        Exit(-1)

    test_dir = test_header.split(test_name + '.svh')[0]
    text = '`include "' + test_header + '"\n'

    with open(os.path.join(env['BUILD_SIM_PATH'], 'test.svh'), 'w') as ofile:
        ofile.write(text)

    return None

#-------------------------------------------------------------------------------
#     Show sv_seed value
def show_sv_seed(target, source, env):
    print("\033[33;40m=======================\033[0m")
    print("\033[33;40m  SV_SEED: {}\033[0m".format(env['SV_SEED']))
    print("\033[33;40m=======================\033[0m")
