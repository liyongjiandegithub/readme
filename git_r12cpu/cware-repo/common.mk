#-------------------------------------------------------------------------
# common.mk
#
# Common make defines and rules to build C-Ware
#
# Copyright (c) 1999-2003 LSI Logic Corporation
# Copyright (c) 2009 Magnum Semiconductor
# All rights reserved.
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Build control variables
#
# These variables control the build process in various ways
#
# debug - When set to non=null, will set the CW_DEBUG define and will
#         compile with -g
#
# dbgmod - When set to a string with one or more space-seperated words,
#         will create a set of defines with the form CW_<WORD>_DEBUG=5.
#         Ex. dbgmod=AVISINK DVDFEC will result in -DCW_AVISINK_DEBUG=5
#         and -DCW_DVDFEC_DEBUG=5.
#
# optimize - When set to a numeric value, will compile the code with that
#         optimization level.  Ex. 3 will be -O3
#
# nobuildlib - When building .out executables, will NOT force build of
#         dependent libraries.  It will just link with the libraries as
#         is.
#
# noprebuiltlib - When building .out executables, will not include the
#         prebuilt library paths in the link options.
#
# norecurse - When set will prevent recursive make in the tree.  Typically
#         used to rebuild code with debugging options on.
#
# noshow - When set will define CW_NOSHOW
#
# assert - If set to 1 all the assertions will be activated, if set to 2
#         only the preconditional assertions will be enabled, if not set
#         all the assertions will be disabled (the default setting is
#         project dependent).  Note that if "debug" is set it overwrites
#         the assertion setting and it enables all of the assertions.
#
# assertminimal - If set to 1 the assertions will print a minimal amount
#         of information in order to save code space.
#
# nowarning - If set then warnings will be treated as errors (default is
#         project dependent)
#
# volatile - If set then all variable will be treated as volatile (default
#         is set)
#
# cwunit - if set will define CWUNIT as cwUnit, all component having a
#         cwUnit sub directory (and having $(CWUNIT) in SUBDIRS) will have
#         the directory's content compiled.
#
# nomult -  If set C compiler will not use *MUL* instructions, audio decoder
#         will not be connected inside ZivaAudioFlowController and prebuild
#         libs wo multiply will be used.
#
# lint - If set will run SPLINT on the code.
#
# docs - Generate local documetation (both public and private versions).
#
# alldocs - Generate global documetation (both public and private versions).
#
# alldocspub - Generate global public documetation.
#
# alldocspriv - Generate global private documetation.
#
# mccabe - generate preprocessed, mccabe project and instrumented files
#	   for McCabe code analysis.
#
# noinst - Do not generate instrumented files for McCabe.
#
# standby - (make standby platform=<name>) to generate standby mode binaries
#
# standalone - (make standalone platform=<name> image=<image>) to generate standalone binaries
#
# profile - compile for profiling based on the functions prototyped in ./profile.h
#
# sclc - Show the number of the non-commented and comment lines of code for each source file (.c and .cpp). If recursive parameter is set to 1 we will see the files in the subdirectories too.
#
# slave - Triggers the linking of a slavelibrary into the application. (make all platform=<name> slave=<standalone.cfg name>)
#
# cpu - Specifies the CPU type of the target, to select the proper toolchain.
#       Allowed values are: "sparc", "mips" (case-sensitive).
#       "sparc" is the default, unless the command-line option is provided.
#       Set BUILDENV_CPU_TYPE environment variable to one of the allowed values
#       to override the default.
#
# codec - (D7 only, sparc only) Specifies the CODEC index to run on, 
#       Allowed values are: "1", "2". "1" is the default, 
#       unless the command-line option is provided.
#-------------------------------------------------------------------------


#-------------------------------------------------------------------------
# General build control.
#-------------------------------------------------------------------------

CCASE_BLD_UMASK = 2

.KEEP_STATE:

#-------------------------------------------------------------------------
# Default target platform.
# Currently supported targets are listed in $ROOT/targets.
#-------------------------------------------------------------------------
target = domino

ifeq "$(PLATFORM)" ""
    PLATFORM = $(platform)
endif

#-------------------------------------------------------------------------
# Default ARCH value
#-------------------------------------------------------------------------
ARCH := D7

#-------------------------------------------------------------------------
# TS muxer object file location
#-------------------------------------------------------------------------
MUX_OBJ = $(ROOT)/obj/domino/cware/activefilter/engine/mux/ProTransport
FLTE_OBJ = $(ROOT)/obj/domino/cware/activefilter/engine

#-------------------------------------------------------------------------
# Default values for all compilation variables
# NOTE: Can be changed in target specific .mk files
#-------------------------------------------------------------------------
nowarning=0
# "volatile" option has been broken in gcc since v.3.0. Remove it, once we
# move away from Tornado and its gcc 2.7.2
volatile=1
nomult=0
ifeq "$(norecurse)" "0"
    norecurse=
endif

#-------------------------------------------------------------------------
# Include wrenv.mk
# In wrenv.mk set environment variable about workbench 
#-------------------------------------------------------------------------
ifeq ("$(cpu)", "mips")
-include $(ROOT)/wrenv.mk
endif

#-------------------------------------------------------------------------
# Include environment detection mechanisms.
# Components that need to have environment-aware makefiles should include
# this makefile right after defining ROOT and MODULE.
#-------------------------------------------------------------------------
include $(ROOT)/common_env.mk
include $(ROOT)/config.mk
#-------------------------------------------------------------------------
# Default FW library locaion
# $(cpu) is guranteed to be defined until after common_env.mk is included
#-------------------------------------------------------------------------
#FWROOT should be defined in config.mk
ifndef FWROOT
    $(error 'FWROOT' is not defined)
#    FWROOT = $(ROOT)/fw_release
endif

ifeq ("$(cpu)", "x86_64")
    FW_INC = $(FWROOT)/r12c/x86/cware/inc/
    FW_LIB = $(FWROOT)/r12c/x86/cware/lib/
else
ifeq ("$(cpu)", "x86")
FW_INC = $(FWROOT)/r12c/x86/cware/inc/
FW_LIB = $(FWROOT)/r12c/x86/cware/lib/
else
ifeq ("$(cpu)", "mips")
FW_INC = $(FWROOT)/r1x/d7mips/cware/inc
FW_LIB = $(FWROOT)/r1x/d7mips/cware/lib
else
FW_INC = $(FWROOT)/r1x/d7sparc/cware/inc
FW_LIB = $(FWROOT)/r1x/d7sparc/cware/lib
endif
endif
endif
#-------------------------------------------------------------------------
# Default streamtype
# This is for historical reason. Only "new" is supported.
#-------------------------------------------------------------------------
streamtype  = new


#-------------------------------------------------------------------------
# Define the HAL include directory before including $target.mk so it can
# specify its HAL directories
#-------------------------------------------------------------------------
INCLUDE_HAL_DIR = $(ROOT)/include/hal

#-------------------------------------------------------------------------
# Include the platforms cwExtLib.mk to pick up the platform
# specific library list and associated paths
#-------------------------------------------------------------------------
-include $(ROOT)/lib/domino$(cpusuffix)/platform/$(PLATFORM)/cwExtLib.mk

#-------------------------------------------------------------------------
# For each target platform there should be a <target>.mk file in the ROOT
# directory that contain target-specific defines
#-------------------------------------------------------------------------

ifeq "$(cpu)" "mips"
	-include $(ROOT)/targets/$(target)_mips.mk
else
  ifeq "$(cpu)" "sparc"
	-include $(ROOT)/targets/$(target).mk
  else
	-include $(ROOT)/targets/$(target)_x86.mk
        WIND_HOST_TYPE	:= x86-linux2
  endif
endif

#-------------------------------------------------------------------------
# Parameters to pass along to recursive make
#-------------------------------------------------------------------------
MAKE_PARAMS = \
    'target=$(target)' \
    'kernel=$(kernel)' \
    'build=$(build)'

#-------------------------------------------------------------------------
# Directories
#-------------------------------------------------------------------------

SRC_ROOT        := $(ROOT)/src
SRC_DIR         := .
OBJ_DIR         := $(ROOT)/obj/$(target)$(cpusuffix)/$(MODULE)
HPP_INCLUDE_DIR := $(ROOT)/obj/$(target)/cware/hpp
BIN_DIR         := $(ROOT)/bin/$(target)$(cpusuffix)/$(PLATFORM)
DLL_DIR         := $(ROOT)/bin/$(target)$(cpusuffix)/AudioDLL
SYS_DLL_DIR     := $(ROOT)/bin/$(target)$(cpusuffix)/SysDLL
LIB_DIR         := $(ROOT)/lib/$(target)$(cpusuffix)
DOC_DIR         := $(ROOT)/doc/$(target)
INCLUDE_DIR     := $(ROOT)/include/cware/$(target)
KERNEL_DIR      := $(ROOT)/tornado/target/proj/$(target)$(cpusuffix)/$(kernel)
COMMON_DIR      = $(ROOT)/src/cware/streamHelp
PLATFORM_DIR    = $(LIB_DIR)/platform/$(PLATFORM)
LIB_ARCH_DIR := $(addprefix $(LIB_DIR)/, $(arch))
LIB_BITACCESS_DIR := $(addprefix $(LIB_DIR)/, $(bitacc))
PLATFORM_OBJ_DIR  = $(ROOT)/obj/$(target)$(cpusuffix)/cware/platform/$(PLATFORM)
PLATSTBY_OBJ_DIR  = $(ROOT)/obj/$(target)$(cpusuffix)/standby/src/platform/$(PLATFORM)
PLATFORM_CFG_DIR  = $(ROOT)/targets/platforms/$(PLATFORM)
ifneq "$(cpu)" "x86"
    ifneq "$(cpu)" "x86_64"
TOOLCHAIN_TARGET_DIR = $(WIND_BASE)/target
endif
endif

STANDALONE_BAL_OBJ_DIR  =  $(PLATFORM_OBJ_DIR)/$(image)/bal
STANDALONE_CONS_OBJ_DIR  = $(PLATFORM_OBJ_DIR)/$(image)/cons

# path to linkall.c which is used to build cware as object
LINKALL_C = $(PLATFORM_CFG_DIR)/linkall.c
LINKALL_OBJ = $(PLATFORM_OBJ_DIR)/linkall.o
LINKALL_COMPLETE_OBJ = $(PLATFORM_OBJ_DIR)/cware.o
LINKALL_VERBOSE = $(PLATFORM_OBJ_DIR)/linkall.txt
PLATFORM_OVERLAY_CFG = $(PLATFORM_CFG_DIR)/overlay.cfg

# used for prebuilt libraries
NOMULT_LIB =
ifneq "$(nomult)" "0"
    NOMULT_LIB = nomult_lib
    TARGET_DEFINES  += -DUSE_NO_MULTIPLY
endif
PREBUILT_LIB_DIR_TARGET = $(ROOT)/prebuilt_lib/$(NOMULT_LIB)/$(target)$(cpusuffix)
PREBUILT_LIB_DIR_COMMON = $(ROOT)/prebuilt_lib/$(NOMULT_LIB)

#-------------------------------------------------------------------------
# Final build goals.
#-------------------------------------------------------------------------
LIBRARY_OUT       = $(LIB_DIR)/lib$(LIBRARY).a
ifeq "$(LIBRARY)" ""
    LIB_ARCH_OUT      =
    LIB_BITACCESS_OUT =
else
    LIB_ARCH_OUT      = $(LIB_ARCH_DIR)/lib$(LIBRARY).a
    LIB_BITACCESS_OUT = $(LIB_BITACCESS_DIR)/lib$(LIBRARY).a
endif
MODULE_OUT         = $(BIN_DIR)/$(notdir $(MODULE)).out
MODULE_DLL_OUT     = $(DLL_DIR)/$(notdir $(DLL_MODULE)).so
MODULE_SYS_DLL_OUT = $(SYS_DLL_DIR)/$(notdir $(DLL_MODULE)).so
MODULE_MUNCH_OUT   = $(BIN_DIR)/$(notdir $(MODULE)).m.out
PLATFORM_OUT       = $(PLATFORM_DIR)/libplatform.a
MODULE_MAP         = $(BIN_DIR)/$(notdir $(MODULE)).map
BOOTROM            = $(BIN_DIR)/bootrom.hex
RAM_IMAGE          = $(BIN_DIR)/$(MODULE)-$(kernel)-ram
ROM_IMAGE          = $(BIN_DIR)/$(MODULE)-$(kernel)-rom.hex
ROM_CMP_IMAGE      = $(BIN_DIR)/$(MODULE)-$(kernel)-cmp.hex
ROM_RES_IMAGE      = $(BIN_DIR)/$(MODULE)-$(kernel)-res.hex

