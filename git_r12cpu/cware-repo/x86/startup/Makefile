#================================================================
#  File Name: Makefile
#
#  Copyright 2015 Magnum Semiconductor Inc.  All rights reserved.
#
#  Description:
#
#  Makefile for dxHostAPI
#
#  Modification History:
#
#================================================================

MODULE := $(shell pwd | sed -e 's@\\@/@g' -e 's@.*/x86/@@')
ROOT := $(shell echo $(MODULE)/..| sed 's@[0-9a-zA-Z_]*/@../@g' )

#FWROOT should be defined in config.mk
include $(ROOT)/config.mk

ifndef FWROOT
$(error 'FWROOT' is not defined)
#    FWROOT = $(ROOT)/fw_release
endif

# licensing only in licensing=1 builds
ifeq ("$(licensing)", "1")
ifndef LICENSINGROOT
ifdef licensingroot
LICENSINGROOT := $(realpath $(licensingroot))
else
$(error 'LICENSINGROOT' or 'licensingroot' is not defined)
endif
endif
endif

# Workaround for FW_INC/FW_LLIB. Should get from cware/common.mk, but the $(ROOT) can't be gotten correctly
FW_INC = $(FWROOT)/r12c/x86/cware/inc/
FW_LIB = $(FWROOT)/r12c/x86/cware/lib/

# Comment/uncomment to enable/disable debugging code
#DEBUG=1

ifeq ($(DEBUG),1)
	DEBFLAGS = -g -O -DDEBUG
else
	DEBFLAGS = -g -O2
	CFLAGS += -fno-strict-aliasing
endif

CFLAGS += -DCPU=41 -DMIPSEL -DSW_CODEC -fno-builtin-printf
LFLAGS += -rdynamic

ifeq "$(cpu)" "x86_64"
	CFLAGS += -m64
	LFLAGS += -m64
else
	CFLAGS += -m32
	LFLAGS += -m32
endif

SRLINC = $(ROOT)/src/cware/core/D7/srl/
BSPINC = -I$(ROOT)/tornado/target/config/all/ -I$(ROOT)/tornado/target/config/d70/ -I$(ROOT)/tornado/target/config/dmnCommon/
#OS_INC = ../os_wrapper/h/
INCLUDES = -I../../include/cware/ -I../osal/ -I../bsp/include -I$(FW_INC) -I../os_wrapper/linux

# need also thread support for interrupt handling
LFLAGS += -I../../include -pthread -Wl,--no-as-needed -lrt -ldl
LFLAGS += -L../../lib/domino -L../../lib/domino/platform/cpu_intel_xeon -L$(FW_LIB) -L../

CFLAGS += $(DEBFLAGS) -Werror -Wall -fPIC -I../../include -I./ -g $(INCLUDES)
ADDITIONAL_LIBS +=  -lcware -lcwBsp -lplatform -lcware -lplatform -lcware -loswrapper -lm -lx86osal
ifeq "$(cpu)" "x86_64"
    # currently FW builds to libfw.a in both 32-bit and 64-bit builds
    # ADDITIONAL_LIBS += -lfw_64
    ADDITIONAL_LIBS += -lfw
else
    ADDITIONAL_LIBS += -lfw
endif
#-lProXCodeHostIFUtil

# add licensing includes and libs in licensing=1 builds
ifeq ("$(licensing)", "1")
# non-EAP secure build: set licensing includes and libs to bring in content from licensingroot
LICENSING_INCLUDES = -I$(LICENSINGROOT)/tools -I$(LICENSINGROOT)/LDK/Linux/API/Admin/C -I/usr/include/libxml2
ifeq "$(cpu)" "x86_64"
    LICENSING_LIBS = $(LICENSINGROOT)/LDK/Linux/API/Admin/C/x86_64/libsntl_adminapi_linux_x86_64.a
else
    LICENSING_LIBS = $(LICENSINGROOT)/LDK/Linux/API/Admin/C/x86_64/libsntl_adminapi_linux.a
endif
LICENSING_LIBS += -lxml2
# pass demo flag through to the build
# this supports licensing development on the LDK DEMOMA vendorcode
# in production, DEMO_VENDORCODE is left undefined/0 to select the IDT vendorcode
ifeq "$(DEMO_VENDORCODE)" "1"
CFLAGS += -DDEMO_VENDORCODE
endif
endif

