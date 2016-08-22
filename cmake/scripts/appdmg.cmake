
if (NOT APP_DMG_EXE)
	message(FATAL_ERROR "Please install appdmg! https://github.com/LinusU/node-appdmg")
endif()

string(REPLACE "/Contents/MacOS" "" ELE_MIX_APP "${ELE_MIX_APP}")
string(REPLACE "/Contents/MacOS" "" ELE_ALELEZERO_APP "${ELE_ALELEZERO_APP}")

set(OUTFILE "${ELE_BUILD_DIR}/appdmg.json")

configure_file(${APP_DMG_FILE} ${OUTFILE})

execute_process(COMMAND ${CMAKE_COMMAND} -E copy "${APP_DMG_ICON}" "${ELE_BUILD_DIR}/appdmg_icon.icns")
execute_process(COMMAND ${CMAKE_COMMAND} -E copy "${APP_DMG_BACKGROUND}" "${ELE_BUILD_DIR}/appdmg_background.png")
execute_process(COMMAND ${CMAKE_COMMAND} -E remove "${ELE_BUILD_DIR}/cpp-elementrem-osx.dmg") 
execute_process(COMMAND ${APP_DMG_EXE} ${OUTFILE} "${ELE_BUILD_DIR}/cpp-elementrem-osx.dmg" RESULT_VARIABLE RETURN_CODE)

if (NOT RETURN_CODE EQUAL 0)
  message(FATAL_ERROR "Failed to run 'appdmg' npm module.  Is it correctly installed?")
endif()
