# Copyright (C) 2011 LuaDist
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

# This is a straightforward installer for LuaDist modules.
project ( luadist_installer NONE )
cmake_minimum_required ( VERSION 2.8 )
include ( ExternalProject )

## SETTINGS
# Build Release by default
if ( NOT CMAKE_BUILD_TYPE)
  set ( CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE )
endif ()

# Install dists required for bootstrap by default
if ( NOT DISTS OR DISTS STREQUAL "" )
  set ( DISTS "lua-5.1.4 luafilesystem luasocket md5 unzip openssl luasec luadist" CACHE STRING "List of dists to install (in order)." FORCE )
endif ()
string ( REPLACE " " ";" INSTALL_DISTS "${DISTS}" )
message ( "Installing: ${INSTALL_DISTS}")

# Where to install 
set ( INSTALL_BIN bin CACHE PATH "Where to install binaries to." )
set ( INSTALL_LIB lib CACHE PATH "Where to install libraries to." )
set ( INSTALL_INC include CACHE PATH "Where to install headers to." )
set ( INSTALL_ETC etc CACHE PATH "Where to store configuration files" )
set ( INSTALL_LMOD ${INSTALL_LIB}/lua CACHE PATH "Directory to install Lua modules." )
set ( INSTALL_CMOD ${INSTALL_LIB}/lua CACHE PATH "Directory to install Lua binary modules." )
set ( INSTALL_SHARE share CACHE PATH "Directory for shared data." )

# Skipable content, headers, binaries and libraries are always required
option ( SKIP_TESTING "Do not add tests." OFF)
option ( SKIP_LUA_WRAPPER "Do not build and install Lua executable wrappers." OFF)
option ( SKIP_INSTALL_DATA "Skip installing all data." OFF )
if ( NOT SKIP_INSTALL_DATA )
  option ( SKIP_INSTALL_DOC "Skip installation of documentation." OFF )  
  option ( SKIP_INSTALL_EXAMPLE "Skip installation of documentation." OFF )
  option ( SKIP_INSTALL_TEST "Skip installation of tests." OFF)
  option ( SKIP_INSTALL_FOO "Skip installation of optional package content." OFF)
endif ()

# Use relative path for Lua.
option ( USE_RPATH "Use relative paths and installation " OFF )
if ( USE_RPATH )
  #2DO: This will break if INSTALL_BIN depth changes
  set ( CMAKE_SKIP_BUILD_RPATH FALSE )
  set ( DCMAKE_BUILD_WITH_INSTALL_RPATH FALSE )
  set ( DCMAKE_INSTALL_RPATH "$ORIGIN/../lib" )
  set ( DCMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE )
  set ( DCMAKE_INSTALL_NAME_DIR "@executable_path/../lib" )
  set ( LUA_ROOT "!/../" )
else ()
  set ( LUA_ROOT ${CMAKE_INSTALL_PREFIX} )
endif ()  

# Search paths
set ( CMAKE_INCLUDE_PATH ${CMAKE_INSTALL_PREFIX}/${INSTALL_INC} CACHE PATH "Path to search for headers." FORCE )
set ( CMAKE_LIBRARY_PATH ${CMAKE_INSTALL_PREFIX}/${INSTALL_LIB} CACHE PATH "Path to search for libraries." FORCE )

## External projects needed for Bootstrap
macro ( install_dist _DIST )
  string ( REGEX MATCH "[^-]*" _DIST_NAME ${_DIST} )
  string ( REGEX MATCH "-.*" _DIST_VER ${_DIST} )
  string ( REPLACE "-" "" _DIST_VER "${_DIST_VER}" )

  # If no specific version was requested
  if ( _DIST_VER STREQUAL "" )
    # Use master branch
    set ( _DIST_VER master )
  endif ()

  # Use local resources if they are availble
  if ( EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_DIST_NAME}/dist.info )
    set ( _DIST_SOURCE SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${_DIST_NAME} )
  else ()
    set ( _DIST_SOURCE GIT_REPOSITORY http://github.com/LuaDist/${_DIST_NAME}.git GIT_TAG ${_DIST_VER} )
  endif ()
  
  # Build project with all configuration
  ExternalProject_Add( ${_DIST_NAME} 
      PREFIX ${_DIST_NAME}-${_DIST_VER}
      ${_DIST_SOURCE}
      BINARY_DIR ${_DIST_NAME}-${_DIST_VER}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
      CMAKE_ARGS
        # Basic
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DCMAKE_INCLUDE_PATH:PATH=${CMAKE_INCLUDE_PATH}
        -DCMAKE_LIBRARY_PATH:PATH=${CMAKE_LIBRARY_PATH}
        # Lua config
        -DLUA_ROOT:STRING=${LUA_ROOT}
        # RPath functionality
        -DCMAKE_SKIP_BUILD_RPATH:BOOLEAN=FALSE
        -DCMAKE_BUILD_WITH_INSTALL_RPATH:BOOLEAN=FALSE
        -DCMAKE_INSTALL_RPATH:STRING=$ORIGIN/../lib
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOLEAN=TRUE
        -DCMAKE_INSTALL_NAME_DIR:STRING=@executable_path/../lib
        # Install Paths
        -DINSTALL_BIN:STRING=${INSTALL_BIN}
        -DINSTALL_LIB:STRING=${INSTALL_LIB}
        -DINSTALL_INC:STRING=${INSTALL_INC}
        -DINSTALL_ETC:STRING=${INSTALL_ETC}
        -DINSTALL_LMOD:STRING=${INSTALL_LMOD}
        -DINSTALL_CMOD:STRING=${INSTALL_CMOD}
        -DINSTALL_SHARE:STRING=${INSTALL_SHARE}
        # Install skip options
        -DSKIP_TESTING:BOOLEAN=${DSKIP_TESTING}
        -DSKIP_LUA_WRAPPER:BOOLEAN=${DSKIP_LUA_WRAPPER}
        -DSKIP_INSTALL_DATA:BOOLEAN=${DSKIP_INSTALL_DATA}
        -DSKIP_INSTALL_DOC:BOOLEAN=${DSKIP_INSTALL_DOC}
        -DSKIP_INSTALL_EXAMPLE:BOOLEAN=${DSKIP_INSTALL_EXAMPLE}
        -DSKIP_INSTALL_TEST:BOOLEAN=${DSKIP_INSTALL_TEST}
        -DSKIP_INSTALL_FOO:BOOLEAN=${DSKIP_INSTALL_FOO}
      DEPENDS ${_PREV}
    )
    set ( _PREV ${_DIST_NAME})
    list ( APPEND DEPS ${_DIST_NAME} )
endmacro ()

# Build all dists
foreach ( DIST ${INSTALL_DISTS} )
  install_dist ( ${DIST} )
endforeach ()

# On CMake 2.8.2 (Ubuntu) This may generate an error even if everything is fine. Ignore it, or update to 2.8.4.
add_custom_target ( install
  COMMAND echo "Installation Complete."
  DEPENDS ${_PREV}
)
