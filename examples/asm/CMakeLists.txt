if(X86 AND CRINKLER)
    set(CMAKE_INCLUDE_CURRENT_DIR ON)

    add_custom_command(
        COMMAND
            ${compilecmd} -arch 386 -o physics_girl_st.asm "${PROJECT_SOURCE_DIR}/examples/patches/physics-girl-st.yml"
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

    add_executable(asmplay
        asmplay.asm
        physics_girl_st.asm
        physics_girl_st.inc
    )
    target_link_libraries(asmplay PRIVATE winmm)
    add_dependencies(asmplay sointu-compiler)
endif()
