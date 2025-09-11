pw_add_library(zig2025_di STATIC
  HEADERS
    public/zig2025/di/app.h
  PUBLIC_INCLUDES
    public
  SOURCES
    di.cc
  PUBLIC_DEPS
    pw_digital_io_zephyr
    zephyr_interface
    zig2025_service
)

# TODO figure out how to do this better. We have a pw_system.zephyr_target_hooks which define
# everything but the UserAppInit() function. If we have that function in 'app' things work,
# but we really need to append it to the Zephyr backend for the target hooks library.
target_link_libraries(pw_system.init PUBLIC zig2025_di)
