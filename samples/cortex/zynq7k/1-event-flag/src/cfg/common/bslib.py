#---------------------------------------------------t----------------------------
#
#    Build System Library
#
#    Author: Harry E. Zhurov
#
#-------------------------------------------------------------------------------

import os
import time

from utils import *

#-------------------------------------------------------------------------------
def process_prjopt(optnames):

    options = {}
    
    #-----------------------------------------------------------
    #
    #    Retrieve optins from environment variables
    #
    for name in optnames:
        key = 'PREFIX_' + name + '_ENABLE'
        if key not in os.environ:
            print_error('\nError: project option "' + name + '" not specified\n')
            print_info('The follwing envrionment variables should be defined:')
            for i in optnames:
                print_info('    PREFIX_' + i + '_ENABLE')
            Exit(-4)

        val = os.environ[key].lower()

        pos = ['1', 'yes', 'true']
        neg = ['0', 'no',  'false']

        if val in pos:
            options[name] = '1'
        elif val in neg:
            options[name] = '0'
        else:
            print_error('\nError: project option "' + name + '" has invalid value: "' + val +'"')
            print_error('      Valid values are: ' + ', '.join(['"{}"'.format(i) for i in pos+neg]) )
            Exit(-4)

    #-----------------------------------------------------------
    #
    #    Process command-line options settings
    #
    opten  = []
    optdis = []

    if 'opten' in ARGUMENTS and ARGUMENTS['opten']:
        opten =  [i.strip().upper() for i in ARGUMENTS['opten'].split(',')]

    if 'opten' in ARGUMENTS and ARGUMENTS['optdis']:
        optdis = [i.strip().upper() for i in ARGUMENTS['optdis'].split(',')]

    if len(opten) and len(optdis) and not set(opten).isdisjoint(set(optdis)):
        com_items = list(set(opten) & set(optdis))
        print_error(os.linesep + 'Error: enable and disable options lists has common items: ' +
                     ', '.join(['"{}"'.format(i.strip()) for i in com_items])  + os.linesep)
        Exit(-4)

    opten  = [i for i in opten  if i]
    optdis = [i for i in optdis if i]
    for i in opten + optdis:
        if i not in options:
            print_error('\nError: command-line project option "' + i + '" has invalid name')
            print_error('      Valid names are: ' + ', '.join(['"{}"'.format(i) for i in options]) )
            Exit(-4)

    #-----------------------------------------------------------
    #
    #    Overlay command-line options above default
    #
    for i in opten:
        options[i] = '1'

    for i in optdis:
        options[i] = '0'

    opten  = [i for i in options if options[i] == '1']
    optdis = [i for i in options if options[i] == '0']

    #-----------------------------------------------------------
    #
    #    Display Project Option Summary
    #

    maxlen = max(len(opten), len(optdis))
    opten.extend(['']*(maxlen-len(opten)))
    optdis.extend(['']*(maxlen-len(optdis)))

    INDENT = 20
    print(colorize(' '*(INDENT-4) + 'Project Options for Current Build', 'yellow', True), os.linesep)
    from tabulate import tabulate as tab

    headers = [colorize('ENABLED', 'green', True), colorize('DISABLED', 'red', True)]
    opttab  = tab([(colorize(x, 'green', True), colorize(y, 'red', True)) for x, y in zip(opten, optdis)], headers,
                    tablefmt='fancy_grid')

    print(' '*INDENT + opttab.replace('\n', '\n'+' '*INDENT))

    return options

#-------------------------------------------------------------------------------
def create_prjopt_files(bld):
    opts     = bld.envx['PROJECT_OPTIONS']

    if not opts:
        bld.envx.Append( PRJ_MACRODEFS = [] )
        return

    bld.prjopten  = [x + '_ENABLE=' + opts[x] for x in opts]
    bld.prjoptuse = [x + '_OPTION_USE' for x in opts if opts[x] == '1']

    prjoptvlog = 'parameters :' + os.linesep
    prjopttcl  = 'set_property verilog_define { \\' + os.linesep

    max_pn_len = max_str_len([k + '_ENABLE' for k in opts.keys()])
    for i in opts:
        k = i + '_ENABLE'
        v = opts[i]
        value_len     = len(v)
        name_padding  = max_pn_len - len(k) + 2
        prjoptvlog   += ' '*4 + k + ' '*name_padding + ' : ' + v + os.linesep
        prjopttcl    += k + '=' + v + ' \\' + os.linesep

    prjoptvlog += os.linesep

    for k in bld.prjoptuse:
        prjopttcl  +=  k + ' \\' + os.linesep

    prjopttcl += '} [current_fileset]' + os.linesep

    prjoptvlog_path = os.path.join(bld.envx['BUILD_SRC_PATH'], 'prjopts.yml')
    prjopttcl_path  = os.path.join(bld.envx['BUILD_SRC_PATH'], 'prjopts.tcl')
    if not os.path.exists(bld.envx['BUILD_SRC_PATH']):
        Execute( Mkdir(bld.envx['BUILD_SRC_PATH']) )

    with open(prjoptvlog_path, 'w') as vlog_fh:
        vlog_fh.write(prjoptvlog)
        vlog_fh.flush()
        os.fsync(vlog_fh.fileno())

    with open(prjopttcl_path, 'w') as tcl_fh:
        tcl_fh.write(prjopttcl)
        tcl_fh.flush()
        os.fsync(tcl_fh.fileno())
        
    while(not os.path.exists(prjoptvlog_path)):
        pass

    bld.envx.Append( PRJ_MACRODEFS = bld.prjopten + bld.prjoptuse)

#-------------------------------------------------------------------------------
def process_arguments(bld):
    bld.no_colors = int(bld.envx['ARGUMENTS'].get('no_colors', 0))
    bld.sim_args  = str(bld.envx['ARGUMENTS'].get('sim_args', ''))

#-------------------------------------------------------------------------------
def set_sv_seed(bld):
    seed = bld.envx['ARGUMENTS'].get('sv_seed', '')

    sv_seed = seed if seed else str(int(time.time()))

    bld.envx['SV_SEED'] = sv_seed
    print(colorize(os.linesep + ' '*12 + '*'*40, 'green', True))
    print(colorize(' '*12 + '*' + ' '*10 + 'sv_seed: ' + sv_seed + ' '*9 + '*', 'green', True))
    print(colorize(' '*12 + '*'*40, 'green', True)+os.linesep)

#-------------------------------------------------------------------------------

