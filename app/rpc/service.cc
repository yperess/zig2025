#include "zig2025/rpc/service.h"

#include <chrono>
#include <mutex>

#include "pw_chrono/system_clock.h"
#include "pw_log/log.h"
#include "zig2025/di/app.h"

using namespace std::chrono_literals;

namespace zig2025::rpc {
Service::Service() {}

pw::Status Service::SetLed(
    const com::google::zig2025::pwpb::SetLedRequest::Message& request,
    com::google::zig2025::pwpb::SetLedResponse::Message&) {
  if (request.on) {
    app::GetLed().SetStateActive();
  } else {
    app::GetLed().SetStateInactive();
  }
  return pw::OkStatus();
}

pw::Status Service::TriggerInterrupt(
    const com::google::zig2025::pwpb::TriggerInterruptRequest::Message&,
    com::google::zig2025::pwpb::TriggerInterruptResponse::Message&) {
  std::lock_guard lock(spin_lock_);
  auto start_time = pw::chrono::SystemClock::now();
  app::GetOutputPin().SetStateActive();
  while (pw::chrono::SystemClock::now() - start_time <
         pw::chrono::SystemClock::for_at_least(200ns)) {
  }
  app::GetOutputPin().SetStateInactive();
  return pw::OkStatus();
}

pw::Status Service::GetInterruptCount(
    const com::google::zig2025::pwpb::GetInterruptCountRequest::Message&,
    com::google::zig2025::pwpb::GetInterruptCountResponse::Message& response) {
  response.count = app::GetAndResetInterruptCount();
  return pw::OkStatus();
}
}  // namespace zig2025::rpc
