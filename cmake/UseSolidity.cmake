function(ele_apply TARGET REQUIRED SUBMODULE)

	set(SOL_DIR "${ELE_CMAKE_DIR}/../../solidity" CACHE PATH "The path to the solidity directory")
	set(SOL_BUILD_DIR_NAME  "build" CACHE STRING "The name of the build directory in solidity repo")
	set(SOL_BUILD_DIR "${SOL_DIR}/${SOL_BUILD_DIR_NAME}")
	set(CMAKE_LIBRARY_PATH ${SOL_BUILD_DIR};${CMAKE_LIBRARY_PATH})

	find_package(Solidity)

	# Hide confusing blank dependency information when using FindSolidity on itself.
	if (NOT(${MODULE_MAIN} STREQUAL Solidity))
		ele_show_dependency(SOLIDITY solidity)
	endif()

	target_include_directories(${TARGET} PUBLIC ${Solidity_INCLUDE_DIRS})

	if (${SUBMODULE} STREQUAL "evmasm")
		ele_use(${TARGET} ${REQUIRED} )
                target_link_libraries(${TARGET} ${Solidity_EVMASM_LIBRARIES})
	endif()

	if (${SUBMODULE} STREQUAL "lll")
		ele_use(${TARGET} ${REQUIRED} Solidity::evmasm)
		target_link_libraries(${TARGET} ${Solidity_LLL_LIBRARIES})
	endif()

	if (${SUBMODULE} STREQUAL "solidity" OR ${SUBMODULE} STREQUAL "")
		ele_use(${TARGET} ${REQUIRED} Dev::devcore Solidity::evmasm)
		target_link_libraries(${TARGET} ${Solidity_SOLIDITY_LIBRARIES})
	endif()

	target_compile_definitions(${TARGET} PUBLIC ELE_SOLIDITY)
endfunction()