#-------------------------------------------------------------------------
# If we are using platform configuration, use platform library
#-------------------------------------------------------------------------
ifneq "$(PLATFORM)" ""
    PLATFORM_LIB = platform
    PLATSTBY_LIB = $(addsuffix standby, $(PLATFORM_LIB))
    EXTLIBS_MK   = $(PLATFORM_DIR)/cwExtLib.mk
    EXTLIBS_OUT  = $(PLATFORM_DIR)/cwExtib.pl
endif

#-------------------------------------------------------------------------
# Partially linked application object file used to build kernel image.
#-------------------------------------------------------------------------
APP_MODULE = \
    $(KERNEL_DIR)/module.o

#-------------------------------------------------------------------------
# List of all libraries to be linked with the module with -l in front
#
# Note: This variable, ALL_LIBS, is now only used to create cwExtLib.mk
# The $(MODULE_OUT) expansion will depend on the contents of the
# given platforms' cwExtLib.mk.
#-------------------------------------------------------------------------
ifeq "$(cpu)" "sparc"
#-------------------------------------------------------------------------
# FIXME: Just a temp solution at current stage,Since there is still
# no libraries (such as CSS, ieee1394,...)avaialbe for nomult version
#-------------------------------------------------------------------------
ifneq "$(nomult)" "0"
    CWARE_RM_LIBS += CSS ieee1394 doscore udfcore udfutil usb20
endif
ALL_LIBS = \
    $(addprefix -l,             \
                cware           \
                $(PLATFORM_LIB) \
                $(CUSTOMER_LIB) \
                $(MODULE_LIBS)  \
                $(filter-out $(CWARE_RM_LIBS), $(TARGET_LIBS)))
endif
ifeq "$(cpu)" "mips"
ALL_LIBS = \
    $(addprefix -l,             \
                cware           \
                $(PLATFORM_LIB) $(MODULE_LIBS))
endif
ifeq "$(cpu)" "x86"
ALL_LIBS = \
    $(addprefix -l,             \
                cware           \
                $(PLATFORM_LIB) \
                $(CUSTOMER_LIB) \
                $(MODULE_LIBS)  \
                $(filter-out $(CWARE_RM_LIBS), $(TARGET_LIBS)))
endif
ifeq "$(cpu)" "x86_64"
ALL_LIBS = \
    $(addprefix -l,             \
                cware           \
                $(PLATFORM_LIB) \
                $(CUSTOMER_LIB) \
                $(MODULE_LIBS)  \
                $(filter-out $(CWARE_RM_LIBS), $(TARGET_LIBS)))
endif
#------------------------------------------------------------------------
# Compilation variable are handled here, see beginning of file for details
#------------------------------------------------------------------------
ifeq ($(nowarning), 1)
    TARGET_DEFINES  += -Werror
endif

ifeq ($(volatile), 1)
    TARGET_DEFINES  := $(TARGET_DEFINES) -fvolatile
else
    ifeq ($(volatile), global)
        TARGET_DEFINES  := $(TARGET_DEFINES) -fvolatile-global
    endif
endif

TARGET_DEFINES += -DARCH_MIPS=1 -DARCH_SPARC=0

TARGET_DEFINES += -D$(os)
ifeq "$(cpu)" "mips"
    TARGET_DEFINES += -DTHIS_CPU_ARCH=ARCH_MIPS -DMIPS_CBUSREGS_USAGE
endif
ifeq "$(cpu)" "sparc"
    TARGET_DEFINES += -DTHIS_CPU_ARCH=ARCH_SPARC
endif

# per the email, the SW_CODEC for R12CPU
ifeq "$(cpu)" "x86"
    TARGET_DEFINES += -DSW_CODEC -D__vxworks -DTHIS_CPU_ARCH=ARCH_SPARC -m32 -Wno-write-strings -fno-builtin-printf -g
else
    ifeq "$(cpu)" "x86_64"
        TARGET_DEFINES += -DSW_CODEC -DX86_64 -D__vxworks -DTHIS_CPU_ARCH=ARCH_SPARC -m64 -Wno-write-strings -fno-builtin-printf -g -fno-builtin
    endif
endif

ifeq "$(multiencoder)" "1"
    TARGET_DEFINES  += -DMULTIENCODER
endif


# Three variables drive McCabe. If no instrumentation is needed,
# MCCABE_COMP but not MCCABE_BUILD is defined. Instrumentation
# causes MCCABE_BUILD to be defined. MCCABE_PROJ_DIR allows you to
# change the McCabe intermediate file directory from the make
# command line away from its default value.
ifeq ($(mccabe), 1)
	MCCABE_COMP = mccabe_comp
    ifeq ($(noinst),)
        MCCABE_BUILD = build_mccabe
    endif
    ifeq ($(mccabedir),)
        MCCABE_PROJ_DIR = mccabe
    else
        MCCABE_PROJ_DIR = $(mccabedir)
    endif
endif

#-------------------------------------------------------------------------
# Global '-D' defines.
#-------------------------------------------------------------------------


ifeq ($(assertminimal), 1)
    DEBUG_DEFINES  += -DCW_ASSERT_MEMORY_SAVING
endif

ifeq ($(assert), 1)
    DEBUG_DEFINES  += -DCW_ASSERT_ENABLED
else
    ifeq ($(assert), 2)
        DEBUG_DEFINES  += -DCW_ASSERT_PRECONDITION_ENABLED
    endif
endif

# If the master debug flag is set on the make command line then use debug build
ifeq "$(cpu)" "x86"
  ifneq "$(debug)" ""
      ASM_DEBUG_DEFINES = -g
      DEBUG_DEFINES += -g
  endif
else
    ifeq "$(cpu)" "x86_64"
      ifneq "$(debug)" ""
          ASM_DEBUG_DEFINES = -g
          DEBUG_DEFINES += -g
      endif
    else

  ifneq "$(debug)" ""

      ASM_DEBUG_DEFINES = -gstabs
      DEBUG_DEFINES += -g
      ifeq "$(debug)" "2"
          DEBUG_DEFINES += -DCW_MAKEOPT_VERBOSE=1
      endif

  endif
endif
endif

# The dbgmodules variable contains a list of modules debug values.  Use this string
# to create corresponding defines
ifneq "$(dbgmod)" ""
    # For variable MOD create CW_MOD_DEBUG
    DEBUG_DEFINES += $(addsuffix _DEBUG=100, $(addprefix -DCW_, $(dbgmod)))
endif

# If the master debug flag is set on the make command line then use debug build
ifneq "$(optimize)" ""
    OPTLEVEL = $(optimize)
else
    OPTLEVEL = 0
endif

# profiling control - the script turns off warnings if profiling is used
ifneq "$(profile)" ""
PROFILE         = perl $(UTILS_COMMON_BIN)/tools/profile.pl profile.h
else
PROFILE         =
endif

# Individual makefiles can set optimization level overrides which are set in the
# target.mk file.  This override is used UNLESS the optimization level is 0 due
# to the assumption that level 0 is reserved for debugging.
ifneq "$(OPTLEVEL_OVERRIDE)" ""
    ifneq ($(OPTLEVEL), 0)
        OPTLEVEL = $(OPTLEVEL_OVERRIDE)
        OVERRIDE = 1
    endif
endif

# Add support for VxSim
ifeq ($(BUILD_SPEC),SIMSPARCSOLARISgnu)
    CPU_DEFINES = -DCPU=SIMSPARCSOLARIS
else
    ifeq "$(cpu)" "sparc"
        CPU_DEFINES = -DCPU=SPARC
    else
        ifeq "$(cpu)" "mips"
            CPU_DEFINES = -DCPU=MIPSI32R2 -DMIPSEB
 #           CPU_DEFINES = -DCPU=MIPS32 -DMIPSEB
        endif
# how CPU_DEFINES, X86?
        ifeq "$(cpu)" "x86"
            CPU_DEFINES = -DCPU=41 -DMIPSEL
        else
            ifeq "$(cpu)" "x86_64"
                CPU_DEFINES = -DCPU=41 -DMIPSEL
        endif        
    endif
             
    endif
endif

ALL_DEFINES = \
    $(CPU_DEFINES) \
    $(TARGET_DEFINES) \
    $(MODULE_DEFINES) \
    $(DEBUG_DEFINES)

#
# If the noshow make variable is specified then define CW_NOSHOW
#
ifneq "$(noshow)" ""
    ALL_DEFINES += -DCW_NOSHOW
endif

#-------------------------------------------------------------------------
# Global '-I' includes.
#-------------------------------------------------------------------------
COMMON_INCLUDES = \
    -I$(ROOT)/include \
    -I$(ROOT)/include/hal \
    -I$(ROOT)/include/cware \
#end of COMMON_INCLUDES

GENERATED_INCLUDES = \
    -I$(ROOT)/include/cware/$(target) \
#end of GENERATED_INCLUDES

MAPI_LIB_INCLUDES = \
    -I$(MAPI_BASE_DIR)/include/mapi\
#end of GENERATED_INCLUDES

CWARE_INCLUDES = \
    -I$(ROOT)/src/cware/include \
    -I$(ROOT)/src/cware/core/$(ARCH)/include/arch \
    $(MODULE_INCLUDES) \
    $(TARGET_INCLUDES) \
    $(MAPI_LIB_INCLUDES) \
#end of CWARE_INCLUDES

BSP_INCLUDES = \
    -I$(DMN_COMMON) \
#end of BSP_INCLUDES

OS_INCLUDES = -I$(TOOLCHAIN_TARGET_DIR)/h

ifeq "$(toolchain)" "WORKBENCH"
    OS_INCLUDES += -I$(WIND_GNU_PATH)/lib/gcc/mips-wrs-vxworks/4.1.2/include \
                  -I$(WIND_GNU_PATH)/include/c++/4.1 \
                  -I$(TOOLCHAIN_TARGET_DIR)/h/wrn/coreip
endif

ifeq "$(cpu)" "x86"
    OS_INCLUDES += -I$(ROOT)/x86/os_wrapper/h
    BSP_INCLUDES += -I$(ROOT)/tornado/target/config/dmnCommon 
    BSP_INCLUDES += -I$(ROOT)/x86/bsp/include
endif

ifeq "$(cpu)" "x86_64"
    OS_INCLUDES += -I$(ROOT)/x86/os_wrapper/h
    BSP_INCLUDES += -I$(ROOT)/tornado/target/config/dmnCommon
    BSP_INCLUDES += -I$(ROOT)/x86/bsp/include
endif

ALL_INCLUDES := \
    -I. \
    $(COMMON_INCLUDES) \
    $(GENERATED_INCLUDES) \
    $(CWARE_INCLUDES) \
    $(BSP_INCLUDES) \
    $(OS_INCLUDES) \
#end of ALL_INCLUDES

#-------------------------------------------------------------------------
# List of all files to be c2ph-ed
#-------------------------------------------------------------------------
C2PH_INCLUDES = $(patsubst %.h, $(OBJ_DIR)/%_ph.h, $(MODULE_C2PH_FILES))

#-------------------------------------------------------------------------
# List of all source files modules in SRC_DIR directory.
#-------------------------------------------------------------------------
SRC_FILES = \
    $(wildcard $(SRC_DIR)/*.[csS] $(SRC_DIR)/*.cpp)

ifeq (,$(findstring $(HPP_INFOC),$(SRC_FILES)))
  SRC_FILES += $(HPP_INFOC)
endif

# generated source files: a subset of SRC_FILES which "make clean" removes
GEN_SRC_FILES = $(HPP_INFOC)

# component factory config files (not Make files, in spite of the name)
CMPFACTORY_MK_FILES := \
	$(patsubst $(SRC_DIR)/%,%,$(wildcard $(SRC_DIR)/cmpfactory_*.mk))

ifneq ($(PLATFORM), "")
   ifeq ($(findstring $(PLATFORM)/stub,$(MODULE)), $(PLATFORM)/stub)
      MODULE_OBJS += CCmpFactory.o
      SRC_FILES += $(SRC_DIR)/CCmpFactory.c
      GEN_SRC_FILES += $(SRC_DIR)/CCmpFactory.c
$(OBJ_DIR)/CCmpFactory.o: $(SRC_DIR)/CCmpFactory.c
   endif
endif

#-------------------------------------------------------------------------
#Reverse the source files from the obj files
#-------------------------------------------------------------------------
MODULE_OBJS_TMP = $(subst .m,.c, $(subst .o,.c, $(MODULE_OBJS)))
MODULE_OBJS_TMP += $(subst .m,.cpp, $(subst .o,.cpp, $(MODULE_OBJS)))
MODULE_OBJS_TMP += $(subst .n,.s, $(subst .o,.s, $(MODULE_OBJS)))
MODULE_OBJS_TMP += $(subst .n,.S, $(subst .o,.S, $(MODULE_OBJS)))
MODULE_OBJS_REVS = $(addprefix $(SRC_DIR)/,$(MODULE_OBJS_TMP))
OBJ_SRC_FILES = $(filter $(MODULE_OBJS_REVS), $(SRC_FILES))
#-------------------------------------------------------------------------
# List of fully qualified object files.
#-------------------------------------------------------------------------
OBJ_FILES = \
    $(addprefix $(OBJ_DIR)/, $(MODULE_OBJS))

OBJ_SUB_FILES = \
    $(wildcard $(OBJ_DIR)/*.o)\
    $(wildcard $(OBJ_DIR)/*/*.o)\
    $(wildcard $(OBJ_DIR)/*/*/*.o)\

