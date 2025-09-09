cmake_minimum_required(VERSION 3.20.0)

find_package(Python COMPONENTS Interpreter REQUIRED)

set(PW_DIR "${CMAKE_CURRENT_LIST_DIR}/../third_party/pigweed")
include("${PW_DIR}/pw_build/pigweed.cmake")
include("${PW_DIR}/pw_trace/backend.cmake")
include("${PW_DIR}/pw_protobuf_compiler/proto.cmake")

if("${dir_pw_third_party_nanopb}" STREQUAL "")
  set(dir_pw_third_party_nanopb "${CMAKE_CURRENT_LIST_DIR}/../third_party/nanopb" CACHE PATH "" FORCE)
endif()

# One time setup: Zephyr does some strange handling of nanopb by linking the
# sources directly into Zephyr instead of creating a static library which we
# can depend on, so we need to create a fake target to keep the linker happy.
add_library(protobuf-nanopb INTERFACE)
add_compile_definitions(PW_SYSTEM_ENABLE_TRACE_SERVICE=1)
add_compile_definitions(PW_SYSTEM_ENABLE_TRANSFER_SERVICE=0)
pw_set_backend(pw_trace pw_trace_tokenized)

# Add the token database builder BEFORE adding the Zephyr package, otherwise it will not be picked
# up by the build system.
set_property(GLOBAL APPEND PROPERTY extra_post_build_commands
  COMMAND
    ${Python_EXECUTABLE}
    -m pw_tokenizer.database
    create
    --force
    --type binary
    -d ${CMAKE_BINARY_DIR}/tokendatabase.bin
    ${CMAKE_BINARY_DIR}/zephyr/zephyr_pre0.elf
)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(zig2025)

target_sources(app
  PRIVATE
    src/main.cc
)
