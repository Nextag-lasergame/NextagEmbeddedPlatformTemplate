function(avr_target_include_directories EXECUTABLE_TARGET)
    if(NOT ARGN)
        message(FATAL_ERROR "No include directories to add to ${EXECUTABLE_TARGET}.")
    endif()

    get_target_property(TARGET_LIST ${EXECUTABLE_TARGET} OUTPUT_NAME)
    set(extra_args ${ARGN})

    target_include_directories(${TARGET_LIST} ${extra_args})
endfunction()