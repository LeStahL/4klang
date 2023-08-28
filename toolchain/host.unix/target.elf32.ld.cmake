# Set host- and target-specific options.
set(SU_TARGET_X86 ON)
set(SU_TARGET_X86_64 OFF)
set(SU_TARGET_ARCH "386")
message(STATUS "Target architexture: ${SU_TARGET_ARCH}.")

set(SU_TARGET_OS_IS_UNIX ON)
set(SU_TARGET_OS_IS_WINDOWS OFF)
set(SU_TARGET_OS "unix")
message(STATUS "Target system is ${SU_HOST_SYSTEM}.")

file(GLOB SU_TEMPLATE_SOURCES "${CMAKE_CURRENT_LIST_DIR}/../templates/amd64-386/*.asm")

set(SU_TARGET_EXE_SUFFIX "")
message(STATUS "Target executable suffix: `${SU_TARGET_EXE_SUFFIX}`.")
set(SU_TARGET_STATIC_LIBRARY_SUFFIX ".a")
message(STATUS "Target static library suffix: `${SU_TARGET_STATIC_LIBRARY_SUFFIX}`.")

set(SU_HOST_USES_CRINKLER OFF)
set(SU_HOST_IS_WINDOWS OFF)
set(SU_HOST_IS_UNIX ON)

# Assembler settings
set(CMAKE_ASM_NASM_FLAGS "-felf32 -Ox")

# C compiler settings
set(CMAKE_C_FLAGS "-m32")

# Linker settings
set(CMAKE_LINKER ld)
set(CMAKE_ASM_NASM_LINK_EXECUTABLE "<CMAKE_LINKER> <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
set(CMAKE_ASM_NASM_LINK_LIBRARY_SUFFIX "")
set(CMAKE_ASM_NASM_LINK_LIBRARY_FLAG "-l")
set(CMAKE_ASM_NASM_LIBRARY_PATH_FLAG "-L")
set(CMAKE_ASM_NASM_LINK_FLAGS -melf_i386)
