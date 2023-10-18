function(add_avr_executable EXECUTABLE_NAME)

    if(NOT ARGN)
        message(FATAL_ERROR "No source files given for ${EXECUTABLE_NAME}.")
    endif(NOT ARGN)

    # set file names
    set(elf_file ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}.elf)
    set(hex_file ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}.hex)
    set(lst_file ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}.lst)
    set(map_file ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}.map)
    set(eeprom_image ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}-eeprom.hex)

    set (${EXECUTABLE_NAME}_ELF_TARGET ${elf_file} PARENT_SCOPE)
    set (${EXECUTABLE_NAME}_HEX_TARGET ${hex_file} PARENT_SCOPE)
    set (${EXECUTABLE_NAME}_LST_TARGET ${lst_file} PARENT_SCOPE)
    set (${EXECUTABLE_NAME}_MAP_TARGET ${map_file} PARENT_SCOPE)
    set (${EXECUTABLE_NAME}_EEPROM_TARGET ${eeprom_file} PARENT_SCOPE)
    # elf file
    add_executable(${elf_file} EXCLUDE_FROM_ALL ${ARGN})

    set_target_properties(
            ${elf_file}
            PROPERTIES
            COMPILE_FLAGS "-mmcu=${AVR_MCU}"
            LINK_FLAGS "-mmcu=${AVR_MCU} -Wl,--gc-sections -mrelax -Wl,-Map,${map_file}"
    )

    add_custom_command(
            OUTPUT ${hex_file}
            COMMAND
            ${AVR_OBJCOPY} -j .text -j .data -O ihex ${elf_file} ${hex_file}
            COMMAND
            ${AVR_SIZE_TOOL} ${AVR_SIZE_ARGS} ${elf_file}
            DEPENDS ${elf_file}
    )

    add_custom_command(
            OUTPUT ${lst_file}
            COMMAND
            ${AVR_OBJDUMP} -d ${elf_file} > ${lst_file}
            DEPENDS ${elf_file}
    )

    # eeprom
    add_custom_command(
            OUTPUT ${eeprom_image}
            COMMAND
            ${AVR_OBJCOPY} -j .eeprom --set-section-flags=.eeprom=alloc,load
            --change-section-lma .eeprom=0 --no-change-warnings
            -O ihex ${elf_file} ${eeprom_image}
            DEPENDS ${elf_file}
    )

    add_custom_target(
            ${EXECUTABLE_NAME}
            ALL
            DEPENDS ${hex_file} ${lst_file} ${eeprom_image}
    )

    set_target_properties(
            ${EXECUTABLE_NAME}
            PROPERTIES
            OUTPUT_NAME "${elf_file}"
    )

    # clean
    get_directory_property(clean_files ADDITIONAL_MAKE_CLEAN_FILES)
    set_directory_properties(
            PROPERTIES
            ADDITIONAL_MAKE_CLEAN_FILES "${map_file}"
    )

    # upload - with avrdude
    add_custom_target(
            upload_${EXECUTABLE_NAME}
            ${AVR_UPLOADTOOL} ${AVR_UPLOADTOOL_BASE_OPTIONS} ${AVR_UPLOADTOOL_OPTIONS}
            -U flash:w:${hex_file}
            -P ${AVR_UPLOADTOOL_PORT}
            DEPENDS ${hex_file}
            COMMENT "Uploading ${hex_file} to ${AVR_MCU} using ${AVR_PROGRAMMER}"
    )

    # upload eeprom only - with avrdude
    # see also bug http://savannah.nongnu.org/bugs/?40142
    add_custom_target(
            upload_${EXECUTABLE_NAME}_eeprom
            ${AVR_UPLOADTOOL} ${AVR_UPLOADTOOL_BASE_OPTIONS} ${AVR_UPLOADTOOL_OPTIONS}
            -U eeprom:w:${eeprom_image}
            -P ${AVR_UPLOADTOOL_PORT}
            DEPENDS ${eeprom_image}
            COMMENT "Uploading ${eeprom_image} to ${AVR_MCU} using ${AVR_PROGRAMMER}"
    )

    # disassemble
    add_custom_target(
            disassemble_${EXECUTABLE_NAME}
            ${AVR_OBJDUMP} -h -S ${elf_file} > ${EXECUTABLE_NAME}.lst
            DEPENDS ${elf_file}
    )
endfunction(add_avr_executable)