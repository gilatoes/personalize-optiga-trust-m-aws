#
# \copyright
# MIT License
#
# Copyright (c) 2018 Infineon Technologies AG
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE
#
# \endcopyright
#
# \author Infineon Technologies AG
#

#Include build congiguration, compiler to be used, file name/directory definitions
-include Config.mk

ROOT_DIR = .
#VERBOSE = 
VERBOSE = @

OSFLAG :=
ifeq ($(OS),Windows_NT)
	OSFLAG = win
	CCFLAGS += -D__WIN32__
	ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
		OSARCH = x86_64
	endif
	ifeq ($(PROCESSOR_ARCHITECTURE),x86)
		OSARCH = x86
	endif
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OSFLAG = linux
	endif
	ifeq ($(UNAME_S),Darwin)
		OSFLAG = osx
	endif

	UNAME_M := $(shell uname -m)
	ifeq ($(UNAME_M),x86_64)
		OSARCH = x86_64
	endif
		ifneq ($(filter %86,$(UNAME_M)),)
			OSARCH = x86
		endif
	ifneq ($(filter arm%,$(UNAME_M)),)
		OSARCH = arm
	endif
endif

BIN_DIR =              $(ROOT_DIR)/../bin/$(MAKECMDGOALS)_$(OSFLAG)_$(OSARCH)
BUILD_DIR =            $(ROOT_DIR)/build

OPTIGA_CORE_OBJECTS =  $(patsubst %.c, $(BUILD_DIR)/%.o, $(SOURCES))
ifeq ($(MAKECMDGOALS), libusb)
PAL_OBJECTS =          $(patsubst %.c, $(BUILD_DIR)/%.o, $(PAL_LIBUSB_SOURCES))
else
PAL_OBJECTS =          $(patsubst %.c, $(BUILD_DIR)/%.o, $(PAL_LINUX_SOURCES))
endif

GEN_CSR_OBJECTS =      $(patsubst %.c, $(BUILD_DIR)/%.o, $(GEN_CSR_SOURCES))
UPLOAD_CRT_OBJECTS =   $(patsubst %.c, $(BUILD_DIR)/%.o, $(UPLOAD_CRT_SOURCES))

.PHONY: mkdirs all clean rpi3 ultra96 libusb cp_lib

all: libusb

rpi3 ultra96:  mkdirs mbedtls $(BUILD_DIR)/optiga_generate_csr $(BUILD_DIR)/optiga_upload_crt cp_lib
libusb: mkdirs mbedtls $(BUILD_DIR)/optiga_generate_csr $(BUILD_DIR)/optiga_upload_crt cp_lib

#Make application note

#Create Directories for binaries and build
mkdirs:
	$(MKDIR) -p $(BUILD_DIR)
	$(MKDIR) -p $(BIN_DIR)


cp_lib:
	-$(COPY) $(PAL_LIBUSB_DIR)/include/libusb-1.0.dll  $(BIN_DIR)/
	$(COPY) $(BUILD_DIR)/optiga_generate_csr  $(BIN_DIR)/
	$(COPY) $(BUILD_DIR)/optiga_upload_crt  $(BIN_DIR)/

mbedtls:
	$(MAKE) -C $(ROOT_DIR)/mbedtls-2.16.0/ no_test

$(BUILD_DIR)/%.o: %.c
	$(VERBOSE)echo Compiling $<
	$(VERBOSE)mkdir -p $(dir $@)
	$(VERBOSE)$(CC) $(CCFLAGS) $(INCLUDES) $(PAL_LIBUSB_INCLUDES) $(PAL_LINUX_INCLUDES) $(GEN_CSR_INCLUDES) -c $< -o $@

$(BUILD_DIR)/optiga_generate_csr: $(OPTIGA_CORE_OBJECTS) $(PAL_OBJECTS) $(GEN_CSR_OBJECTS)
	$(VERBOSE)echo Linking $@
	$(VERBOSE)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@

$(BUILD_DIR)/optiga_upload_crt: $(OPTIGA_CORE_OBJECTS) $(PAL_OBJECTS) $(UPLOAD_CRT_OBJECTS)
	$(VERBOSE)echo Linking $@
	$(VERBOSE)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@

#Clean
clean:
	-$(CLEAN) -rf $(BUILD_DIR)
	rm -rf $(ROOT_DIR)/mbedtls-2.16.0/library/*.o
	rm -rf $(ROOT_DIR)/mbedtls-2.16.0/library/*.a
	find $(ROOT_DIR)/mbedtls-2.16.0/ -name *.exe -type f -delete
