pw_proto_library(zig2025_proto
  SOURCES
    proto/zig2025.proto
  INPUTS
    proto/zig2025.options
)

pw_add_library(zig2025_service STATIC
  HEADERS
    public/zig2025/rpc/service.h
  PUBLIC_INCLUDES
    public
  SOURCES
    service.cc
  PUBLIC_DEPS
    zig2025_proto.pwpb_rpc
    zephyr_interface
  PRIVATE_DEPS
    zig2025_di
    pw_chrono.system_clock
    pw_rpc.server
    pw_log
    pw_system.work_queue
    pw_sync.interrupt_spin_lock
)
