##########################################################################
# "THE ANY BEVERAGE-WARE LICENSE" (Revision 42 - based on beer-ware
# license):
# <dev@layer128.net> wrote this file. As long as you retain this notice
# you can do whatever you want with this stuff. If we meet some day, and
# you think this stuff is worth it, you can buy me a be(ve)er(age) in
# return. (I don't like beer much.)
#
# Matthias Kleemann
##########################################################################

##########################################################################
# The toolchain requires some variables set.
#
# AVR_MCU (default: atmega8)
#     the type of AVR the application is built for
# AVR_L_FUSE (NO DEFAULT)
#     the LOW fuse value for the MCU used
# AVR_H_FUSE (NO DEFAULT)
#     the HIGH fuse value for the MCU used
# AVR_UPLOADTOOL_PORT (default: usb)
#     the port used for the upload tool, e.g. usb
# AVR_PROGRAMMER (default: avrispmkII)
#     the programmer hardware used, e.g. avrispmkII
##########################################################################

##########################################################################
# options
##########################################################################
option(WITH_MCU "Add the mCU type to the target file name." ON)

set(AVR_CC avr-gcc)
set(AVR_CXX avr-g++)
set(AVR_OBJCOPY avr-objcopy)
set(AVR_SIZE_TOOL avr-size)
set(AVR_OBJDUMP avr-objdump)
set(AVR_UPLOADTOOL avrdude)

##########################################################################
# toolchain starts with defining mandatory variables
##########################################################################
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)
set(CMAKE_CROSSCOMPILING 1)
set(CMAKE_C_COMPILER ${AVR_CC})
set(CMAKE_CXX_COMPILER ${AVR_CXX})

##########################################################################
# Identification
##########################################################################
set(AVR 1)

##########################################################################
# some necessary tools and variables for AVR builds, which may not
# defined yet
# - AVR_UPLOADTOOL
# - AVR_UPLOADTOOL_PORT
# - AVR_PROGRAMMER
# - AVR_MCU
# - AVR_SIZE_ARGS
##########################################################################

# default upload tool port
if(NOT AVR_UPLOADTOOL_PORT)
    set(
            AVR_UPLOADTOOL_PORT usb
            CACHE STRING "Set default upload tool port: usb"
    )
endif(NOT AVR_UPLOADTOOL_PORT)

# default programmer (hardware)
if(NOT AVR_PROGRAMMER)
    set(
            AVR_PROGRAMMER avrispmkII
            CACHE STRING "Set default programmer hardware model: avrispmkII"
    )
endif(NOT AVR_PROGRAMMER)

# default MCU (chip)
if(NOT AVR_MCU)
    set(
            AVR_MCU atmega8
            CACHE STRING "Set default MCU: atmega8 (see 'avr-gcc --target-help' for valid values)"
    )
endif(NOT AVR_MCU)

#default avr-size args
if(NOT AVR_SIZE_ARGS)
    set(AVR_SIZE_ARGS -B)
endif(NOT AVR_SIZE_ARGS)

# prepare base flags for upload tool
set(AVR_UPLOADTOOL_BASE_OPTIONS -p ${AVR_MCU} -c ${AVR_PROGRAMMER})

# use AVR_UPLOADTOOL_BAUDRATE as baudrate for upload tool (if defined)
if(AVR_UPLOADTOOL_BAUDRATE)
    set(AVR_UPLOADTOOL_BASE_OPTIONS ${AVR_UPLOADTOOL_BASE_OPTIONS} -b ${AVR_UPLOADTOOL_BAUDRATE})
endif()

##########################################################################
# check build types:
# - Debug
# - Release
# - RelWithDebInfo
#
# Release is chosen, because of some optimized functions in the
# AVR toolchain, e.g. _delay_ms().
##########################################################################
if(NOT ((CMAKE_BUILD_TYPE MATCHES Release) OR
(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo) OR
(CMAKE_BUILD_TYPE MATCHES Debug) OR
(CMAKE_BUILD_TYPE MATCHES MinSizeRel)))
    set(
            CMAKE_BUILD_TYPE Release
            CACHE STRING "Choose cmake build type: Debug Release RelWithDebInfo MinSizeRel"
            FORCE
    )
endif(NOT ((CMAKE_BUILD_TYPE MATCHES Release) OR
(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo) OR
(CMAKE_BUILD_TYPE MATCHES Debug) OR
(CMAKE_BUILD_TYPE MATCHES MinSizeRel)))



##########################################################################

##########################################################################
# target file name add-on
##########################################################################
if(WITH_MCU)
    set(MCU_TYPE_FOR_FILENAME "-${AVR_MCU}")
else(WITH_MCU)
    set(MCU_TYPE_FOR_FILENAME "")
endif(WITH_MCU)

##########################################################################
# add_avr_executable.cmake
# - IN_VAR: EXECUTABLE_NAME
#
# Creates targets and dependencies for AVR toolchain, building an
# executable. Calls add_executable with ELF file as target name, so
# any link dependencies need to be using that target, e.g. for
# target_link_libraries(<EXECUTABLE_NAME>-${AVR_MCU}.elf ...).
##########################################################################

include(${CMAKE_CURRENT_LIST_DIR}/add_avr_executable.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/add_avr_library.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/avr_target_link_libraries.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/avr_target_include_directories.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/avr_target_compile_definitions.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/avr_generate_fixed_targets.cmake)

##########################################################################
# Bypass the link step in CMake's "compiler sanity test" check
#
# CMake throws in a try_compile() target test in some generators, but does
# not know that this is a cross compiler so the executable can't link.
# Change the target type:
#
# https://stackoverflow.com/q/53633705
##########################################################################

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
