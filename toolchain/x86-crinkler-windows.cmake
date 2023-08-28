# Set host- and target-specific options.
set(SU_TARGET_X86 ON)
set(SU_TARGET_X86_64 OFF)

set(SU_TARGET_ARCH "i386")

set(SU_HOST_USES_CRINKLER ON)
set(SU_HOST_USES_UPX OFF)

set(SU_HOST_IS_WINDOWS ON)
set(SU_HOST_IS_UNIX OFF)

# Find crinkler.
find_program(CRINKLER NAMES crinkler)
if(NOT CRINKLER)
    message(WARNING "crinkler not found, cannot build player example. Get it from: https://github.com/runestubbe/Crinkler")
else()
    message(STATUS "crinkler found at: ${CRINKLER}")
endif()

# Assembler settings
set(CMAKE_ASM_NASM_FLAGS "-fwin32 -Ox")

# Linker settings
set(CMAKE_LINKER ${CRINKLER})
set(CMAKE_ASM_NASM_LINK_EXECUTABLE "<CMAKE_LINKER> <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> /out:<TARGET> <LINK_LIBRARIES>")
set(CMAKE_ASM_NASM_LINK_LIBRARY_SUFFIX ".lib")
set(CMAKE_ASM_NASM_LINK_LIBRARY_FLAG "")
set(CMAKE_ASM_NASM_LIBRARY_PATH_FLAG "/libpath:")
set(CMAKE_ASM_NASM_LINK_FLAGS /subsystem:windows /progressgui /compmode:veryslow /HASHTRIES:2400 /ORDERTRIES:20000 /TINYIMPORT /UNSAFEIMPORT /UNALIGNCODE)
