
import os

from pathlib  import Path

#-------------------------------------------------------------------------------
def setup_default_env(env):


    #-------------------------------------------------------------------------------
    #
    #      Toolkit
    #
    TOOLKIT_PATH = Path(os.environ['CAD']) / 'gcc' / 'arm-none-eabi' / '13'

    CPP      = TOOLKIT_PATH / 'bin' / 'arm-none-eabi-cpp'
    ASM      = TOOLKIT_PATH / 'bin' / 'arm-none-eabi-as'
    CC       = TOOLKIT_PATH / 'bin' / 'arm-none-eabi-gcc'
    CXX      = TOOLKIT_PATH / 'bin' / 'arm-none-eabi-g++'
    LINKER   = TOOLKIT_PATH / 'bin' / 'arm-none-eabi-gcc'
    OBJDUMP  = TOOLKIT_PATH / 'bin' / 'arm-none-eabi-objdump'
    LOADER   = TOOLKIT_PATH / 'bin' / 'arm-none-eabi-ldr'
    SIZE     = TOOLKIT_PATH / 'bin' / 'arm-none-eabi-size'

    env['CPP']     = str(CPP)
    env['AS']      = str(ASM)
    env['CC']      = str(CC)
    env['CXX']     = str(CXX)
    env['LINK']    = str(LINKER)
    env['OBJDUMP'] = str(OBJDUMP)

    #-------------------------------------------------------------------------------
    #
    #    The options
    #
    FLAGS = []
    FLAGS.append('-pipe')
    FLAGS.append('-ffunction-sections')
    FLAGS.append('-fdata-sections')
    #FLAGS.append('-DBUILD_DATE=\"' + BUILD_DATE + '\"')
    #FLAGS.append('-DBUILD_TIME=\"' + BUILD_TIME + '\"')
    #-----------------------------------------------------------
    GCCFLAGS = FLAGS.copy()
    #GCCFLAGS += ' -MD'
    GCCFLAGS.append('-DPRINTF_FLOAT')
    GCCFLAGS.append('-fomit-frame-pointer')
    GCCFLAGS.append('-ffast-math')

    GCC_W_FLAGS = []
    GCC_W_FLAGS.append('-Wall')
    GCC_W_FLAGS.append('-Wextra')
    GCC_W_FLAGS.append('-Wcast-align')
    GCC_W_FLAGS.append('-Wpointer-arith')
    GCC_W_FLAGS.append('-Wredundant-decls')
    GCC_W_FLAGS.append('-Wshadow')
    GCC_W_FLAGS.append('-Wcast-qual')
    GCC_W_FLAGS.append('-pedantic')
    #-----------------------------------------------------------
    CFLAGS = GCCFLAGS.copy()
    CFLAGS.append('-std=c99')
    CFLAGS.append('-Wimplicit')
    CFLAGS.append('-Wnested-externs')
    #-----------------------------------------------------------
    CXXFLAGS  = GCCFLAGS.copy()
    CXXFLAGS.append('-fno-exceptions')
    CXXFLAGS.append('-fno-rtti')
    CXXFLAGS.append('-std=gnu++17')
    CXXFLAGS.append('-funsigned-bitfields')
    CXXFLAGS.append('-fshort-enums')
    #-----------------------------------------------------------
    LFLAGS = FLAGS.copy()
    LFLAGS.append('-Wl,--gc-sections')
    LFLAGS.append('--specs=nano.specs')
    LFLAGS.append('--specs=nosys.specs')
    #LFLAGS.append(' -L '   + ObjDir + LibraryPathOptions)
    LFLAGS.append('-nostartfiles')
    #-------------------------------------------------------------------------------

    env.Append(ASFLAGS   = FLAGS    )
    env.Append(CFLAGS    = CFLAGS   )
    env.Append(CXXFLAGS  = CXXFLAGS )
    env.Append(LINKFLAGS = LFLAGS   )
    env.Append(LIBS      = ['m', 'stdc++'])

#-------------------------------------------------------------------------------

