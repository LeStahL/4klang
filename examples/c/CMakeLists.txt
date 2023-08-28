add_custom_command(
    COMMAND
        ${PROJECT_BINARY_DIR}/sointu-compile${SU_TARGET_EXE_SUFFIX} -arch ${SU_TARGET_ARCH} -o physics_girl_st.asm "${PROJECT_SOURCE_DIR}/examples/patches/physics-girl-st.yml"
    WORKING_DIRECTORY
        ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS
        "${PROJECT_SOURCE_DIR}/examples/patches/physics-girl-st.yml"
    OUTPUT
        physics_girl_st.asm
        physics_girl_st.h
        physics_girl_st.inc
    COMMENT
        "Compiling ${PROJECT_SOURCE_DIR}/examples/patches/physics-girl-st.yml..."
)

add_library(physics_girl_st physics_girl_st.asm)
add_dependencies(physics_girl_st sointu)

add_executable(cplay
    cplay.${SU_TARGET_OS}.c
    physics_girl_st.h
)
if(SU_TARGET_OS_IS_WINDOWS)
    # TODO: Link
elseif(SU_TARGET_OS_IS_UNIX)
    target_compile_options(cplay PRIVATE)
    target_link_libraries(cplay PRIVATE asound pthread)
    target_link_options(cplay PRIVATE -z noexecstack -no-pie)
endif()
target_link_libraries(cplay PRIVATE physics_girl_st)

install(TARGETS cplay DESTINATION examples)
