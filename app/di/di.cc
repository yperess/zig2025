#define PW_LOG_MODULE_NAME "main"

#include "pw_digital_io_zephyr/digital_io.h"
#include "pw_log/log.h"
#include "pw_system/init.h"
#include "pw_system/rpc_server.h"
#include "pw_system/target_hooks.h"
#include "zig2025/di/app.h"
#include "zig2025/rpc/service.h"

namespace {
zig2025::rpc::Service service;
pw::digital_io::ZephyrDigitalOut led(GPIO_DT_SPEC_GET(DT_ALIAS(led0), gpios));
pw::digital_io::ZephyrDigitalInterrupt input_pin(
    GPIO_DT_SPEC_GET(DT_PATH(interrupt_loop), in_gpios));
pw::digital_io::ZephyrDigitalOut output_pin(
    GPIO_DT_SPEC_GET(DT_PATH(interrupt_loop), out_gpios));
uint32_t interrupt_count = 0;
}  // namespace

namespace zig2025::app {
pw::digital_io::DigitalOut& GetLed() { return led; }

pw::digital_io::DigitalInterrupt& GetInputPin() { return input_pin; }

pw::digital_io::DigitalOut& GetOutputPin() { return output_pin; }

pw::rpc::Service& GetService() { return service; }

uint32_t GetAndResetInterruptCount() {
  auto count = interrupt_count;
  interrupt_count = 0;
  return count;
}
}  // namespace zig2025::app

namespace pw::system {
void UserAppInit() {
  // This MUST be here. It might seem reasonable to run some of the init code in
  // the Service constructor, but the way Zephyr runs the constructor doesn't
  // have any dependency ordering so there's no guarantee that the DigitalIO
  // classes would be constructed fully before the call to the Service
  // constructor.
  GetRpcServer().RegisterService(zig2025::app::GetService());
  zig2025::app::GetLed().Enable();
  zig2025::app::GetOutputPin().Enable();
  zig2025::app::GetOutputPin().SetStateInactive();

  zig2025::app::GetInputPin().SetInterruptHandler(
      pw::digital_io::InterruptTrigger::kActivatingEdge,
      [](pw::digital_io::State) {
        interrupt_count++;
        PW_LOG_INFO("Interrupt count: %u", interrupt_count);
      });
  auto status = zig2025::app::GetInputPin().EnableInterruptHandler();
  status = zig2025::app::GetInputPin().Enable();
}
}  // namespace pw::system
