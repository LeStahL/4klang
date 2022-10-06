set(GO4KVSTI_CXX_SOURCES
    source/common/AudioEffect.cpp
    source/common/audioeffectx.cpp
    source/GoSynth/Go4kVSTi.cpp
    source/GoSynth/Go4kVSTiCore.cpp
    
    source/GoSynth/Go4kVSTimain.cpp
    source/GoSynth/Go4kVSTIproc.cpp

    win/Go4kVSTi.rc
)

set(GO4kVSTI_LIBRARIES
    vstgui
    Comctl32
    odbc32
    odbccp32
)

if(USE_QT)
    set(GO4KVSTI_CXX_SOURCES ${GO4KVSTI_CXX_SOURCES}
        source/GoSynth/Go4kVSTiGUIQt.cpp
        source/GoSynth/SynthWindow.cpp
        source/GoSynth/SynthWindow.ui
    )
    set(GO4kVSTI_LIBRARIES ${GO4kVSTI_LIBRARIES} ${QT_PREFIXED_COMPONENTS})
    set(GO4kVSTI_DEFINITIONS USE_QT)
else()
    set(GO4KVSTI_CXX_SOURCES ${GO4KVSTI_CXX_SOURCES}
        source/GoSynth/Go4kVSTiGUI.cpp
    )
endif()

set_source_files_properties(4klang.obj PROPERTIES EXTERNAL_OBJECT true GENERATED true)

include_directories(
    "${CMAKE_CURRENT_SOURCE_DIR}/win"
    "${CMAKE_CURRENT_SOURCE_DIR}/source/common"
    "${CMAKE_CURRENT_SOURCE_DIR}/source/GoSynth"
    )
link_directories("${CMAKE_CURRENT_SOURCE_DIR}/win/library")

add_library(4klang SHARED ${GO4KVSTI_CXX_SOURCES} win/Go4kVSTi.def 4klang.obj)
target_compile_definitions(4klang PUBLIC ${GO4kVSTI_DEFINITIONS})
target_link_libraries(4klang PUBLIC ${GO4kVSTI_LIBRARIES} ${QT_PREFIXED_COMPONENTS})
add_custom_command(TARGET 4klang PRE_BUILD BYPRODUCTS 4klang.obj
    COMMAND ${YASM} ${CMAKE_CURRENT_SOURCE_DIR}/win/4klang.asm ${YASM_OPTIONS} -o 4klang.obj -i "${CMAKE_CURRENT_SOURCE_DIR}/win/"
    COMMENT "Assembling 4klang.asm..."
)

add_library(8klang SHARED ${GO4KVSTI_CXX_SOURCES} win/Go4kVSTi2.def 4klang.obj)
target_compile_definitions(8klang PUBLIC ${GO4kVSTI_DEFINITIONS} _8KLANG)
target_link_libraries(8klang PUBLIC ${GO4kVSTI_LIBRARIES} ${QT_PREFIXED_COMPONENTS})

add_executable(4klang_standalone
    source/GoSynth/Go4kStandalone.cpp
)
target_link_libraries(4klang_standalone PRIVATE 4klang ${QT_PREFIXED_COMPONENTS})

add_custom_command(TARGET 4klang POST_BUILD
    COMMAND Qt${QT_VERSION_MAJOR}::windeployqt $<TARGET_FILE:4klang>
    COMMENT "Running windeployqt on 4klang..."
)

add_custom_command(TARGET 8klang POST_BUILD
    COMMAND Qt${QT_VERSION_MAJOR}::windeployqt $<TARGET_FILE:4klang>
    COMMENT "Running windeployqt on 8klang..."
)