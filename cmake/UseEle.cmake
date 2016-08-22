function(ele_apply TARGET REQUIRED SUBMODULE)
	# TODO take into account REQUIRED

	set(ELE_DIR "${ELE_CMAKE_DIR}/../../libelementrem" CACHE PATH "The path to the elementrem directory")
	set(ELE_BUILD_DIR_NAME  "build" CACHE STRING "Elementrem build directory name")
	set(ELE_BUILD_DIR "${ELE_DIR}/${ELE_BUILD_DIR_NAME}")
	set(CMAKE_LIBRARY_PATH 	${ELE_BUILD_DIR};${CMAKE_LIBRARY_PATH})

	find_package(Ele)

	target_include_directories(${TARGET} BEFORE PUBLIC ${Ele_INCLUDE_DIRS})
	if ((DEFINED cpp-elementrem_VERSION) OR (DEFINED elementrem_VERSION))
		target_include_directories(${TARGET} PUBLIC "${CMAKE_BINARY_DIR}/libelementrem/include/")
	else()
		target_include_directories(${TARGET} PUBLIC "${ELE_BUILD_DIR}/include/")
	endif()

	if (${SUBMODULE} STREQUAL "elhash")
		# even if elhash is required, Cryptopp is optional
		ele_use(${TARGET} OPTIONAL Cryptopp)
		target_link_libraries(${TARGET} ${Ele_ELHASH_LIBRARIES})
		# even if elhash is required, elhash-cl and cpuid are optional

		# workaround for https://github.com/elementrem/alelezero/issues/69
		# force linking to libOpenCL as early as possible
		if ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux" AND ELHASHCL AND GUI)
			find_package (OpenCL)
			if (OpenCL_FOUND)
				target_link_libraries(${TARGET} "-Wl,--no-as-needed -l${OpenCL_LIBRARIES} -Wl,--as-needed")
			endif()
		endif()
	endif()

	if (${SUBMODULE} STREQUAL "elhash-cl")
		if (ELHASHCL)
			ele_use(${TARGET} ${REQUIRED} OpenCL)
			if (OpenCL_FOUND)
				ele_use(${TARGET} ${REQUIRED} Ele::elhash)
				target_include_directories(${TARGET} SYSTEM PUBLIC ${OpenCL_INCLUDE_DIRS})
				target_link_libraries(${TARGET} ${Ele_ELHASH-CL_LIBRARIES})
				target_compile_definitions(${TARGET} PUBLIC ELE_ELHASHCL)
			endif()
		endif()
	endif()

	if (${SUBMODULE} STREQUAL "elecore")
		ele_use(${TARGET} ${REQUIRED} Dev::devcrypto Dev::buildinfo Dev::devcore)
		target_link_libraries(${TARGET} ${Ele_ELECORE_LIBRARIES})
	endif()

	if (${SUBMODULE} STREQUAL "evmcore")
		ele_use(${TARGET} ${REQUIRED} Dev::devcore)
		target_link_libraries(${TARGET} ${Ele_EVMCORE_LIBRARIES})
	endif()

	if (${SUBMODULE} STREQUAL "evmjit")
		# TODO: not sure if should use evmjit
		# TODO: take into account REQUIRED variable
		if (EVMJIT)
			target_link_libraries(${TARGET} ${Ele_EVMJIT_LIBRARIES})
			ele_copy_dlls(${TARGET} EVMJIT_DLLS)
		endif()
	endif()

	if (${SUBMODULE} STREQUAL "evm")
		ele_use(${TARGET} ${REQUIRED} Ele::elecore Dev::devcrypto Ele::evmcore Dev::devcore)
		ele_use(${TARGET} OPTIONAL Ele::evmjit)
		target_link_libraries(${TARGET} ${Ele_EVM_LIBRARIES})
	endif()

	if (${SUBMODULE} STREQUAL "elhashseal")
		ele_use(${TARGET} ${REQUIRED} Ele::elementrem Ele::elhash)
		ele_use(${TARGET} OPTIONAL Ele::elhash-cl Cpuid)
		target_link_libraries(${TARGET} ${Ele_ELHASHSEAL_LIBRARIES})
	endif()

	if (${SUBMODULE} STREQUAL "elementrem")
		ele_use(${TARGET} ${REQUIRED} Ele::evm Ele::elecore)
		if (NOT EMSCRIPTEN)
			ele_use(${TARGET} ${REQUIRED} Dev::p2p Dev::devcrypto)
		endif()
		target_link_libraries(${TARGET} ${Boost_REGEX_LIBRARIES})
		target_link_libraries(${TARGET} ${Ele_ELEMENTREM_LIBRARIES})
	endif()

	if (${SUBMODULE} STREQUAL "natspec")
		target_link_libraries(${TARGET} ${Ele_NATSPEC_LIBRARIES})
	endif()

	if (${SUBMODULE} STREQUAL "testutils")
		ele_use(${TARGET} ${REQUIRED} Ele::elementrem)
		target_link_libraries(${TARGET} ${Ele_TESTUTILS_LIBRARIES})
	endif()

endfunction()
