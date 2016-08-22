function(ele_apply TARGET REQUIRED SUBMODULE)	

	ele_use(${TARGET} ${REQUIRED} Jsoncpp)
	find_package (json_rpc_cpp 0.4)
	find_program(ELE_JSON_RPC_STUB jsonrpcstub)
	ele_show_dependency(JSON_RPC_CPP json-rpc-cpp)

	if (${SUBMODULE} STREQUAL "Server")
		ele_use(${TARGET} ${REQUIRED} Mhd)
		get_property(DISPLAYED GLOBAL PROPERTY ELE_JSONRPCSTUB_DISPLAYED)
		if (NOT DISPLAYED)
			set_property(GLOBAL PROPERTY ELE_JSONRPCSTUB_DISPLAYED TRUE)
			message(STATUS "jsonrpcstub location    : ${ELE_JSON_RPC_STUB}")
		endif()
		target_include_directories(${TARGET} SYSTEM PUBLIC ${JSON_RPC_CPP_INCLUDE_DIRS})
		target_link_libraries(${TARGET} ${JSON_RPC_CPP_SERVER_LIBRARIES})
		target_compile_definitions(${TARGET} PUBLIC ELE_JSONRPC)
	endif()

	if (${SUBMODULE} STREQUAL "Client")
		target_include_directories(${TARGET} SYSTEM PUBLIC ${JSON_RPC_CPP_INCLUDE_DIRS})
		target_link_libraries(${TARGET} ${JSON_RPC_CPP_CLIENT_LIBRARIES})
		target_compile_definitions(${TARGET} PUBLIC ELE_JSONRPC)

		ele_use(${TARGET} ${REQUIRED} CURL)
	endif()

endfunction()
