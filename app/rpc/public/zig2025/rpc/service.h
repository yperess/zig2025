#pragma once

#include <cstdint>

#include "proto/zig2025.rpc.pwpb.h"
#include "pw_status/status.h"
#include "pw_sync/interrupt_spin_lock.h"

namespace zig2025::rpc {
class Service final
    : public com::google::zig2025::pw_rpc::pwpb::ZigService::Service<Service> {
 public:
  Service();

  pw::Status SetLed(
      const com::google::zig2025::pwpb::SetLedRequest::Message& request,
      com::google::zig2025::pwpb::SetLedResponse::Message& response);

  pw::Status TriggerInterrupt(
      const com::google::zig2025::pwpb::TriggerInterruptRequest::Message&
          request,
      com::google::zig2025::pwpb::TriggerInterruptResponse::Message& response);

  pw::Status GetInterruptCount(
      const com::google::zig2025::pwpb::GetInterruptCountRequest::Message&
          request,
      com::google::zig2025::pwpb::GetInterruptCountResponse::Message& response);

 private:
  pw::sync::InterruptSpinLock spin_lock_;
  uint64_t interrupt_count_;
};
}  // namespace zig2025::rpc
