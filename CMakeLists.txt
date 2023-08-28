cmake_minimum_required(VERSION 3.14)

# General options
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Find programs required to build.
find_program(GO NAMES go)
if(NOT GO)
  message(FATAL_ERROR "go not found. Get it from: https://golang.org")
else()
  message(STATUS "go found at: ${GO}")
endif()

find_program(NODE NAMES node)
if(NOT NODE)
  message(WARNING "node not found, cannot run WebAssembly tests. Get it from: https://nodejs.org/")
else()
  message(STATUS "node found at: ${NODE}")
endif()

find_program(WAT2WASM NAMES wat2wasm)
if(NOT WAT2WASM)
  message(WARNING "wat2wasm not found, cannot build wasm tests. Get it from: https://github.com/WebAssembly/wabt")
else()
  message(STATUS "wat2wasm found at: ${WAT2WASM}")
endif()

find_program(NASM NAMES nasm)
if(NOT NASM)
  message(WARNING "nasm not found, cannot build player example or nasm tests. Get it from: https://www.nasm.us/")
endif()
set(CMAKE_ASM_NASM_COMPILER ${NASM})

# Get the sointu version from git.
execute_process(
  COMMAND ${GO} run github.com/choffmeister/git-describe-semver --dir ${CMAKE_CURRENT_LIST_DIR} --fallback v0.0.0
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  OUTPUT_VARIABLE full_version
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REGEX MATCH "[^-]*" cmake_compatible_version ${full_version})
string(REGEX REPLACE "^[v]" "" cmake_compatible_version ${cmake_compatible_version})

project(sointu
    VERSION ${cmake_compatible_version}
    DESCRIPTION "A modular synthesizer for 4k/8k/64k intros"
    HOMEPAGE_URL "https://github.com/vsariola/sointu"
    LANGUAGES ASM_NASM C
)

# if(APPLE)
#     set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-no_pie")
# endif()

# the tests include the entire ASM but we still want to rebuild when they change
file(GLOB sointusrc "${PROJECT_SOURCE_DIR}/*.go")
file(GLOB compilersrc "${PROJECT_SOURCE_DIR}/compiler/*.go")
file(GLOB compilecmdsrc "${PROJECT_SOURCE_DIR}/cmd/sointu-compile/*.go")

# Build sointu-cli only once because go run has everytime quite a bit of delay when
# starting
add_custom_command(
    COMMAND ${GO} build -o sointu-compile${SU_TARGET_EXE_SUFFIX} ${PROJECT_SOURCE_DIR}/cmd/sointu-compile/main.go
    OUTPUT sointu-compile${SU_TARGET_EXE_SUFFIX}
    DEPENDS "${sointusrc}" "${compilersrc}" "${compilecmdsrc}"
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/sointu-compile${SU_TARGET_EXE_SUFFIX} DESTINATION bin)

# Build the tracker.
add_custom_command(
    COMMAND ${GO} build -o sointu-track${SU_TARGET_EXE_SUFFIX} ${PROJECT_SOURCE_DIR}/cmd/sointu-track/main.go
    OUTPUT sointu-track${SU_TARGET_EXE_SUFFIX}
    DEPENDS "${sointusrc}" "${compilersrc}" "${compilecmdsrc}"
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/sointu-track${SU_TARGET_EXE_SUFFIX} DESTINATION bin)

# Build the sointu library.
add_custom_command(
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/sointu-compile${SU_TARGET_EXE_SUFFIX} -arch=${SU_TARGET_ARCH} -a -o ${CMAKE_CURRENT_BINARY_DIR}
    OUTPUT sointu.asm
    BYPRODUCTS sointu.h
    # Ok, this is hacky - for the dependencies to come out correctly, the sointu library depends on everything!
    # not pretty, but works.
    DEPENDS "${SU_TEMPLATE_SOURCES}" sointu-compile${SU_TARGET_EXE_SUFFIX} sointu-track${SU_TARGET_EXE_SUFFIX}
)
add_library(sointu sointu.asm)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/sointu.h DESTINATION include)
install(TARGETS sointu DESTINATION lib)

# Add examples subdirectory for the sointu asm example
add_subdirectory(examples)

# # Only do these if this is the main project, and not if it is included through add_subdirectory
# if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
#     # Let's ensure -std=c++xx instead of -std=g++xx
#     set(CMAKE_CXX_EXTENSIONS OFF)

#     # Let's nicely support folders in IDE's
#     set_property(GLOBAL PROPERTY USE_FOLDERS ON)

#     # Testing only available if this is the main app
#     # Note this needs to be done in the main CMakeLists
#     # since it calls enable_testing, which must be in the
#     # main CMakeLists.
#     include(CTest)
# endif()

# # Testing only available if this is the main app
# # Emergency override 4KLANG_CMAKE_BUILD_TESTING provided as well
# if((CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME OR SOINTU_CMAKE_BUILD_TESTING) AND BUILD_TESTING)
#     add_subdirectory(tests)
# endif()