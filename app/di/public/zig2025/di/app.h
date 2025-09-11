#pragma once

#include "pw_digital_io/digital_io.h"

namespace zig2025::app {
pw::digital_io::DigitalOut& GetLed();

pw::digital_io::DigitalInterrupt& GetInputPin();

pw::digital_io::DigitalOut& GetOutputPin();

pw::rpc::Service& GetService();

uint32_t GetAndResetInterruptCount();
}