#-------------------------------------------------------------------------
# Files used to build dependancy rules.
#-------------------------------------------------------------------------
DEP_FILE        = $(OBJ_DIR)/depends.mk
TMP_FILE        = $(OBJ_DIR)/depends.tmp
FIXDEP          = $(ROOT)/fixdep.pl

#-------------------------------------------------------------------------
# Development tool and utilities.
#-------------------------------------------------------------------------

# Base directories
UTILS_BIN       = $(ROOT)/utils/$(WIND_HOST_TYPE)
UTILS_COMMON_BIN    = $(ROOT)/utils


ifeq "$(toolchain)" "TORNADO"
    ifeq  "$(cpu)" "sparc"
        ifneq ($(findstring ccsparc.exe,$(wildcard $(WIND_BASE)/host/$(WIND_HOST_TYPE)/bin/*.exe)),)
            RESULTS := $(shell perl -I$(ROOT)/utils/$(WIND_HOST_TYPE) $(ROOT)/common.pl VersionPredicates $(strip $(WIND_BASE)/host/$(WIND_HOST_TYPE)/bin/ccsparc))
        else
            ifneq ($(findstring ccsparc,$(wildcard $(WIND_BASE)/host/$(WIND_HOST_TYPE)/bin/*)),)
                RESULTS := $(shell perl -I$(ROOT)/utils/$(WIND_HOST_TYPE) $(ROOT)/common.pl VersionPredicates $(strip $(WIND_BASE)/host/$(WIND_HOST_TYPE)/bin/ccsparc))
            else
                RESULTS := $(shell perl -I$(ROOT)/utils/$(WIND_HOST_TYPE) $(ROOT)/common.pl VersionPredicates $(strip $(WIND_BASE)/host/gnu/4.1.2-vxworks-5.5/$(WIND_HOST_TYPE)/bin/ccsparc))
            endif
        endif
		IS_CC_VERSION_BELOW_4_0 = $(word 2, $(RESULTS))
    	ifeq "$(IS_CC_VERSION_BELOW_4_0)" "no"
	        TOOLS_BIN       = $(strip $(WIND_BASE)/host/gnu/4.1.2-vxworks-5.5/$(WIND_HOST_TYPE)/bin)
	        COREUTILS_BIN   = $(strip $(WIND_BASE)/host/$(WIND_HOST_TYPE)/bin)
		else
        	TOOLS_BIN       = $(strip $(WIND_BASE)/host/$(WIND_HOST_TYPE)/bin)
	        COREUTILS_BIN   = $(strip $(TOOLS_BIN))
		endif

    # We use the tools in the VOB for cross-compling but use
    # tools out of the path if we use VxSim

    ifneq ($(BUILD_SPEC),SIMSPARCSOLARISgnu)

	# Tools for building code
	AR              = $(TOOLS_BIN)/arsparc
	AS              = $(TOOLS_BIN)/ccsparc

	#assembler for e5.X Magnum SPARC instructions
	ifeq "$(IS_CC_VERSION_BELOW_4_0)" "no"
		CUBAS         = $(ROOT)/cware_tools/$(WIND_HOST_TYPE)/e6-elf-as
	else
		CUBAS         = $(ROOT)/cware_tools/$(WIND_HOST_TYPE)/sparc-aout-as
	endif

	CC              = $(TOOLS_BIN)/ccsparc
	CCC             = $(TOOLS_BIN)/ccsparc
	CPP             = $(CC) -E -P -xc
	LD              = $(TOOLS_BIN)/ldsparc
	NM              = $(TOOLS_BIN)/nmsparc -g
	OBJCOPY         = $(TOOLS_BIN)/objcopysparc
	OBJDUMP         = $(TOOLS_BIN)/objdumpsparc
	RANLIB          = $(TOOLS_BIN)/ranlibsparc
	SIZE            = $(TOOLS_BIN)/sizesparc
    endif
endif
else
   ifeq "$(toolchain)" "WORKBENCH"
   ifeq  "$(cpu)" "mips"
        TOOLS_BIN       = $(strip $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin)
        COREUTILS_BIN   = $(strip $(WIND_TOOLS)/$(WIND_HOST_TYPE)/bin)

	# Tools for building code
	AR              = $(TOOLS_BIN)/armips
	AS              = $(TOOLS_BIN)/ccmips

	#assembler for e5.X Magnum SPARC instructions - not available on MIPS
#	CUBAS         = @echo "ERROR: CUBAS does not work with MIPS target type."; false
	CUBAS           = $(AS) -mips32r2

	CC              = $(TOOLS_BIN)/ccmips
	CCC             = $(CC)
	CPP             = $(CC) -E -P
	LD              = $(TOOLS_BIN)/ldmips
	NM              = $(COREUTILS_BIN)/nmmips -g
	OBJCOPY         = $(COREUTILS_BIN)/objcopymips
	OBJDUMP         = $(TOOLS_BIN)/objdumpmips
	RANLIB          = $(TOOLS_BIN)/ranlibmips
	SIZE            = $(TOOLS_BIN)/sizemips
    endif
    endif
    
   ifeq  "$(cpu)" "x86"
      AR        = $(GCC_EXEC_PREFIX)ar
      AS        = $(GCC_EXEC_PREFIX)as
      CC        = $(GCC_EXEC_PREFIX)gcc
      CCC       = $(CC)
      CPP       = $(CC) -E -P
      CUBAS     = $(AS) --32 
      LD        = $(GCC_EXEC_PREFIX)ld 
      NM        = $(GCC_EXEC_PREFIX)nm
      OBJDUMP   = $(GCC_EXEC_PREFIX)objdump
      OBJCOPY   = $(GCC_EXEC_PREFIX)objcopy
      RANLIB    = $(GCC_EXEC_PREFIX)ranlibmips
      SIZE      = $(GCC_EXEC_PREFIX)size
   endif

   ifeq  "$(cpu)" "x86_64"
      AR        = $(GCC_EXEC_PREFIX)ar
      AS        = $(GCC_EXEC_PREFIX)as
      CC        = $(GCC_EXEC_PREFIX)gcc
      CCC       = $(CC)
      CPP       = $(CC) -E -P
      CUBAS     = $(AS) --64
      LD        = $(GCC_EXEC_PREFIX)ld 
      NM        = $(GCC_EXEC_PREFIX)nm
      OBJDUMP   = $(GCC_EXEC_PREFIX)objdump
      OBJCOPY   = $(GCC_EXEC_PREFIX)objcopy
      RANLIB    = $(GCC_EXEC_PREFIX)ranlibmips
      SIZE      = $(GCC_EXEC_PREFIX)size
   endif
endif

LSFILES         := $(ROOT)/ls.pl

# Get the host type
UNAME = $(shell uname)

# We need to set various variables differently to retain SPARC and PC
# build compatibility so we set HOST_TYPE to identify
ifneq (,$(findstring SunOS,${UNAME}))
    HOST_TYPE   = Solaris2
else
ifneq (,$(findstring Linux,${UNAME}))
    HOST_TYPE   = Linux
else
    HOST_TYPE   = Wintel
endif
endif

BEAUTY_PARAM    = \
    -bad -bap -bbb -bfda -bli0 -brs \
    -cdw -ci0 -cli4 \
    -di0 \
    -i4 -ip0 \
    -l120 -lc120 -lp \
    -nce -npcs -npsl -nsaf -nsai -nut \
    -sob \
    -ts4

SPLINT_PARAM    = \
    $(ALL_INCLUDES) -I$(ROOT)/utils/x86-win32/splint-3.1.1/lib \
    +skip-sys-headers \
    -sys-dirs $(TOOLCHAIN_TARGET_DIR)/h

ifeq "$(cpu)" "sparc"
    DUMMY_LIB_DIR = $(ROOT)/lib/$(target)$(cpusuffix)
    DUMMY_LIB_SCRIPT =  perl $(UTILS_COMMON_BIN)/create_dummy_lib.pl
else
    DUMMY_LIB_SCRIPT =  @echo "ERROR: DUMMY_LIB_SCRIPT is only for SPARC! \
                               Update the script and remove this message"; false
endif

#-------------------------------------------------------------------------
# Helper tools and utilities.
#-------------------------------------------------------------------------

# Set tools directory to Solaris or wintel depending on host
# We need to set recursive make since clearmake cannot use -C option
# to cd to a directory and shell's way to combine commands on unix
# NT are different.

ifneq (,$(findstring SunOS,$(UNAME)))
    PATH                := $(UTILS_BIN)/:$(PATH)
    CAT                 = cat
    CP                  = -cp
    MV                  = mv
    RM                  = -rm -f
    RMRECURSE           = -rm -rf
    MKDIR               = mkdir -p
    RMDIR               = rmdir
    C2PH                = perl $(UTILS_BIN)/e5_c2ph -W
    FIXPRIVINC          = perl $(UTILS_COMMON_BIN)/fixprivinclude.pl
    SED                 = /usr/bin/sed
    PERL                = perl

else
    # PC's use lower case or mixed case path variables. '/' for Workbench; '\' for Tornado.
    # for some reason, $(Path) doesn't get resolved properly when common.mk is processed
    # from a cygwin terminal so force it to $(PATH)
    ifeq "$(TERM)" "cygwin"
	Path                := $(UTILS_BIN);$(TOOLS_BIN);$(COREUTILS_BIN);$(PATH)
    else
	Path                := $(UTILS_BIN);$(TOOLS_BIN);$(COREUTILS_BIN);$(Path)
    endif
    ifeq "$(HOST_TYPE)" "Wintel"
    	Path            := $(subst /,\\,$(Path))
    endif
    path                := $(Path)
    ifeq "$(HOST_TYPE)" "Linux"
        PATH            := $(subst ;,:,$(Path)):$(PATH)
        CAT             = cat
        CP              = cp
        MV              = mv
        MKDIR           = mkdir -p
        RMDIR           = rmdir
        RM              = rm -f
        RMRECURSE       = rm -rf
        PERL            = perl
        C2PH            = perl $(UTILS_BIN)/e5_c2ph
    else
        PATH            := $(Path)
        CAT             = $(UTILS_BIN)/cat
        CP              = cp
        CP_DOS_ALT      = copy
        MV              = $(UTILS_BIN)/mv
        RM              = rm -f
        # for some reason, specifying path breaks wildcard substitution
        # normally, rm is from Tornado installation, same as make
        RMRECURSE       = $(COREUTILS_BIN)/rm -rf
        MKDIR           = $(UTILS_BIN)/mkdir -p
        RMDIR           = $(UTILS_BIN)/rmdir
        DOXY_UTILS_BIN  = $(UTILS_BIN)/doxy
        DOXYGEN         = $(DOXY_UTILS_BIN)/v1.5.1p1/doxygen
        PERL		= $(UTILS_BIN)/perl -I$(UTILS_BIN)
        C2PH                = perl $(UTILS_BIN)/e5_c2ph -t -W
    endif
    MAKEOVERLAYS        = perl $(UTILS_BIN)/makeoverlays.pl
    SCLC                = perl -I$(UTILS_BIN) $(UTILS_COMMON_BIN)/tools/sclc.pl
endif

    ITOOL               = perl $(UTILS_COMMON_BIN)/tools/itool.pl
    DUS                 = perl $(UTILS_BIN)/add_.pl
    CWUNITGEN           = perl $(UTILS_COMMON_BIN)/tools/cwUnitGenInfo.pl
    CWUNITLIST          = perl $(UTILS_COMMON_BIN)/tools/cwUnitList.pl
    CWUNITDIFF          = perl $(UTILS_COMMON_BIN)/tools/cwUnitListDiff.pl
    BEAUTY              = $(UTILS_BIN)/indent $(BEAUTY_PARAM)
    SPLINT_UTILS_BIN    = $(UTILS_BIN)/splint-3.1.1
    SPLINT              = $(SPLINT_UTILS_BIN)/bin/splint -f $(ROOT)/targets/$(target)/splintrc
    SPLINT_ARCHPATH     = $(SPLINT_UTILS_BIN)/lib
ifeq "$(os)" "OS_VXWORKS_5_4"
    MKSTANDBY           = perl $(UTILS_COMMON_BIN)/tools/makeStandby.pl
else
    MKSTANDBY           = perl $(UTILS_COMMON_BIN)/tools/makeStandbyElf.pl
endif
    MKSTANDALONE        = perl $(UTILS_BIN)/standalone.pl
    MKGETSLAVE          = perl $(UTILS_BIN)/getslave.pl
    MKCMPFACTORY        = perl $(UTILS_COMMON_BIN)/tools/cmpfactory.pl
    COMMON_PL		= $(PERL) $(ROOT)/common.pl


#-------------------------------------------------------------------------
# Compiler version detection and facilities to maintain version-dependent code.
#-------------------------------------------------------------------------

# Compute some predicates relating to the version of $(CC).
# Since make doesn't have arithmetic facilities, use a call to Perl to
# evaluate all expressions of interest.
# (Using only 1 external call for multiple calculations to speed things up).
ifneq "$(cpu)" "x86"
    ifneq "$(cpu)" "x86_64"
RESULTS := $(shell $(COMMON_PL) VersionPredicates $(CC))
endif
endif

IS_CC_VERSION_BELOW_3_0 = $(word 1, $(RESULTS))
IS_CC_VERSION_BELOW_4_0 = $(word 2, $(RESULTS))

# Since C++ compiler is the same version as C compiler, copy values.
ifeq "$(CC)" "$(CCC)"
    CCC_VERSION_DOTS = $(CC_VERSION_DOTS)
    CCC_VERSION = $(CC_VERSION)
    IS_CCC_VERSION_BELOW_3_0 = $(IS_CC_VERSION_BELOW_3_0)
    IS_CCC_VERSION_BELOW_4_0 = $(IS_CC_VERSION_BELOW_4_0)
endif

#-----------------------------------------------------------------------
# Command line options for development tools.
#-----------------------------------------------------------------------
STDLIB_FLAGS =
ifeq "$(cpu)" "mips"
    STDLIB_FLAGS += -nostdlib
endif

ifeq "$(IS_CC_VERSION_BELOW_4_0)" "no"
	MODULE_CFLAGS := $(subst -mflat,, $(MODULE_CFLAGS))
endif

CBASEFLAGS = -O$(OPTLEVEL) \
        $(ALL_DEFINES) \
        $(ALL_INCLUDES) \
        $(MODULE_CFLAGS)

ifneq "$(cpu)" "x86"
    ifneq "$(cpu)" "x86_64"
CBASEFLAGS += -O$(OPTLEVEL) \
        -Wall -Wno-char-subscripts \
        -fno-builtin \
        -fno-guess-branch-probability 
endif
endif

ifeq "$(IS_CC_VERSION_BELOW_4_0)" "no"
	CBASEFLAGS += -Wno-strict-aliasing
else
    ifneq "$(cpu)" "x86"
        ifneq "$(cpu)" "x86_64"
        CBASEFLAGS += -nostdinc
    endif
endif
endif

ifeq "$(nomult)" "0"
    ifeq "$(cpu)" "sparc"
        ifeq "$(IS_CC_VERSION_BELOW_3_0)" "yes"
            CBASEFLAGS += -mv8
        else
            CBASEFLAGS += -mcpu=v8
        endif
    endif
endif

ifeq "$(cpu)" "mips"
    CBASEFLAGS += -mips32r2
endif

CFLAGS = $(CBASEFLAGS)

CFLAGS += -std=gnu89

CCC_FLAGS = \
    $(CBASEFLAGS) \
    -fno-rtti \
    -fno-exceptions

ifeq "$(IS_CC_VERSION_BELOW_3_0)" "yes"
    CCC_FLAGS += -fvtable-thunks
    CCC_FLAGS += -nostdinc++
endif

ifeq "$(IS_CC_VERSION_BELOW_4_0)" "no"
	ifneq ($(findstring c++, $(CFLAGS)),c++)
		CFLAGS += -Wno-pointer-sign
	endif
endif

CFLAGS_AS = \
    $(CFLAGS) \
    -P \
    -x assembler-with-cpp

#-------------------------------------------------------------------------
# Compiler version-based error checking.
#-------------------------------------------------------------------------
# verifies that flags obsolete by gcc 3.0 are not used
ifeq "$(IS_CC_VERSION_BELOW_3_0)" "no"
    $(if $(filter -fvolatile% -fno-volatile%, $(TARGET_DEFINES)), \
         $(error "-fvolatile-... family2 has been broken since gcc 3.0.0. Current version is $(CC_VERSION_DOTS)"))

    $(if $(filter -fvtable-thunks, $(CCC_FLAGS)), \
         $(warning "-fvtable-thunks is obsolete as of gcc 3.x. Remove it..."))
endif

#-------------------------------------------------------------------------
# Compiler cpu-based error checking (to catch errors in local Makefiles).
#-------------------------------------------------------------------------
ifeq "$(cpu)" "mips"
    $(if $(filter -ffixed-o% -ffixed-i% -ffixed-g%,$(MODULE_CFLAGS)), \
         $(error $(cpu) compilation failed due to a possible error in your code: -ffixed-... \
         flag in Makefile is CPU dependent. Modify your code and the Makefile to use MIPS registers.))
    ifneq (,$(filter -mno-app-regs,$(MODULE_CFLAGS)))
    	 $(warning Option -mno-app-regs doesn't make sense for $(cpu) CPU type. Ignoring)
    	 MODULE_CFLAGS := $(filter-out -mno-app-regs,$(MODULE_CFLAGS))
    endif
endif

#-----------------------------------------------------------------------
# LDFLAGS_PARTIAL:
#
#   This variable defines the flags, including the paths required to
# link with cware, provided to the link commands found in this common.mk.
# Note, the path variants added to this variable are sourced from the
# cwExtLib.mk provided by each platform.  The rule is: A final link which uses
# LDFLAGS_PARTIAL cannot occur if a platform name has not been specified.
#-----------------------------------------------------------------------
# if noprebuiltlib is set then we don't use the prebuilt libs path
#-----------------------------------------------------------------------

ifneq "$(noprebuiltlib)" ""
LDFLAGS_PARTIAL = -X -r $(addprefix -L$(ROOT),$(subst -L,,$(CW_LIB_PATHS))) -L$(FW_LIB)
else
    ifeq "$(script)" "1"
    LDFLAGS_PARTIAL = -T linkscript.xr --verbose -X -r $(addprefix -L$(ROOT),$(subst -L,,$(CW_LIB_PATHS))) -L$(PREBUILT_LIB_DIR_TARGET) -L$(PREBUILT_LIB_DIR_COMMON) -L$(FW_LIB) -L$(MUX_OBJ) -L$(FLTE_OBJ)
    else
    LDFLAGS_PARTIAL = -X -r $(addprefix -L$(ROOT),$(subst -L,,$(CW_LIB_PATHS))) -L$(PREBUILT_LIB_DIR_TARGET) -L$(PREBUILT_LIB_DIR_COMMON) -L$(FW_LIB)
    endif
endif

#-----------------------------------------------------------------------
# LDFLAGS_COMPLETE:
#
#   This variable defines the flags and paths required to link to
# cware based on other variables, such as LIB_DIR, defined to this point
# of the build execution.  The only intended use of this variable is to
# specify the paths that must end up in a given cwExtLib.mk.
#-----------------------------------------------------------------------
ifneq "$(noprebuiltlib)" ""
LDFLAGS_COMPLETE = -X -r -L$(LIB_DIR) -L$(LIB_DIR)/$(ARCHLIB) -L$(LIB_DIR)/$(BITINSTR) -L$(CUSTOMER_DIR) -L$(PLATFORM_DIR) -L$(DMN_LIB_COMMON)
else
LDFLAGS_COMPLETE = -X -r -L$(LIB_DIR) -L$(LIB_DIR)/$(ARCHLIB) -L$(LIB_DIR)/$(BITINSTR) -L$(CUSTOMER_DIR) -L$(PLATFORM_DIR) -L$(DMN_LIB_COMMON) -L$(PREBUILT_LIB_DIR_TARGET) -L$(PREBUILT_LIB_DIR_COMMON)
endif


# if cwunit is set, then define CWUNIT as cwUnit, for components to build their
# unit test
ifneq "$(cwunit)" ""
CWUNIT = cwUnit
endif

# used to prelink to <module>.so
ifeq "$(cpu)" "x86_64"
    LDFLAGS_MAKESO = -X -r -melf_x86_64
else
ifeq "$(cpu)" "x86"
    LDFLAGS_MAKESO = -X -r -melf_i386
else
    LDFLAGS_MAKESO = -X -r
endif
endif

#-----------------------------------------------------------------------
# TARGET_LDFLAGS and MODULE_LIBS:
#
# When building a slave image put the slave image library in the
# linkable libs by determined by the mode of getslave.pl
#
#-----------------------------------------------------------------------
ifneq ($(strip $(slave)),)
	TARGET_LDFLAGS_SLAVE := $(shell $(MKGETSLAVE) -p=$(PLATFORM) -r=$(ROOT) -s=$(slave) -t=$(target) -m=-L)
	TARGET_LDFLAGS += $(TARGET_LDFLAGS_SLAVE)
	MODULE_LIBS_SLAVE := $(shell $(MKGETSLAVE) -p=$(PLATFORM) -r=$(ROOT) -s=$(slave) -t=$(target) -m=-l)
	MODULE_LIBS += $(MODULE_LIBS_SLAVE)
endif


#-----------------------------------------------------------------------
# Pattern Rules.
#-----------------------------------------------------------------------

INTERMEDIATE_FILES := $(addsuffix .dus.S, $(addprefix $(OBJ_DIR)/,$(filter %.m, $(MODULE_OBJS))))

$(OBJ_DIR)/%.o: %.s
	@echo '['$<']'
	$(CC) $(CFLAGS_AS) $(ASM_DEBUG_DEFINES) -c -o $@ $<

$(OBJ_DIR)/%.o: %.S
	@echo '['$<']'
	$(CC) $(CFLAGS_AS) $(ASM_DEBUG_DEFINES) -c -o $@ $<

$(OBJ_DIR)/%.n: %.S
	@echo Cube '['$<']' objdir $(OBJ_DIR)
	$(DUS)                 $<   $@.dus.S
	$(CPP) $(CFLAGS) -c -o $@.s $@.dus.S
	$(CUBAS)         $(ASM_DEBUG_DEFINES)    -o $@   $@.s

$(OBJ_DIR)/%.n: %.s
	@echo Cube '['$<']'	objdir $(OBJ_DIR)
	$(DUS)                 $<   $@.dus.S
	$(CPP) $(CFLAGS) -c -o $@.s $@.dus.S
	$(CUBAS)         $(ASM_DEBUG_DEFINES)    -o $@   $@.s


#-------------------------------------------------------------------------
# Profile dependent suffix rules
#-------------------------------------------------------------------------

# If building McCabe-instrumented files, the instrumented source
# should be used instead of the original source. The instrumented
# source is found in a different directory. This variable is blank
# if not doing a McCabe build.
ifdef MCCABE_BUILD
SOURCE_DIR = $(MCCABE_INST_DIR)/
endif

INTERMEDIATE_FILES += $(addsuffix .x, $(addprefix $(OBJ_DIR)/,$(filter %.m, $(MODULE_OBJS)))) \
                      $(addsuffix .s, $(addprefix $(OBJ_DIR)/,$(filter %.m, $(MODULE_OBJS))))

$(OBJ_DIR)/%.o: %.c
	@echo '['$<']'
	$(PROFILE) $(CC) $(CFLAGS) -c -o $@ $(SOURCE_DIR)$<

$(OBJ_DIR)/%.m: %.c
	@echo Cube '['$<']' objdir $(OBJ_DIR)
	$(PROFILE) $(CC) -S $(CFLAGS) -c -o $@.x $(SOURCE_DIR)$<
	$(CPP) $(CFLAGS) -x assembler-with-cpp -c -o $@.s $@.x
	$(CUBAS) $(STDLIB_FLAGS) -o $@ $@.s

$(OBJ_DIR)/%.o: %.cpp
	@echo '['$<']'
	$(PROFILE) $(CCC) $(CCC_FLAGS) -c -o $@ $(SOURCE_DIR)$<

$(OBJ_DIR)/%.m: %.cpp
	@echo Cube '['$<']' objdir $(OBJ_DIR)
	$(PROFILE) $(CCC) -S $(CCC_FLAGS) -c -o $@.x $(SOURCE_DIR)$<
	$(CPP) $(CCC_FLAGS)  -x assembler-with-cpp -c -o $@.s $@.x
	$(CUBAS) -o $@ $@.s

$(OBJ_DIR)/%_ph.h: %.h
	@echo C2PH '['$<']'
	$(C2PH) -I"$(ALL_INCLUDES)" -D"$(ALL_DEFINES)" $< > $@

%.beauty:
	$(BEAUTY) $*

##########################################################################
# Rules to create headers from .hpp files

# We will use _priv.h file as the derived object for timestamp purposes
HPP = $(MODULE_HPPS)
HPP_H = $(HPP:%.hpp=%.h)
HPP_D = $(HPP:%.hpp=%.d)

# The following fixes the problem when 'make comp all' is issued,
# and _info.c is not produced before SRC_FILES is expended
HPP_INFOC := $(HPP:%.hpp=%_info.c)
ifeq ($(LANGUAGE), cplusplus)
    HPP_INFOC := $(HPP_INFOC:%.c=%.cpp)
endif
HPP_INFOC_OBJS = $(HPP:%.hpp=%_info.o)
# Generate cwUnit class info .c file
ifeq ($(findstring cwunit,$(LIBRARY)), cwunit)
HPP_CWUNITC = $(HPP:%.hpp=%_infoCwUnit.c)
HPP_CWUNITC_OBJS = $(HPP:%.hpp=%_infoCwUnit.m)
endif
HPP_PRIVH = $(HPP:%.hpp=%_priv.h)
HPP_PUBLICH = $(addprefix $(ROOT)/include/cware/$(target)/, $(HPP_H))
HPP_PUBLICD = $(addprefix $(OBJ_DIR)/, $(HPP_D))
ITOOL_DIR = $(UTILS_BIN)

# We include the dependency file for the _priv.h that might already exist
# This include contains dependencies for the _priv.h on not only the .hpp
# file but all parent .hpp files as well
ifneq "$(strip $(HPP))" ""
-include $(HPP_PUBLICD)
endif

# Add the class_info.c and _infoCwUnit.c to the list of object files
OBJ_FILES += $(addprefix $(OBJ_DIR)/, $(HPP_INFOC_OBJS) $(HPP_CWUNITC_OBJS))

# rule to build .h from .hpp
# Note that we must rename _info.c source file .cpp in the case of C++
$(ROOT)/include/cware/$(target)/%.h: %.hpp
	@echo '['$<']'
	$(ITOOL) $(ITOOL_DIR) $(INCLUDE_DIR) $(OBJ_DIR) -I$(HPP_INCLUDE_DIR) $(MODULE_DEFINES) $(TARGET_HPP_DEFINES) --cpu=$(cpu) -nc $<
	$(PERL) $(UTILS_COMMON_BIN)/tools/post_itool.pl $(ROOT) $(<:%.hpp=%)
ifeq ($(findstring cwunit,$(LIBRARY)), cwunit)
	$(CWUNITGEN) $< $(INCLUDE_DIR)
	$(CWUNITLIST) add $(basename $<) $(ROOT)/src/unit_test/cwUnitExe/cwUnitList.c $(ROOT)/include/cware/cwproducts.h $(ROOT)/include/cware/cwplatformdef.h $(ROOT)/src/cware/include/cwUnit_requirements.h
endif
ifeq ($(LANGUAGE), cplusplus)
	$(MV) $(subst .hpp,_info.c,$<) $(subst .hpp,_info.cpp,$<)
endif

# recurse through same directories for components as builds    $(TARGET_DEFINES)
ifeq "$(HOST_TYPE)" "Linux"
     SUBDIRS := $(subst \,/,$(SUBDIRS))
endif
ifneq "$(norecurse)" ""
SUBDIRS_COMPONENT =
SUBDIR_COMPONENT =
else
SUBDIRS_COMPONENT = $(SUBDIRS:%=%.component)
SUBDIR_COMPONENT = $(subst .component,, $@)
endif

.PHONY: $(SUBDIRS_COMPONENT)
ifneq "$(strip $(SUBDIRS_COMPONENT))" ""
$(SUBDIRS_COMPONENT):
	$(MAKE) -C $(SUBDIR_COMPONENT) comp
endif

# Global components rule uses the public .h file as the timestamp
.PHONY: comp

ifneq "$(NOCOMP)" "yes"
ifeq (0,$(MAKELEVEL))
    comp: precomp
endif
ifdef RELEASE
ifeq (1,$(MAKELEVEL))
    comp: precomp
endif
endif
comp: $(HPP_PUBLICH) $(MCCABE_COMP) $(SUBDIRS_COMPONENT)
endif    # NOCOMP

ifneq "$(norecurse)" ""
SUBDIRS_PRECOMP =
SUBDIR_PRECOMP =
else
SUBDIRS_PRECOMP = $(SUBDIRS:%=%.precomp)
SUBDIR_PRECOMP = $(subst .precomp,, $@)
endif

.PHONY: $(SUBDIRS_PRECOMP)
ifneq "$(strip $(SUBDIRS_PRECOMP))" ""
$(SUBDIRS_PRECOMP):
	$(MAKE) -C $(SUBDIR_PRECOMP) precomp
endif

.PHONY: precomp
ifneq "$(NOCOMP)" "yes"
precomp: PREBUILD $(SUBDIRS_PRECOMP) $(addprefix $(HPP_INCLUDE_DIR)/,$(MODULE_HPPS) $(CMPFACTORY_MK_FILES))
endif     # NOCOMP

$(HPP_INCLUDE_DIR)/%.hpp: %.hpp
	$(RM) $(HPP_INCLUDE_DIR)/$?
	-$(CP) $? $(HPP_INCLUDE_DIR)

$(HPP_INCLUDE_DIR)/cmpfactory_%.mk: cmpfactory_%.mk
	$(RM) $(HPP_INCLUDE_DIR)/$?
	-$(CP) $? $(HPP_INCLUDE_DIR)

# run lint
ifneq "$(norecurse)" ""
SUBDIRS_LINT =
SUBDIR_LINT =
else
SUBDIRS_LINT = $(SUBDIRS:%=%.lint)
SUBDIR_LINT = $(subst .lint,, $@)
endif

.PHONY: $(SUBDIRS_LINT)
ifneq "$(strip $(SUBDIRS_LINT))" ""
$(SUBDIRS_LINT):
	$(MAKE) -C $(SUBDIR_LINT) lint
endif

.PHONY: lint
lint: $(SUBDIRS_LINT) splint

#end lint

.PHONY: splint
splint:
	@echo Running SPLINT 3.1.1
	-$(SPLINT) $(wildcard *.c) -larchpath $(SPLINT_ARCHPATH) $(SPLINT_PARAM)

# The overlay name is the basename of component.hpp.  Note that there should
# be a single hpp file per directory.  Just in case we use the first word
# in the MODULE_HPPS string and remove the .hpp
OVERLAY_NAME = $(basename $(word 1, $(MODULE_HPPS)))

# We make an overlay if there is one or more HPP in the directory and valid
# MODULE_OBJS
ifneq "$(OVERLAY_NAME)" ""
ifneq "$(filter-out ' ', $(MODULE_OBJS))" ""
MAKE_OVERLAY = 1
endif
endif


###############################################################################

#-------------------------------------------------------------------------
# Rules to create mccabe instrumented library.
# A separate mccabe directory and .pcf is created for each subdirectory.
#
# PRE-REQUISITE: - Install McCabe to local windows machine.
#		 - Add McCabe bin to the PATH
#			eg. PATH = $PATH C:\Program Files\McCabe\8.0\bin
# USAGE: make clean comp all mccabe=1
#	 or, make clean mccabe=1; make comp mccabe=1; make all mccabe=1
#    Always run "make clean mccabe=1" before next "make comp all mccabe=1"
#
#    You can turn off the instrumentation step by setting 'noinst'
#        make clean comp all mccabe=1 noinst=1
#    This allows you to use the McCabe Battlemap to evaluate static metrics
#    but since it skips the instrumentation step, you will not get instrumented
#    code that you can run on the target and do coverage analysis on. Objects
#    will be build as normal.
#
#    You can specify the directory used for intermediate files by setting
#    'mccabedir'
#        make clean comp all mccabe=1 mccabedir=myMcabeDir
#    If you do not set this variable the default dir './mccabe' will be
#    used.
#
# CAUTION: Preferably call it from the subdir which you want to instrument.
#	Creating instrumented files is a CPU intesive process and also
#	running too many instrumented files on the target might change system
#	timings significantly. Therefore, avoid calling it from top level dir.
#-------------------------------------------------------------------------

MCCABE_CLI = cli
MCCABE_GENPCF_SCRIPT = $(UTILS_BIN)/mccabeGenPcf.pl

# Directories
MCCABE_PREP_DIR = $(MCCABE_PROJ_DIR)/prep
MCCABE_INST_DIR = $(MCCABE_PROJ_DIR)/inst
CUR_DIR = $(strip $(shell pwd))

MODULE_NAME = $(basename $(notdir $(MODULE_OUT)))

# McCabe needs preprocess files to generate instrumented files.
PREPROCESSED_FILES = $(notdir $(SRC_FILES))

# To compile the mccabe instrumented src files, get modified object filenames.
MCCABE_MODULE_OBJS = $(MODULE_OBJS) $(MODULE_NAME)_instlib.o $(MODULE_NAME)_instplus.o
MCCABE_OBJ_FILES := $(addprefix $(OBJ_DIR)/, $(MCCABE_MODULE_OBJS))

# Limit mccabe specific changes in global variables to mccabe only...
ifdef MCCABE_BUILD
    # McCabe instrumentation and compile the instrumented files.
    MODULE_OBJS := $(MCCABE_MODULE_OBJS) $(HPP_INFOC_OBJS)
    OBJ_FILES = $(MCCABE_OBJ_FILES) $(addprefix $(OBJ_DIR)/, $(HPP_INFOC_OBJS))

    # McCabe generated _instlib.c and _instplus.cpp have many unused variables
    # and leads to many warnings. To successfully compile it, let us avoid
    # considering warnings as errors.
    TARGET_DEFINES := $(subst -Werror,,$(TARGET_DEFINES))
    CFLAGS := $(subst -Wall,,$(CFLAGS)) -DVxWorks
endif

#-------------------------------------------------------------------------
# Rules for build_mccabe
#-------------------------------------------------------------------------

.PHONY: $(MCCABE_BUILD)	$(MCCABE_COMP) mccabe_mkdirs mccabe_generate_pcf mccabe_instrument_files

# Rule for the 'comp' build stage
$(MCCABE_COMP): mccabe_mkdirs mccabe_generate_pcf

# Rule for the 'all' build stage
$(MCCABE_BUILD) : mccabe_instrument_files

# Make directories for McCabe derived files
mccabe_mkdirs:
	-@$(MKDIR) $(MCCABE_PROJ_DIR)
	-@$(MKDIR) $(MCCABE_PREP_DIR)
	-@$(MKDIR) $(MCCABE_INST_DIR)

# Do McCabe processing (instrumentation).
# There are a couple of tricks here: First, instrumentation will generate
# either *_inslib.c or *_instplus.cpp depending on whether C or C++ is
# being used instrumented. At this stage it is difficult to tell which one.
# So we just put both objects into the dependency list and make two empty
# such files prior to instrumentation. During instrumentation, one will
# be overwritten. During compilation using the special rules below, both
# will be compiled, the empty one harmlessly. Since we don't have access
# to 'touch', the empty files are created by echoing a single ';' into a
# new file.
# The second trick has to do with the _info file. When building McCabe,
# the object dependencies are changed to depend on the source files in
# the inst directory. But the _info file created by itool is placed
# in the current directory where it won't be found by the object deps.
# So the simple trick is to just copy it into the inst dir so the
# dependency rule can find it. Directories with pure C++ won't have an
# _info file so we must ignore errors with the '-'
mccabe_instrument_files:
	@echo '['MCCABE: Instrumenting preprocessed files...']'
	@echo ; > $(MCCABE_INST_DIR)/$(MODULE_NAME)_instlib.c
	@echo ; > $(MCCABE_INST_DIR)/$(MODULE_NAME)_instplus.cpp
	-@$(CP) $(HPP_INFOC) $(MCCABE_INST_DIR)
	@cd $(MCCABE_PROJ_DIR) & $(MCCABE_CLI) export -pcf "$(CUR_DIR)/$(MCCABE_PROJ_DIR)/$(MODULE_NAME).pcf"

# Generate the PCF file that drives McCabe processing
mccabe_generate_pcf: $(addprefix $(MCCABE_PREP_DIR)/, $(PREPROCESSED_FILES))
	@echo '['MCCABE: Generating .pcf file...']'
	perl $(MCCABE_GENPCF_SCRIPT) $(MODULE_NAME) $(CUR_DIR) $(MCCABE_PROJ_DIR) $(MCCABE_PREP_DIR) $(MCCABE_INST_DIR) "$(PREPROCESSED_FILES)"

# Rules to make preprocessed files
$(MCCABE_PREP_DIR)/%.c: %.c
	@echo '['MCCABE: Preprocessing file $<']'
	$(CC) $(CFLAGS) -E -o $@ $<

$(MCCABE_PREP_DIR)/%.cpp: %.cpp
	@echo '['MCCABE: Preprocessing file $<']'
	$(CCC) $(CCC_FLAGS) -E -o $@ $<

# Rules for special McCabe derived instrumentation library files
$(OBJ_DIR)/$(MODULE_NAME)_instlib.o: $(MCCABE_INST_DIR)/$(MODULE_NAME)_instlib.c
	@echo '['$<']'
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJ_DIR)/$(MODULE_NAME)_instplus.o: $(MCCABE_INST_DIR)/$(MODULE_NAME)_instplus.cpp
	@echo '['$<']'
	$(CCC) $(CCC_FLAGS) -c -o $@ $<

##########################################################################

#-------------------------------------------------------------------------
# Default build rule.
# This rule just prints usage info.
#-------------------------------------------------------------------------
.PHONY:	default
default:
	@echo Build goal not specified!
	@echo Usage: make '<'goal'>' '['target='<'platform'>'']' '['kernel='<'project'>'']' '['build='<'type'>'']'
	@echo \t'<'goal'>': bootrom, cware or application name
	@echo \t'<'platform'>': athena1, athena2, etc.
	@echo \t'<'kernel'>': dev0, dev1, prd0, etc.
	@echo \t'<'build'>': ram, rom, cmp or res
	@echo Defaults:
	@echo \ttarget=$(target)
	@echo \tkernel=$(kernel)
	@echo \tbuild=$(build)


#-------------------------------------------------------------------------
# Rule for building a DLL application module.
#-------------------------------------------------------------------------
ifneq "$(NOCOMP)" "yes"
$(MODULE_DLL_OUT):
	$(MKDIR) $(DLL_DIR)
	$(LD) $(LDFLAGS_PARTIAL) $(TARGET_LDFLAGS) $(MODULE_LDFLAGS) $(OBJ_SUB_FILES) $(PREBUILT_OBJ_FILES) -o $@
endif    # NOCOMP

ifneq "$(NOCOMP)" "yes"
$(MODULE_SYS_DLL_OUT):
	$(MKDIR) $(SYS_DLL_DIR)
	$(LD) $(LDFLAGS_PARTIAL) $(TARGET_LDFLAGS) $(MODULE_LDFLAGS) $(OBJ_SUB_FILES) $(PREBUILT_OBJ_FILES) -o $@
endif    # NOCOMP

#-------------------------------------------------------------------------
# Rule for building a stand-alone application module.
#-------------------------------------------------------------------------
ifneq "$(NOCOMP)" "yes"
$(MODULE_OUT): PREBUILD $(MCCABE_BUILD) $(DEP_FILE) $(OBJ_FILES)
ifeq "$(norecurse)" ""
$(MODULE_OUT): $(SUBDIRS)
endif
$(MODULE_OUT):
	$(LD) $(LDFLAGS_PARTIAL) $(TARGET_LDFLAGS) $(MODULE_LDFLAGS) $(OBJ_FILES) $(PREBUILT_OBJ_FILES) --start-group $(addprefix -l,$(CUSTOMER_LIB) $(MODULE_LIBS)) $(CW_LIBS) --end-group -o $@ -Map $(MODULE_MAP)

endif    # NOCOMP



#-------------------------------------------------------------------------
# Rule for building a stand-alone application module and 'munching' its symbols
# Munching is to resolve C++ static constructors
# This rule also uses version 2.95.2 of GCC to link code which uses C++ namespace
#-------------------------------------------------------------------------
ifneq "$(norecurse)" ""
$(MODULE_MUNCH_OUT): PREBUILD $(MCCABE_BUILD) $(DEP_FILE) $(OBJ_FILES)
else
$(MODULE_MUNCH_OUT): PREBUILD $(MCCABE_BUILD) $(DEP_FILE) $(OBJ_FILES) $(SUBDIRS)
endif
	$(LD2952) $(LDFLAGS_PARTIAL) $(TARGET_LDFLAGS) $(OBJ_FILES) $(PREBUILT_OBJ_FILES) --start-group $(addprefix -l,$(CUSTOMER_LIB) $(MODULE_LIBS)) $(CW_LIBS) --end-group -o $(MODULE_OUT) -Map $(MODULE_MAP)
	@echo "Get symbols from .out..."
	$(NM) $(MODULE_OUT) > symbollist.txt
	@echo "Munching symbols..."
	$(WTXTCL) $(TCL) < symbollist.txt > ctdt.c
	ifeq "$(cpu)" "mips"
	    $(error Please verify that /utils/tools/fix_static_const.pl correctly processes MIPS assembly before removing this message)
	    false
	endif
	perl $(ROOT)/utils/tools/fix_static_const.pl ctdt.c lsictdt.S
	@echo "Compiling munch output file..."
	$(AS) $(CFLAGS) -c -o ctdt.o ctdt.c
	$(AS) $(CFLAGS) -c -o lsictdt.o lsictdt.S
	$(CP) $(MODULE_OUT) tmp.out
	@echo "Relinking..."
	$(LD2952) -X -r tmp.out ctdt.o lsictdt.o -o $@
	@echo "cleanup..."
	$(RM) ctdt.o ctdt.c tmp.out symbollist.txt lsictdt.o lsictdt.S
	@echo "Application is ready to be launched"

#-------------------------------------------------------------------------
# Rules for building a library.
#-------------------------------------------------------------------------

ifneq "$(NOCOMP)" "yes"
ifneq "$(norecurse)" ""
$(LIBRARY_OUT): PREBUILD $(MCCABE_BUILD) $(C2PH_INCLUDES) $(DEP_FILE) $(OBJ_FILES)
else
$(LIBRARY_OUT): PREBUILD $(MCCABE_BUILD) $(SUBDIRS) $(C2PH_INCLUDES) $(DEP_FILE) $(OBJ_FILES)
endif
ifneq "$(MAKE_OVERLAY)" ""
$(LIBRARY_OUT): $(OBJ_DIR)/$(notdir $(OVERLAY_NAME)).so
endif

$(LIBRARY_OUT):
ifndef LIBRARY
	@echo Error: Not a library!
	@false
endif

ifeq ($(parallel),1)

ifneq "$(MAKE_OVERLAY)" ""
	@echo "$@ $(OBJ_DIR)/$(notdir $(OVERLAY_NAME)).so" >> /vobs/cware/utils/tools/parallel/arList/$(PACKAGES)ArList
	@echo "$@ $(addprefix $(OBJ_DIR)/, $(HPP_INFOC_OBJS) $(HPP_CWUNITC_OBJS))" >> /vobs/cware/utils/tools/parallel/arList/$(PACKAGES)ArList
else
	@echo "$@ $(OBJ_FILES)" >> /vobs/cware/utils/tools/parallel/arList/$(PACKAGES)ArList
endif

else    # else not parallel cware build

ifneq "$(MAKE_OVERLAY)" ""
	$(AR) rucs $@ $(OBJ_DIR)/$(notdir $(OVERLAY_NAME)).so
	$(AR) rucs $@ $(addprefix $(OBJ_DIR)/, $(HPP_INFOC_OBJS) $(HPP_CWUNITC_OBJS))
else
	$(AR) rucs $@ $(OBJ_FILES)
endif
endif   # end of else not parallel cware build

ifneq "$(MAKE_OVERLAY)" ""
$(OBJ_DIR)/$(notdir $(OVERLAY_NAME)).so: $(addprefix $(OBJ_DIR)/, $(MODULE_OBJS))
	$(LD) $(LDFLAGS_MAKESO) $^ -o $@
endif # MAKE_OVERLAY

endif    # NOCOMP

#-------------------------------------------------------------------------
# Rule for building a library architecture dependent, eg e5 or e5.1
#-------------------------------------------------------------------------
ifneq "$(norecurse)" ""
$(LIB_ARCH_OUT): PREBUILD $(LIB_ARCH_DIR) $(C2PH_INCLUDES) $(DEP_FILE) $(OBJ_FILES)
else
$(LIB_ARCH_OUT): PREBUILD $(LIB_ARCH_DIR) $(SUBDIRS) $(C2PH_INCLUDES) $(DEP_FILE) $(OBJ_FILES)
endif
ifndef LIBRARY
	@echo Error: Not a library!
	@false
endif

#-------------------------------------------------------------------------
# Bit-access-instruction-dependent build
#-------------------------------------------------------------------------
ifneq "$(norecurse)" ""
$(LIB_BITACCESS_OUT): PREBUILD $(LIB_BITACCESS_DIR) $(C2PH_INCLUDES) $(DEP_FILE) $(OBJ_FILES)
else
$(LIB_BITACCESS_OUT): PREBUILD $(LIB_BITACCESS_DIR) $(SUBDIRS) $(C2PH_INCLUDES) $(DEP_FILE) $(OBJ_FILES)
endif
ifndef LIBRARY
	@echo Error: Not a library!
	@false
endif

ifeq ($(parallel),1)

ifneq "$(MAKE_OVERLAY)" ""
	$(LD) $(LDFLAGS_MAKESO) $(addprefix $(OBJ_DIR)/, $(MODULE_OBJS)) -o $(OBJ_DIR)/$(notdir $(MODULE)).so
	@echo "$@ $(OBJ_DIR)/$(notdir $(MODULE)).so" >> /vobs/cware/utils/tools/parallel/arList/$(PACKAGES)ArList
	@echo "$@ $(addprefix $(OBJ_DIR)/, $(HPP_INFOC_OBJS))" >> /vobs/cware/utils/tools/parallel/arList/$(PACKAGES)ArList
else
	@echo "$@ $(OBJ_FILES)" >> /vobs/cware/utils/tools/parallel/arList/$(PACKAGES)ArList
endif

else    # else not parallel cware build

ifneq "$(MAKE_OVERLAY)" ""
	$(LD) $(LDFLAGS_MAKESO) $(addprefix $(OBJ_DIR)/, $(MODULE_OBJS)) -o $(OBJ_DIR)/$(notdir $(OVERLAY_NAME)).so
	$(AR) rucs $@ $(OBJ_DIR)/$(notdir $(OVERLAY_NAME)).so
	$(AR) rucs $@ $(addprefix $(OBJ_DIR)/, $(HPP_INFOC_OBJS) $(HPP_CWUNITC_OBJS)) $(addprefix $(OBJ_DIR)/, $(HPP_CWUNITC_OBJS))
else
	$(AR) rucs $@ $(OBJ_FILES)
endif

endif   # end of else not parallel cware build

#-------------------------------------------------------------------------
# Rule for building the exported list of libs
#-------------------------------------------------------------------------

$(EXTLIBS_OUT):	$(PLATFORM_DIR)
	@perl $(UTILS_COMMON_BIN)/tools/makeExtLib.pl \
         "$(ALL_LIBS)" \
         "$(filter-out -X -r, $(subst $(ROOT),,$(LDFLAGS_COMPLETE)))" \
         "$(EXTLIBS_MK)"
	@perl $(UTILS_COMMON_BIN)/tools/cwstripm.pl $(EXTLIBS_MK)

#-------------------------------------------------------------------------
# run component factory script
#-------------------------------------------------------------------------
.PHONY:	CMPFACTORY
CMPFACTORY:
	@echo 'Creating Component Factory file...'
	$(MKCMPFACTORY) $(PLATFORM) $(HPP_INCLUDE_DIR) $(ROOT) $(WIND_HOST_TYPE) $(SRC_DIR)/CCmpFactory.c

#-------------------------------------------------------------------------
# Rule for building a platform library.
#-------------------------------------------------------------------------
ifneq "$(norecurse)" ""
$(PLATFORM_OUT): PREBUILD CMPFACTORY $(PLATFORM_DIR) $(DEP_FILE) $(OBJ_FILES)
else
$(PLATFORM_OUT): PREBUILD CMPFACTORY $(PLATFORM_DIR) $(DEP_FILE) $(SUBDIRS) $(OBJ_FILES)
endif

ifndef PLATFORM
	@echo Error: Platform not defined !
	@false
endif

ifeq ($(parallel),1)
	@echo "$@ $(OBJ_FILES)" >> /vobs/cware/utils/tools/parallel/arList/$(PACKAGES)ArList
else    # else not parallel cware build
	$(AR) rucs $@ $(OBJ_FILES)
endif   # end of else not parallel cware build

ifeq ($(parallel),1)
	@echo "$@ $(OBJ_FILES)" >> /vobs/cware/utils/tools/parallel/arList/$(PACKAGES)ArList
else    # else not parallel cware build
	$(AR) rucs $@ $(OBJ_FILES)
endif   # end of else not parallel cware build

#-------------------------------------------------------------------------
# Rule for building overlays
#-------------------------------------------------------------------------
.PHONY: CWareOverlays
CWareOverlays:
ifndef PLATFORM
	@echo Error: Platform not defined !
	@false
endif
	-mkdir -p $(PLATFORM_OBJ_DIR)
	$(CC) $(CFLAGS) -c -o $(LINKALL_OBJ) $(LINKALL_C)
	$(LD) $(LDFLAGS_PARTIAL) --verbose $(LINKALL_OBJ) --start-group $(ALL_LIBS) --end-group -o $(LINKALL_COMPLETE_OBJ) > $(LINKALL_VERBOSE)
	$(MAKEOVERLAYS) -vf $(LINKALL_VERBOSE) $(PLATFORM_OVERLAY_CFG) -v -o $(PLATFORM_DIR)

#-------------------------------------------------------------------------
# Rule for binary rom_compressed with overlay support
#-------------------------------------------------------------------------
.PHONY: AppWithPrebuiltOverlays
AppWithPrebuiltOverlays: $(MODULE_OUT)
	@echo ">>>"
	@echo "Building ELF compressed overlay image $(MODULE_NAME).ovl.bin"
	@echo "<<<"
	perl $(ROOT)/utils/overlays/overlay.pl \
		-co \
		-keep \
		-m=$(ROOT)/targets/platforms/$(PLATFORM)/standalone.cfg \
		-ep=\"$(ENTRY_POINT)\" \
		-d$(ABS_ROOT) \
		-t$(target) \
		-p$(platform) \
		$(addprefix -i, $(OBJ_FILES)) \
		$(addprefix -i, $(PREBUILT_OBJ_FILES)) \
		-o$(MODULE_NAME).ovl.bin \
		-loverlays \
		-L$(PLATFORM_DIR) \
		$(EXTRA_OVERLAY_CONFIG)

AppWithOverlays: $(MODULE_OUT)
	$(LD) $(LDFLAGS_PARTIAL) -verbose $(TARGET_LDFLAGS) $(OBJ_FILES) $(PREBUILT_OBJ_FILES) --start-group $(ALL_LIBS) --end-group -o $@ -Map $(MODULE_MAP) > verboselink.txt
	$(RM) $@
	$(MAKEOVERLAYS) -vf verboselink.txt -vv $(PLATFORM_OVERLAY_CFG) $(APPLICATION_OVERLAY_CFG) -v -o .
	perl $(ROOT)/utils/overlays/overlay.pl \
		-co \
		-m=$(ROOT)/targets/platforms/$(PLATFORM)/standalone.cfg \
		-ep=\"$(ENTRY_POINT)\" \
		-d$(ABS_ROOT) \
		-t$(target) \
		-p$(platform) \
		-o$(MODULE_NAME).ovl.bin \
		$(addprefix -i, $(OBJ_FILES)) \
		$(addprefix -i, $(PREBUILT_OBJ_FILES)) \
		-loverlays \
		-L. \
		$(EXTRA_OVERLAY_CONFIG)


#		$(addprefix -i, $(OBJ_FILES)) \
#		$(addprefix -i, $(PREBUILT_OBJ_FILES)) \



#-------------------------------------------------------------------------
# Build dependancy rules
#-------------------------------------------------------------------------
$(DEP_FILE): $(filter-out $(HPP_INFOC),$(OBJ_SRC_FILES))
	@echo '['Building dependency rules']'
ifeq ($(parallel),1)
	-touch $(DEP_FILE)
	@echo '# This is a machine-generated file. Do not edit!' >> $(DEP_FILE)
else
	@echo '# This is a machine-generated file. Do not edit!' > $(DEP_FILE)
endif
ifneq "$(strip $(OBJ_SRC_FILES))" ""
	-$(CC) $(CBASEFLAGS) -I$(OBJ_DIR) -M $(OBJ_SRC_FILES) > $(TMP_FILE)
	-perl $(FIXDEP) $(OBJ_DIR) < $(TMP_FILE) >> $(DEP_FILE)
endif


#-------------------------------------------------------------------------
# Rule for general pre-build checking.
#-------------------------------------------------------------------------
.PHONY: PREBUILD
PREBUILD: $(BIN_DIR) $(OBJ_DIR) $(LIB_DIR) $(INCLUDE_DIR) $(HPP_INCLUDE_DIR)

#-------------------------------------------------------------------------
# Rules for creating output directories.
#-------------------------------------------------------------------------
$(BIN_DIR) $(LIB_DIR) $(OBJ_DIR) $(INCLUDE_DIR) $(HPP_INCLUDE_DIR) $(CUSTOMER_DIR) $(PLATFORM_DIR) $(LIB_ARCH_DIR) $(LIB_BITACCESS_DIR):
	-$(MKDIR) $@

##########################################################################

#-------------------------------------------------------------------------
# Rules for cleaning
#-------------------------------------------------------------------------

.PHONY: $(ALL_CLEAN)
$(ALL_CLEAN):
	$(MAKE) $(COMPAT) 'target=$@' clean

#-------------------------------------------------------------------------
# Include dependancy rules (must be last!).
#-------------------------------------------------------------------------

#DEPMK = $(strip $(shell ls -1 $(OBJ_DIR)/*.mk 2> nul))
DEPMK = $(strip $(shell perl $(LSFILES) $(OBJ_DIR) mk))
ifneq "$(DEPMK)" ""
    ifdef MODULE_OBJS
        ifneq (,$(filter-out clean print-%,$(MAKECMDGOALS)))
            -include $(DEP_FILE)
        endif
    endif
endif

# start of cware.mk
ifneq "$(norecurse)" ""
SUBDIR_CLEANS =
SUBDIR =
else
SUBDIR_CLEANS = $(SUBDIRS:%=%.clean)
SUBDIR = $(subst .clean,, $@)
endif

#-------------------------------------------------------------------------
# Recursive clean through all subdirs
#-------------------------------------------------------------------------
.PHONY: $(SUBDIR_CLEANS)
ifneq "$(strip $(SUBDIR_CLEANS))" ""
$(SUBDIR_CLEANS):
	$(MAKE) -C $(SUBDIR) clean
endif

#-------------------------------------------------------------------------
# Rules to build kernels
#-------------------------------------------------------------------------
PRJ_DIR = /cware/tornado/target/proj/$(proc)/$(prjfile)
D_PRJ_DIR = \cware\tornado\target\proj\$(proc)\$(prjfile)

PRJ_FILE = $(PRJ_DIR)/$(prjfile).wpj
PRJ_MAKE = $(PRJ_DIR)/Makefile
TEMP_PRJ_FILE = $(PRJ_DIR)/t_$(prjfile).wpj

MODULE_BIN_PATH = /cware/bin/$(target)/$(PLATFORM)
D_MODULE_BIN_PATH = \cware\bin\$(target)\$(PLATFORM)                                                  `
MODULE_NAME = $(basename $(notdir $(MODULE_OUT)))


# Build a kernel based on a project file.
# Note use use a modified version of the prj file in order
# to remove any hardcoded drive references
.PHONY: kernel
kernel:
	@echo "Building kernel $(proc)/$(prjfile).wpj"
	perl $(UTILS_BIN)/fixprj.pl $(PRJ_FILE) $(TEMP_PRJ_FILE)
	wtxtcl $(UTILS_BIN)/makeGen.tcl $(TEMP_PRJ_FILE)
	-$(MKDIR) $(D_PRJ_DIR)\Downloadable_Kernel
	$(MAKE) -C $(PRJ_DIR)/Downloadable_Kernel -f ../Makefile BUILD_SPEC=Downloadable_Kernel DEFAULT_RULE=vxWorks clean vxWorks
ifneq (,$(findstring SunOS,$(UNAME)))
	$(CP) $(PRJ_DIR)/Downloadable_Kernel/vxWorks /cware/lib/vxWorks.$(proc).$(prjfile)
else
	$(CP_DOS_ALT) $(D_PRJ_DIR)\Downloadable_Kernel\vxWorks \cware\libvxWorks.$(proc).$(prjfile)
endif
	$(RM) $(PRJ_MAKE)
	$(RM) $(TEMP_PRJ_FILE)

# Note: do not insert tabs in front of BSP_BUILD: this would break Tornado's make
ifneq "$(nomult)" "0"
BSP_BUILD = ROM_Compressed_nomult
else
BSP_BUILD = ROM_Compressed
endif

.PHONY: binkernel
binkernel:
	@echo "Building binary image and kernel $(proc)/$(prjfile).wpj"
	perl $(UTILS_BIN)/fixprj.pl $(PRJ_FILE) $(TEMP_PRJ_FILE)
	wtxtcl $(UTILS_BIN)/makeGen.tcl $(TEMP_PRJ_FILE)
	-$(MKDIR) $(D_PRJ_DIR)\$(BSP_BUILD)
	$(MAKE) -C $(PRJ_DIR)/$(BSP_BUILD) -f ../Makefile BUILD_SPEC=$(BSP_BUILD) DEFAULT_RULE=vxWorks_romCompress clean vxWorks_romCompress
ifneq (,$(findstring SunOS,$(UNAME)))
	$(CP) $(PRJ_DIR)/$(BSP_BUILD)/vxWorks /cware/lib/vxWorks.$(proc).$(prjfile)
	$(CP) $(PRJ_DIR)/$(BSP_BUILD)/vxWorks.bin /cware/lib/vxWorks.$(proc).$(prjfile).bin
else
	$(CP_DOS_ALT) $(D_PRJ_DIR)\$(BSP_BUILD)\vxWorks \cware\libvxWorks.$(proc).$(prjfile)
	$(CP_DOS_ALT) $(D_PRJ_DIR)\$(BSP_BUILD)\vxWorks.bin \cware\lib\vxWorks.$(proc).$(prjfile).bin
endif
	$(RM) $(PRJ_MAKE)
	$(RM) $(TEMP_PRJ_FILE)


.PHONY: compressed
compressed: $(MODULE_OUT)
	@echo ">>>"
	@echo "Building compressed image $(MODULE_NAME).$(proc).$(prjfile)"
	@echo "<<<"
	perl $(UTILS_BIN)/fixprj.pl $(PRJ_FILE) $(TEMP_PRJ_FILE)
	wtxtcl $(UTILS_BIN)/makeGen.tcl $(TEMP_PRJ_FILE)
	-$(MKDIR) $(D_PRJ_DIR)\$(BSP_BUILD)
	$(MAKE) -C $(PRJ_DIR)/$(BSP_BUILD) -f ../Makefile \
	BUILD_SPEC=$(BSP_BUILD) vxWorks_romCompress \
	EXTRA_MODULES="$(addprefix $(MODULE_BIN_PATH)/, $(notdir $(MODULE_OUT)))" \
	USER_APPL_INIT="-DUSER_APPL_INIT=CWareInit()" \
	DEFAULT_RULE=vxWorks_romCompress
ifneq (,$(findstring SunOS,$(UNAME)))
	$(CP) $(PRJ_DIR)/$(BSP_BUILD)/vxWorks $(MODULE_BIN_PATH)/$(MODULE_NAME).$(proc).$(prjfile)
	$(CP) $(PRJ_DIR)/$(BSP_BUILD)/vxWorks.bin $(MODULE_BIN_PATH)/$(MODULE_NAME).$(proc).$(prjfile).bin
else
	$(CP_DOS_ALT) $(D_PRJ_DIR)\$(BSP_BUILD)\vxWorks $(D_MODULE_BIN_PATH)\$(MODULE_NAME).$(proc).$(prjfile)
	$(CP_DOS_ALT) $(D_PRJ_DIR)\$(BSP_BUILD)\vxWorks.bin $(D_MODULE_BIN_PATH)\$(MODULE_NAME).$(proc).$(prjfile).bin
endif
	$(RM) $(PRJ_MAKE)
	$(RM) $(TEMP_PRJ_FILE)


# Build standalone compressed ELF image with overlay support

.PHONY: mini
ABS_ROOT = $(word 1, $(subst /src/, ,$(shell pwd)))
mini: $(MODULE_OUT)
	@echo ">>>"
	@echo "Building ELF compressed overlay image $(MODULE_NAME).mini.bin"
	@echo "<<<"
	perl $(ROOT)/utils/overlays/overlay.pl \
		-co \
		-keep \
		-m=$(ROOT)/targets/platforms/$(PLATFORM)/standalone.cfg \
		-d$(ABS_ROOT) \
		-t$(target) \
		-p$(platform) \
		$(addprefix -i, $(OBJ_FILES)) \
		$(addprefix -i, $(PREBUILT_OBJ_FILES)) \
		-o$(MODULE_NAME).mini.bin \
		$(ALL_LIBS) \
		-L$(LIB_DIR) \
		-L$(LIB_DIR)/$(ARCHLIB) \
		-L$(LIB_DIR)/$(BITINSTR) \
		-L$(CUSTOMER_DIR) \
		-L$(PLATFORM_DIR) \
		-L$(PREBUILT_LIB_DIR_TARGET) \
		-L$(PREBUILT_LIB_DIR_COMMON) \
		-L$(FW_LIB) \
		$(EXTRA_OVERLAY_CONFIG)


###############################################################################
# standby
#
# Generate a located binary of the standby module for the given platform
#
# Fix me: If SunOS, exit or fix everything so it builds too
#	perl $(UTILS_COMMON_BIN)/tools/makeStandby.pl \
.PHONY: standby
standby:
	@echo ">>>"
	@echo "Building standby module platform.standby"
	@echo "<<<"
	-mkdir -p $(PLATSTBY_OBJ_DIR)
#	$(MKSTANDBY) \
#		-p=$(PLATFORM) \
#		-g=$(target) \
#		-d=$(DMN_COMMON) \
#		-c=$(ROOT)/src/standby/src/core \
#		-o=$(ROOT)/obj/$(target)$(cpusuffix)/standby/src/core \
#		-b=$(PLATSTBY_OBJ_DIR) \
#		-t=$(TOOLS_BIN) \
#		-r=$(ROOT) \
#		-h=$(WIND_HOST_TYPE) \
#		-m=$(nomult) \
#		-x=$(CP)

###############################################################################
# standalone
#
# Generate a located binary of the standby module for the given platform
#
# Fix me: If SunOS, exit or fix everything so it builds too
#	perl $(UTILS_BIN)/standalone.pl \
.PHONY: standalone
standalone: $(BIN_DIR)
	@echo ">>>"
	@echo "Building standalone image"
	@echo "build" $(MKSTANDALONE) $(PLATFORM) $(image) $(target) $(PROJECT_VER)
	@echo "<<<"
	-mkdir -p $(STANDALONE_BAL_OBJ_DIR)
	-mkdir -p $(STANDALONE_CONS_OBJ_DIR)
	$(MKSTANDALONE) $(PLATFORM) $(image) $(target) $(PROJECT_VER)

#-------------------------------------------------------------------------
# Rules to build individual .o's from libcware.a
#-------------------------------------------------------------------------
.PHONY: cwimage
cwimage:
	perl $(UTILS_BIN)/cwimage.pl target=$(target) proc=$(KERNEL_PROC) prjfile=$(KERNEL_PRJFILE) unittest=$(CWIMAGE_UNITTEST) romtext=$(CWARE_ROM_TEXT) romdata=$(CWARE_ROM_DATA)



#-------------------------------------------------------------------------
# Default clean for cware directories
#-------------------------------------------------------------------------

.PHONY: clean-objs
ifneq "$(NOCOMP)" "yes"
clean-objs: $(SUBDIR_CLEANS)
ifeq ($(mccabe), 1)
	@echo **** MCCABE: cleaning files...
	$(RM) mclog.*
	$(RMRECURSE) "$(MCCABE_PROJ_DIR)"
endif
ifneq "$(strip $(SRC_FILES))" ""
	$(RM) $(OBJ_FILES) $(GEN_SRC_FILES)
endif
	$(RM) $(DEP_FILE)
	$(RM) $(TMP_FILE)
	$(RM) $(C2PH_INCLUDES)
ifneq "$(strip $(HPP))" ""
	$(RM) $(HPP_PRIVH) $(HPP_PUBLICH)
	$(RM) $(addprefix $(HPP_INCLUDE_DIR)/, $(MODULE_HPPS))
ifeq ($(findstring cwunit,$(LIBRARY)), cwunit)
	$(RM) $(HPP_CWUNITC)
endif
endif
ifneq "$(strip $(CMPFACTORY_MK_FILES))" ""
	$(RM) $(addprefix $(HPP_INCLUDE_DIR)/, $(CMPFACTORY_MK_FILES))
endif
	$(RM) $(INTERMEDIATE_FILES)
	$(RM) $(OBJ_DIR)/$(notdir $(OVERLAY_NAME)).so

endif    # NOCOMP

.PHONY: clean-platform
clean-platform:
	$(RM) $(EXTLIBS_MK)

.PHONY: clean-only-objs
clean-only-objs: $(SUBDIR_CLEANS)
ifneq "$(strip $(SRC_FILES))" ""
	$(RM) $(OBJ_FILES)
endif
	$(RM) $(DEP_FILE)
	$(RM) $(TMP_FILE)
	$(RM) $(C2PH_INCLUDES)

clean-bins:
	$(RM) $(MODULE_OUT)
	$(RM) $(MODULE_MAP)

clean-dll:
	$(RM) $(MODULE_DLL_OUT)

clean-sys-dll:
	$(RM) $(MODULE_SYS_DLL_OUT)

superclean:
	$(RMRECURSE) $(ROOT)/obj/$(target)
	$(RMRECURSE) $(ROOT)/lib/$(target)
	$(RMRECURSE) $(INCLUDE_DIR)
	$(RMRECURSE) $(HPP_INCLUDE_DIR)


#-------------------------------------------------------------------------
# Create dummy library with no IP or fuctionality
#-------------------------------------------------------------------------

dummylib:
	$(DUMMY_LIB_SCRIPT) $(DUMMY_LIB_DIR) $(ROOT)/include/cware/cwdefines.h $(DUMMY_LIBS)


#-------------------------------------------------------------------------
# Recursive make through all subdirs
#-------------------------------------------------------------------------
.PHONY: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ all

ifneq "$(norecurse)" ""
SUBDIR_CLIST =
SUBDIRCL =
else
SUBDIR_CLIST = $(SUBDIRS:%=%.clist)
SUBDIRCL = $(subst .clist,, $@)
endif

#-------------------------------------------------------------------------
# Recursive clean through all subdirs
#-------------------------------------------------------------------------
.PHONY: $(SUBDIR_CLIST)
ifneq "$(strip $(SUBDIR_CLIST))" ""
$(SUBDIR_CLIST):
	$(MAKE) -C $(SUBDIRCL) clist
endif


.PHONY: clist
clist: $(SUBDIR_CLIST)
	@echo Library: $(LIBRARY) 	Component: `pwd`


#-------------------------------------------------------------------------
# Rules for creating doxygen based documentation
#-------------------------------------------------------------------------

DOC_CFG_TEMPLATE = $(DOXY_UTILS_BIN)/doxy.template
DOC_CFG_MERGE = $(DOXY_UTILS_BIN)/doxy_use.cfg
DOC_CFG_FILE_CUSTOMER = $(DOXY_UTILS_BIN)/doxygen_customer.cfg
DOC_CFG_FILE_PRIVATE = $(DOXY_UTILS_BIN)/doxygen_private.cfg
DOC_INCLUDES_CUSTOMER = $(COMMON_INCLUDES) $(GENERATED_INCLUDES) $(BSP_INCLUDES)
DOC_INCLUDES_PRIVATE = $(COMMON_INCLUDES) $(CWARE_INCLUDES) $(BSP_INCLUDES)

.PHONY: alldocs
alldocs: alldocspub alldocspriv


.PHONY: alldocspub
alldocspub:
	@echo Building all documentation for $(target)
	-$(MKDIR) $(ROOT)/docs/$(target)
	-$(MKDIR) $(ROOT)/docs/$(target)/alldocs
	-$(MKDIR) $(ROOT)/docs/$(target)/alldocs/customer
	-$(MKDIR) $(ROOT)/docs/$(target)/alldocs/customer\html
	perl $(DOXY_UTILS_BIN)/dxCfgTarget.pl $(DOC_CFG_MERGE) $(target) $(ROOT) "$(DOC_INCLUDES_CUSTOMER)" "NO" $(groups)
	perl $(DOXY_UTILS_BIN)/dxCfgMerge.pl $(DOC_CFG_TEMPLATE) $(DOC_CFG_MERGE) $(DOC_CFG_FILE_CUSTOMER)
	$(DOXYGEN) $(DOC_CFG_FILE_CUSTOMER)


.PHONY: alldocspriv
alldocspriv:
	@echo Building all private documentation for $(target)
	-$(MKDIR) $(ROOT)/docs/$(target)
	-$(MKDIR) $(ROOT)/docs/$(target)/alldocs
	-$(MKDIR) $(ROOT)/docs/$(target)/alldocs/private
	-$(MKDIR) $(ROOT)/docs/$(target)/alldocs/private\html
	perl $(DOXY_UTILS_BIN)/dxCfgTarget.pl $(DOC_CFG_MERGE) $(target) $(ROOT) "$(DOC_INCLUDES_PRIVATE)" "YES" $(groups)
	perl $(DOXY_UTILS_BIN)/dxCfgMerge.pl $(DOC_CFG_TEMPLATE) $(DOC_CFG_MERGE) $(DOC_CFG_FILE_PRIVATE)
	$(DOXYGEN) $(DOC_CFG_FILE_PRIVATE)


.PHONY: docs
docs: docspub docspriv


.PHONY: docspub
docspub:
	@echo Building documentation for the current directory for target $(target)
	-$(MKDIR) $(ROOT)/docs/$(target)
	-$(MKDIR) $(ROOT)/docs/$(target)/docs
	-$(MKDIR) $(ROOT)/docs/$(target)/docs/customer
	-$(MKDIR) $(ROOT)/docs/$(target)/docs/customer\html
	perl $(DOXY_UTILS_BIN)/dxCfgDir.pl $(DOC_CFG_MERGE) $(target) $(ROOT) "$(ALL_INCLUDES)" "NO"
	perl $(DOXY_UTILS_BIN)/dxCfgMerge.pl $(DOC_CFG_TEMPLATE) $(DOC_CFG_MERGE) $(DOC_CFG_FILE_CUSTOMER)
	$(DOXYGEN) $(DOC_CFG_FILE_CUSTOMER)
	$(RM) $(DOXY_UTILS_BIN)/doxy_use.cfg


.PHONY: docspriv
docspriv:
	@echo Building private documentation for the current directory for target $(target)
	-$(MKDIR) $(ROOT)/docs/$(target)
	-$(MKDIR) $(ROOT)/docs/$(target)/docs
	-$(MKDIR) $(ROOT)/docs/$(target)/docs/private
	-$(MKDIR) $(ROOT)/docs/$(target)/docs/private\html
	perl $(DOXY_UTILS_BIN)/dxCfgDir.pl $(DOC_CFG_MERGE) $(target) $(ROOT) "$(ALL_INCLUDES)" "YES" "$(VPATH)"
	perl $(DOXY_UTILS_BIN)/dxCfgMerge.pl $(DOC_CFG_TEMPLATE) $(DOC_CFG_MERGE) $(DOC_CFG_FILE_PRIVATE)
	$(DOXYGEN) $(DOC_CFG_FILE_PRIVATE)
	$(RM) $(DOXY_UTILS_BIN)/doxy_use.cfg


#-------------------------------------------------------------------------
# Rules for adding a single object file to multiple platform libraries.
# These are useful for HAL-style global functions where some platforms
# share one implementation and other platforms share another implemtation.
#-------------------------------------------------------------------------

multiplatform = $($(MULTIPLATFORM_DIR))

MULTIPLATFORM_LIBDIRS = $(addprefix $(LIB_DIR)/platform/, $(filter-out $(PLATFORM),$(multiplatform)))

$(MULTIPLATFORM_LIBDIRS):
	-$(MKDIR) $@

.PHONY: $(multiplatform)

$(multiplatform): $(OBJ_FILES) $(MULTIPLATFORM_LIBDIRS)	$(PLATFORM_DIR)
ifeq ($(parallel),1)
	@echo "$(LIB_DIR)/platform/$@/libplatform.a $(OBJ_FILES)" >> /vobs/cware/utils/tools/parallel/arList/$(PACKAGES)ArList
else
	$(AR) rucs $(LIB_DIR)/platform/$@/libplatform.a $(OBJ_FILES)
endif   # end of else not parallel cware build

.PHONY: MULTIPLATFORM_LIB

ifneq "$(norecurse)" ""
MULTIPLATFORM_LIB: PREBUILD $(DEP_FILE) $(OBJ_FILES) $(multiplatform)
else
MULTIPLATFORM_LIB: PREBUILD $(DEP_FILE) $(SUBDIRS) $(OBJ_FILES) $(multiplatform)
endif

#-------------------------------------------------------------------------
# Rules source line counting
#-------------------------------------------------------------------------

SCLC_ARGS = -counts Cmnts+NCSL -ignore -name ".*\.(c|cpp|inl)" -except ".*_info\.(c|cpp)"

.PHONY: sclc

sclc:
ifneq "$(norecurse)" ""
	@$(SCLC) $(SCLC_ARGS) $(SRC_FILES)
else
	@$(SCLC) $(SCLC_ARGS) -recurse .
endif
