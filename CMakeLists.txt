cmake_minimum_required(VERSION 3.25)

include(CheckIPOSupported)
check_ipo_supported(RESULT supported OUTPUT error)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

set(AVR_PROGRAMMER arduino)
set(AVR_MCU atmega328p)
add_compile_options(-DF_CPU=16000000l)

add_compile_options(-Werror -Wall -Wextra -Wno-error=cpp)

include(cmake/toolchain/generic-gcc-avr.cmake)
include(cmake/NextagEmbeddedPlatform.cmake)
setup_nextag_embedded_platform()

project(NextagEmbeddedBaseTemplate)

set(CMAKE_CXX_STANDARD 20)

add_avr_executable(NextagEmbeddedBaseTemplate 
    src/main.cpp)

avr_target_link_libraries(NextagEmbeddedBaseTemplate PRIVATE NextagEmbeddedPlatform-${AVR_MCU})
