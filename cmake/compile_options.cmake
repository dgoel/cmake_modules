# Common compile options for the project

option(PROJECT_ENABLE_WARNINGS_AS_ERRORS
       "Enable compiler warnings as errors" ON)
option(PROJECT_ENABLE_DEBUG_SYMBOLS "Build with debug symbols" OFF)
option(PROJECT_TRY_REPRODUCIBLE_BUILDS "Build with NDEBUG, strip out filenames, etc." OFF)

if(NOT "${CMAKE_CXX_STANDARD}")
  set(CMAKE_CXX_STANDARD 14)
endif()
if(NOT "${CMAKE_C_STANDARD}")
  set(CMAKE_C_STANDARD 11)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

# common options for gcc and clang
add_compile_options(-O3 -Wall -Wextra -Wnull-dereference)

# gcc specific options
if(CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_C_COMPILER_ID MATCHES GNU)
  add_compile_options(-Wlogical-op -Wshadow)
  add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-Wuseless-cast>)
  add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-Wsuggest-override>)
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Werror-implicit-function-declaration")

# extra options
if(PROJECT_ENABLE_DEBUG_SYMBOLS)
  add_compile_options(-g)
endif()

if(PROJECT_ENABLE_WARNINGS_AS_ERRORS)
  message(STATUS "Enable warnings as errors.")
  add_compile_options(-Werror)
else()
  message(STATUS "Disable warnings as errors.")
endif()

if(PROJECT_TRY_REPRODUCIBLE_BUILDS)
  # https://reproducible-builds.org/docs/
  message(STATUS "Try reproducible builds.")

  # prevent filepaths from being embedded into the build
  # More info here: https://reproducible-builds.org/docs/build-path/
  add_compile_options(-Wno-builtin-macro-redefined)
  add_compile_definitions(__FILE__="")
  add_compile_definitions(NDEBUG)
endif()
