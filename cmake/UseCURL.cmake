function(ele_apply TARGET REQUIRED)
	find_package (CURL)
	ele_show_dependency(CURL curl)

	if (CURL_FOUND)
		if (STATIC_LINKING)
			ele_use(${TARGET} OPTIONAL SSH2)
			ele_use(${TARGET} OPTIONAL OpenSSL)
			ele_use(${TARGET} OPTIONAL ZLIB)
		endif()
		target_include_directories(${TARGET} SYSTEM PUBLIC ${CURL_INCLUDE_DIRS})
		target_link_libraries(${TARGET} ${CURL_LIBRARIES})
		if (NOT STATIC_LINKING)
			ele_copy_dlls(${TARGET} CURL_DLLS)
		endif()
	elseif (NOT ${REQUIRED} STREQUAL "OPTIONAL")
		message(FATAL_ERROR "Curl library not found")
	endif()
endfunction()
