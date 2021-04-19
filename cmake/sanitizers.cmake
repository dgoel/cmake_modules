# Sanitizers
#
# Add support to run sanitizers in C++ builds.
#
# reference: https://github.com/google/sanitizers/wiki
# reference: https://github.com/StableCoder/cmake-scripts/blob/master/sanitizers.cmake
# reference: https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html

include(CMakeDependentOption)

option(SANITIZER_ENABLE_ASAN "Enable Address Sanitizer" OFF)
option(SANITIZER_ENABLE_UBSAN "Enable Undefined Behavior Sanitizer" OFF)
option(SANITIZER_ENABLE_TSAN "Enable Thread Sanitizer" OFF)
option(SANITIZER_ENABLE_MEMSAN "Enable Memory Sanitizer" OFF)

if(SANITIZER_ENABLE_ASAN OR SANITIZER_ENABLE_UBSAN)
  if(SANITIZER_ENABLE_TSAN OR SANITIZER_ENABLE_MEMSAN)
    message(FATAL_ERROR "asan/ubsan are incompatible with tsan/memsan")
  endif()
  if(SANITIZER_ENABLE_ASAN)
    # https://github.com/google/sanitizers/wiki/AddressSanitizer
    # ASan doesn't work with static linkage
    message(STATUS "Address sanitizer enabled")
    add_compile_options(-g -O1 -fsanitize=address -fno-omit-frame-pointer -fPIC)
    add_link_options("LINKER:-fsanitize=address")
    add_link_options("-shared")
    #link_libraries(asan5)
  endif()
  if(SANITIZER_ENABLE_UBSAN)
    # https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
    message(STATUS "Undefined behavior sanitizer enabled")
    add_compile_options(-g -O1 -fsanitize=undefined -fno-omit-frame-pointer)
    add_link_options("LINKER:-fsanitize=undefined")
    #link_libraries(ubsan1)
  endif()
elseif(SANITIZER_ENABLE_TSAN)
  if(SANITIZER_ENABLE_ASAN
     OR SANITIZER_ENABLE_UBSAN
     OR SANITIZER_ENABLE_MEMSAN
  )
    message(FATAL_ERROR "asan/ubsan are incompatible with tsan and memsan")
  endif()
  message(STATUS "Thread sanitizer enabled")
  add_compile_options(-g -O1 -fsanitize=thread -fno-omit-frame-pointer)
  #link_libraries(tsan)
elseif(SANITIZER_ENABLE_MEMSAN)
  if(SANITIZER_ENABLE_ASAN
     OR SANITIZER_ENABLE_UBSAN
     OR SANITIZER_ENABLE_TSAN
  )
    message(FATAL_ERROR "asan/ubsan are incompatible with tsan and memsan")
  endif()
  if(CMAKE_CXX_COMPILER_ID MATCHES Clang)
    # https://github.com/google/sanitizers/wiki/MemorySanitizer
    message(STATUS "Memory sanitizer enabled")
    add_compile_options(-g -fsanitize=memory -fno-omit-frame-pointer -fPIE -pie)
  else()
    message(FATAL_ERROR "Memory Sanitizer is only supported by clang")
  endif()
endif()
