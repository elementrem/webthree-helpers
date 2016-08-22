function(create_build_info NAME)

	# Set build platform; to be written to BuildInfo.h
	set(ELE_BUILD_OS "${CMAKE_SYSTEM_NAME}")

	if (CMAKE_COMPILER_IS_MINGW)
		set(ELE_BUILD_COMPILER "mingw")
	elseif (CMAKE_COMPILER_IS_MSYS)
		set(ELE_BUILD_COMPILER "msys")
	elseif (CMAKE_COMPILER_IS_GNUCXX)
		set(ELE_BUILD_COMPILER "g++")
	elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
		set(ELE_BUILD_COMPILER "msvc")
	elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
		set(ELE_BUILD_COMPILER "clang")
	elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
		set(ELE_BUILD_COMPILER "appleclang")
	else ()
		set(ELE_BUILD_COMPILER "unknown")
	endif ()

	if (EVMJIT)
		set(ELE_BUILD_JIT_MODE "JIT")
	else ()
		set(ELE_BUILD_JIT_MODE "Interpreter")
	endif ()

	set(ELE_BUILD_PLATFORM "${ELE_BUILD_OS}/${ELE_BUILD_COMPILER}/${ELE_BUILD_JIT_MODE}")

	if (PARANOID)
		set(ELE_BUILD_PLATFORM "${ELE_BUILD_PLATFORM}/PARA")
	endif ()

	#cmake build type may be not speCified when using msvc
	if (CMAKE_BUILD_TYPE)
		set(_cmake_build_type ${CMAKE_BUILD_TYPE})
	else()
		set(_cmake_build_type "${CMAKE_CFG_INTDIR}")
	endif()

	# Generate header file containing useful build information
	add_custom_target(${NAME}_BuildInfo.h ALL
		WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
		COMMAND ${CMAKE_COMMAND} -DELE_SOURCE_DIR="${PROJECT_SOURCE_DIR}" -DELE_BUILDINFO_IN="${ELE_CMAKE_DIR}/templates/BuildInfo.h.in" -DELE_DST_DIR="${PROJECT_BINARY_DIR}/include/${PROJECT_NAME}" -DELE_CMAKE_DIR="${ELE_CMAKE_DIR}"
		-DELE_BUILD_TYPE="${_cmake_build_type}"
		-DELE_BUILD_OS="${ELE_BUILD_OS}"
		-DELE_BUILD_COMPILER="${ELE_BUILD_COMPILER}"
		-DELE_BUILD_JIT_MODE="${ELE_BUILD_JIT_MODE}"
		-DELE_BUILD_PLATFORM="${ELE_BUILD_PLATFORM}"
		-DELE_BUILD_NUMBER="${BUILD_NUMBER}"
		-DELE_VERSION_SUFFIX="${VERSION_SUFFIX}"
		-DPROJECT_VERSION="${PROJECT_VERSION}"
		-DELE_FATDB="${FATDB10}"
		-P "${ELE_SCRIPTS_DIR}/buildinfo.cmake"
		)
	include_directories(BEFORE ${PROJECT_BINARY_DIR})
endfunction()
