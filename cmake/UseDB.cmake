function(ele_apply TARGET REQUIRED SUBMODULE)	

	find_package (LevelDB REQUIRED)
	find_package (RocksDB QUIET)

	if (${SUBMODULE} STREQUAL "auto")
		if (ROCKSDB AND ROCKSDB_FOUND)
			ele_use(${TARGET} ${REQUIRED} DB::RocksDB)
		else ()
			ele_use(${TARGET} ${REQUIRED} DB::LevelDB)
		endif()
	endif()

	if (${SUBMODULE} STREQUAL "RocksDB")
		ele_show_dependency(ROCKSDB RocksDB)
		target_include_directories(${TARGET} SYSTEM PUBLIC ${ROCKSDB_INCLUDE_DIRS})
		target_link_libraries(${TARGET} ${ROCKSDB_LIBRARIES})
		target_compile_definitions(${TARGET} PUBLIC "ELE_ROCKSDB")
	endif()

	if (${SUBMODULE} STREQUAL "LevelDB")
		ele_show_dependency(LEVELDB LevelDB)
		target_include_directories(${TARGET} SYSTEM PUBLIC ${LEVELDB_INCLUDE_DIRS})
		target_link_libraries(${TARGET} ${LEVELDB_LIBRARIES})
	endif()

endfunction()
