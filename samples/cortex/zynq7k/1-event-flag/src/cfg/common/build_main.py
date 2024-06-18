#-------------------------------------------------------------------------------
#
#    Basic construction script
#
#    Author: Harry E. Zhurov
#
#-------------------------------------------------------------------------------

import os
import sys
import time

from utils import *

from build_base import *
from build_sim  import *

class BuildMain(BuildBase):

    #---------------------------------------------------------------------------
    def __init__(self, **src_dict):

        super().__init__(**src_dict)

        #self.add_sdpe_riscv_target()
        self.add_target_aliases()
        self.extend_target_help()

    #---------------------------------------------------------------------------
    #
    #    Construction Environment
    #
    def setup_constr_env(self):

        super().setup_constr_env()
        
        self.testname                  = self.envx['ARGUMENTS'].get('test', 'main_int_test')
        self.envx['TEST_NAME']         = self.testname
        self.envx.Append( SIM_INC_PATH = os.path.join(self.dirs.SRC_SIM, 'lib', 'tb') )

        #----------------------------------------------------------------------
        #
        #    Tool flags
        #
        vlog_flags  = ' +define+DDR4_INIT_WITH_ZEROES'  # DDR4 memory initialization
        vlog_flags += ' +define+{}'.format(self.testname.upper())

        vopt_flags  = ''

        vsim_flags = ' +UVM_TESTNAME={}'.format(self.testname)

        #----------------------------------------------------------------------

        self.envx.Append(VLOG_FLAGS = vlog_flags)
        self.envx.Append(VOPT_FLAGS = vopt_flags)
        self.envx.Append(VSIM_FLAGS = vsim_flags)

    #---------------------------------------------------------------------------
    #
    #    Targets
    #
    def add_hdl_params_targets(self):

        super().add_hdl_params_targets()
        
        hdl_param_deps = 'main.yml clk.yml params.yml ila.yml'

        cfg_params_header   = os.path.join(self.envx['BUILD_SRC_PATH'], 'cfg_params.svh')

        self.CfgParamsHeader = self.envx.CreateCfgParamsHeader(cfg_params_header, hdl_param_deps)

        self.cfg_header_trgs = [self.CfgParamsHeader]

    #---------------------------------------------------------------------------
    def add_tcl_params_targets(self):

        super().add_tcl_params_targets()
        
        cfg_params_tcl      = os.path.join(self.envx['BUILD_SRC_PATH'], 'cfg_params.tcl')
        env_params_tcl      = os.path.join(self.envx['BUILD_SRC_PATH'], 'env_params.tcl')
        ila_params_tcl      = os.path.join(self.envx['BUILD_SRC_PATH'], 'ila_params.tcl')
        impl_env_tcl        = os.path.join(self.envx['BUILD_SRC_PATH'], 'impl_env.tcl')

        self.prj_impl_deps.append(impl_env_tcl)

        self.CfgParamsTcl   = self.envx.CreateCfgParamsTcl(cfg_params_tcl, 'params.yml main.yml')
        self.EnvParamsTcl   = self.envx.CreateCfgParamsTcl(env_params_tcl, 'env.yml dirpath.yml')
        self.IlaParamsTcl   = self.envx.CreateCfgParamsTcl(ila_params_tcl, 'ila.yml')
        self.ImplEnvTcl     = self.envx.CreateCfgParamsTcl(impl_env_tcl,   'main.yml clk.yml dirpath.yml ila.yml')

        self.cfg_tcl_trgs   = [self.CfgParamsTcl,
                               self.EnvParamsTcl,
                               self.IlaParamsTcl,
                               self.ImplEnvTcl]

    #---------------------------------------------------------------------------
#   def add_sdpe_riscv_target(self):
#
#       #   VPN SDPE CPU executable
#       riscv_cfg = import_config('riscv.yml')
#       self.envx['VPN_RISCV_CFG'] = riscv_cfg
#       envx = self.envx
#       self.vpn_sw = SConscript(os.path.join(self.dirs.COMMON, 'sw', 'sdpe_vpn', 'sw.scons'), exports = 'envx')

    #---------------------------------------------------------------------------
    def add_main_targets(self):
        super().add_main_targets()

        #self.envx.AddPreAction(self.WLib, create_test_header)
        #self.envx.AddPreAction(self.WLib, compile_tb_pkg)

    def add_phony_targets(self):
        super().add_phony_targets()
        self.envx.AddPostAction(self.LaunchQuestaRun, show_sv_seed)

    def setup_explicit_dependencies(self):
        super.add_explicit_dependencies()
#       Depends(self.WLib,               [self.vpn_sw])
        Depends(self.ImplVivadoProject,  self.prj_impl_deps)

    #---------------------------------------------------------------------------
    #
    #    Target Aliases
    #
    def add_target_aliases(self):

        self.envx.Alias('prjimpl', self.ImplVivadoProject)

    #---------------------------------------------------------------------------
    #
    #    Info
    #
    def extend_target_help(self):

        Help("""
            Main Build Scenario Additional Targets
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                prjimpl    : implement Vivado Project

        ********************************************************************************
        """)

#-------------------------------------------------------------------------------

