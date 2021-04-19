# Configure `icecc` for the project
#
# This option should be configured at the top of the project `CMakeLists.txt`
# after call to `project()`. This is required so that the compiler is set.
#
# NOTE: Use `ninja` as the backend build tool since it is significantly faster
# for incremental builds.
#
# Reference: https://github.com/lilles/icecc-chromium/blob/master/icecc-ninja

option(PROJECT_ENABLE_ICECC "Enable ICECC for distributed builds" OFF)

macro(find_icecc_toolchain TOOLCHAIN_PATH)
  # Find file that matches this pattern: `[0-9a-f]{32}.tar.gz`
  execute_process(
    COMMAND find ${CMAKE_BINARY_DIR} -maxdepth 1 -regextype posix-extended -regex ".*/[a-f0-9]{32}.tar.gz" -exec readlink -f {} \\;
    RESULT_VARIABLE CMD_FAILURE
    OUTPUT_VARIABLE TOOLCHAIN_PATH
    )
  message(STATUS "ICECC: find output: ${RESULT} ${TOOLCHAIN_PATH}")
  if(CMD_FAILURE OR "${TOOLCHAIN_PATH}" STREQUAL "")
    unset(TOOLCHAIN_PATH)
  endif()
endmacro()

if(PROJECT_ENABLE_ICECC AND NOT PROJECT_ENABLE_CCACHE)
  find_program(ICECC_PROGRAM icecc)
  if(ICECC_PROGRAM)
    message(STATUS "Enable icecc only")
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${ICECC_PROGRAM}")
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK "${ICECC_PROGRAM}")
  endif()
endif()

if(PROJECT_ENABLE_ICECC)
  find_program(ICECC_PROGRAM icecc)
  find_program(ICECC_CREATE_ENV_PROGRAM icecc-create-env)
  if(ICECC_PROGRAM AND ICECC_CREATE_ENV_PROGRAM)
    message(STATUS "Enable iceccc for ${CMAKE_C_COMPILER}")
    find_icecc_toolchain(TOOLCHAIN_PATH)
    if(NOT TOOLCHAIN_PATH)
      message(STATUS "ICECC compressed toolchain not found -- generate one!")
      # Generate toolchain
      execute_process(
        COMMAND ${ICECC_CREATE_ENV_PROGRAM} ${CMAKE_C_COMPILER} ${ICECC_ADD_FILES}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        RESULT_VARIABLE icecc_create_env_ret COMMAND_ECHO STDOUT
      )
      if(icecc_create_env_ret)
        message(FATAL_ERROR "Failed to create icecc compressed toolchain")
      endif()

      # Find the path to generated toolchain
      find_icecc_toolchain(TOOLCHAIN_PATH)
      if(NOT TOOLCHAIN_PATH)
        message(FATAL_ERROR "Failed to find icecc compressed toolchain")
      endif()
    endif()

    # Prepended to PATH to enable icecc to intercept build command
    set(PATH_LINE "export PATH=/usr/lib/icecc/bin:$PATH")

    # Create a ninja wrapper to call icecc
    message(STATUS "Generate icecc-ninja")
    file(
      WRITE ${CMAKE_BINARY_DIR}/icecc-ninja
      "
#!/bin/bash

export CCACHE_PREFIX=icecc
export CCACHE_PREFIX_CPP=icecc
export CCACHE_DEPEND=true
export ICECC_VERSION=${TOOLCHAIN_PATH}
${PATH_LINE}
ninja \"$@\"
"
    )
    execute_process(
      COMMAND chmod u+x ${CMAKE_BINARY_DIR}/icecc-ninja
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
  endif()
else()
  message(STATUS "Remove icecc-ninja")
  file(REMOVE ${CMAKE_BINARY_DIR}/icecc-ninja)
endif()