# always build the unsecure r12c binary
TARGET_R12C = DXPerfMon r12c_unsec
# add the secure r12c binary in licensing=1 builds
# note that secure binary contains license checks, is not yet enveloped
ifeq ("$(licensing)", "1")
TARGET_R12C += r12c_sec_must_envelope
endif
TARGET = $(TARGET_R12C)

#LD = gcc
#AR = ar
CC = $(GCC_EXEC_PREFIX)gcc
LD = $(GCC_EXEC_PREFIX)gcc
OD = ./

all: $(TARGET)

r12c_unsec.o: r12c.c
	# build unsecure r12c object
	$(CC) -c $(CFLAGS) -DLICENSING=0 $< -o $@

r12c_unsec: r12c_unsec.o
	# link unsecure r12c binary
	# gcc links to the shared libstdc++.so by default.
	# This causes errors at executable load if the system libstdc++.so is
	# of incompatible C++ ABI; this can happen if r12c is build+linked with
	# a non-system gcc (for example gcc 6.1 in /usr/local/bin or /tools)
	# and deployed onto a system that does not have the same version.
	# To avoid this, force a static link to libstdc++.a.
	# 1. create a symlink to gcc's libstdc++.a to prepare for static link
	ln -fs `$(CC) $(CFLAGS) -print-file-name=libstdc++.a` libstdc++.a
	# 2. link to the symlinked libstdc++.a explicitly rather than using
	# -lstdc++. Note that libstdc++.a needs to be the last library linked.
	$(LD) $(LFLAGS) $^ $(ADDITIONAL_LIBS) -lstdc++ -o $@
	# 3. can now delete the symlink
	rm -f libstdc++.a
ifdef EAP
	# EAP unlicensed build has separate debuginfo
	# make standalone debuginfo file from the binary
	objcopy --only-keep-debug $@ $@.debug
	# strip debug symbols from the binary
	strip --strip-debug $@
	# add a debug link from the binary to the debuginfo file
	objcopy --add-gnu-debuglink=$@.debug $@
endif

ifeq ("$(licensing)", "1")
envelope_utils.o: $(LICENSINGROOT)/tools/envelope_utils.c
	# build envelope_utils from the licensing repo in licensing=1 builds
	$(CC) -c $(CFLAGS) $(LICENSING_INCLUDES) $< -o $@
r12c_sec_must_envelope.o: r12c.c
	# build secure r12c object
	$(CC) -c $(CFLAGS) $(LICENSING_INCLUDES) -DLICENSING=1 $< -o $@
r12c_sec_must_envelope: r12c_sec_must_envelope.o envelope_utils.o
	# link secure r12c binary
	# gcc links to the shared libstdc++.so by default.
	# This causes errors at executable load if the system libstdc++.so is
	# of incompatible C++ ABI; this can happen if r12c is build+linked with
	# a non-system gcc (for example gcc 6.1 in /usr/local/bin or /tools)
	# and deployed onto a system that does not have the same version.
	# To avoid this, force a static link to libstdc++.a.
	# 1. create a symlink to gcc's libstdc++.a to prepare for static link
	ln -fs `$(CC) $(CFLAGS) -print-file-name=libstdc++.a` libstdc++.a
	# 2. link to the symlinked libstdc++.a explicitly rather than using
	# -lstdc++. Note that libstdc++.a needs to be the last library linked.
	$(LD) $(LFLAGS) $^ $(ADDITIONAL_LIBS) $(LICENSING_LIBS) -lstdc++ -o $@
	# 3. can now delete the symlink
	rm -f libstdc++.a
	# licensed builds always have separate debuginfo
	# make standalone debuginfo file
	objcopy --only-keep-debug $@ r12c_sec.debug
	# strip debug symbols from the binary
	# note this is not strictly necessary as the enveloper will also strip
	strip --strip-debug $@
	# add a debug link from the binary to the debuginfo file
	# note this is not strictly useful as the enveloper will not preserve it
	# but good practice to add it anyway
	objcopy --add-gnu-debuglink=r12c_sec.debug $@
endif

DXPerfMon : DXPerfMon.o
	$(LD) $(LFLAGS) -o $@ $< -lfw

%.o : %.c
	$(CC) -c $(CFLAGS) -o $@ $<

clean :
	rm -f *~ *.o *.a $(TARGET_R12C) *.debug
	# always delete the unenveloped r12c_sec regardless
	rm -f r12c_sec_must_envelope
	# clean also the enveloped versions which are put here by top-level make
	rm -f r12c_sec_prod r12c_sec_dev
