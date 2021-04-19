# Configure `ccache` for the project.
#
# This option should be configured at the top of the project `CMakeLists.txt`
# before call to `project()`.
#
# Reference: https://crascit.com/2016/04/09/using-ccache-with-cmake/

option(PROJECT_ENABLE_CCACHE "Enable ccache for build caching" OFF)

if(PROJECT_ENABLE_CCACHE)
  find_program(CCACHE_PROGRAM ccache)
  if(CCACHE_PROGRAM)
    message(STATUS "Enable ccache")
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK "${CCACHE_PROGRAM}")
  endif()
endif()
