cmake_minimum_required(VERSION 3.15)

project(4klang LANGUAGES CXX RC)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Cache option defaults
set(DOWNLOAD_YASM OFF CACHE BOOL "Download yasm if not present.")
set(YASM_PATH "${PROJECT_BINARY_DIR}/downloads/" CACHE PATH "Search path for yasm.")

# Download yasm if configured in cache and not present.
find_program(YASM NAMES yasm-1.3.0-win32.exe HINTS "${YASM_PATH}/")
if(${YASM} MATCHES YASM-NOTFOUND AND DOWNLOAD_YASM)
    set(YASM_URL "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win32.exe")
    message(STATUS "Downloading YASM from ${YASM_URL}...")
    file(DOWNLOAD ${YASM_URL} "${YASM_PATH}/yasm-1.3.0-win32.exe" SHOW_PROGRESS)
    find_program(YASM NAMES yasm-1.3.0-win32.exe HINTS "${YASM_PATH}")
endif()
message(STATUS "Found YASM: ${YASM}")

# Qt related stuff
set(USE_QT OFF CACHE BOOL "Enable QT UI for 4klang.")
if(USE_QT)
    set(QT_COMPONENTS Core Widgets Gui)

    set(CMAKE_INCLUDE_CURRENT_DIR ON)
    set(CMAKE_AUTOUIC ON)
    set(CMAKE_AUTORCC ON)
    set(CMAKE_AUTOMOC ON)

    find_package(QT NAMES Qt6 Qt5 COMPONENTS ${QT_COMPONENTS} REQUIRED)
    find_package(Qt${QT_VERSION_MAJOR} COMPONENTS ${QT_COMPONENTS} REQUIRED)

    foreach(QT_COMPONENT ${QT_COMPONENTS})
        set(QT_PREFIXED_COMPONENTS ${QT_PREFIXED_COMPONENTS} Qt${QT_VERSION_MAJOR}::${QT_COMPONENT})
    endforeach()

    # Windeployqt
    if(WIN32 AND NOT TARGET Qt${QT_VERSION_MAJOR}::windeployqt)
        get_target_property(_qt${QT_VERSION_MAJOR}_qmake_location Qt${QT_VERSION_MAJOR}::qmake IMPORTED_LOCATION)

        execute_process(
            COMMAND "${_qt${QT_VERSION_MAJOR}_qmake_location}" -query QT_INSTALL_PREFIX
            OUTPUT_VARIABLE QT${QT_VERSION_MAJOR}_INSTALL_PREFIX
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        set(WINDEPLOYQT_LOCATION "${QT${QT_VERSION_MAJOR}_INSTALL_PREFIX}/bin/windeployqt.exe")
        if(EXISTS ${WINDEPLOYQT_LOCATION})
            add_executable(Qt${QT_VERSION_MAJOR}::windeployqt IMPORTED)
            set_target_properties(Qt${QT_VERSION_MAJOR}::windeployqt PROPERTIES IMPORTED_LOCATION ${WINDEPLOYQT_LOCATION})
            message(STATUS "Found windeployqt executable at ${WINDEPLOYQT_LOCATION}")
        else()
            message(SEND_ERROR "Could not find windeployqt executable.")
        endif()
    endif()
endif()

# Build-type-dependent configuration
add_compile_definitions(WIN32 _WINDOWS WINDOWS=1)
if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
    add_compile_definitions(_DEBUG _CRT_SECURE_NO_DEPRECATE)
    add_compile_options(/MTd)
elseif(${CMAKE_BUILD_TYPE} MATCHES "Release")
    add_compile_definitions(NDEBUG)
    add_compile_options(/MT)
endif()

set(YASM_OPTIONS ${YASM_OPTIONS} -Xvc -fwin32)

add_subdirectory(4klang_source/Go4kVSTi)
